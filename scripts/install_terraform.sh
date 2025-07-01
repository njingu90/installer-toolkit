#!/usr/bin/env bash
set -euo pipefail

# ── Logging helpers ───────────────────────────────
log()     { echo -e "ℹ️  terraform: $*"; }
success() { echo -e "✅  terraform: $*"; }
warn()    { echo -e "⚠️  terraform: $*" >&2; }
error()   { echo -e "❌  terraform: $*" >&2; exit 1; }

# ── Check dependencies ────────────────────────────
command -v jq >/dev/null 2>&1 || { error "jq is required but not installed."; }
command -v unzip >/dev/null 2>&1 || { error "unzip is required but not installed."; }
command -v curl >/dev/null 2>&1 || { error "curl is required but not installed."; }

# ── Detect OS & ARCH ─────────────────────────────
OS="$(uname | tr '[:upper:]' '[:lower:]')"
case "$OS" in
  linux|darwin) ;;
  *) error "unsupported OS: $OS" ;;
esac

ARCH_RAW="$(uname -m)"
case "$ARCH_RAW" in
  x86_64|amd64)     ARCH="amd64" ;;
  arm64|aarch64)    ARCH="arm64" ;;
  *) error "unsupported architecture: $ARCH_RAW" ;;
esac

terraform-install() {
  local BIN="${HOME}/bin/terraform"
  if [[ -f "$BIN" ]]; then
    log "$("$BIN" version) already installed at $BIN"
    return 0
  fi

  log "Fetching latest Terraform release info..."
  local INDEX_JSON
  INDEX_JSON=$(curl -sL https://releases.hashicorp.com/terraform/index.json)
  local LATEST_VERSION
  LATEST_VERSION=$(echo "$INDEX_JSON" | jq -r '.versions | to_entries | map(select(.value.builds[].os=="'"$OS"'" and .value.builds[].arch=="'"$ARCH"'")) | sort_by(.key) | last.key')
  [[ -z "$LATEST_VERSION" ]] && error "Could not determine latest Terraform version for $OS/$ARCH"

  local DOWNLOAD_URL
  DOWNLOAD_URL=$(echo "$INDEX_JSON" | jq -r --arg ver "$LATEST_VERSION" --arg os "$OS" --arg arch "$ARCH" '
    .versions[$ver].builds[] | select(.os==$os and .arch==$arch) | .url
  ')
  [[ -z "$DOWNLOAD_URL" ]] && error "Could not find download URL for $OS/$ARCH"

  log "Downloading Terraform $LATEST_VERSION from $DOWNLOAD_URL"
  local TMP_ZIP="/tmp/terraform_${LATEST_VERSION}_${OS}_${ARCH}.zip"
  curl -sSL "$DOWNLOAD_URL" -o "$TMP_ZIP"

  mkdir -p "${HOME}/bin"
  (cd "${HOME}/bin" && unzip -o "$TMP_ZIP")

  # Ensure PATH is set in .bashrc
  if ! grep -q 'export PATH="$HOME/bin:$PATH"' ~/.bashrc; then
    echo 'export PATH="$HOME/bin:$PATH"' >> ~/.bashrc
  fi

  rm -f "$TMP_ZIP"

  log "Installed: $("${HOME}/bin/terraform" version)"

  cat << EOF

Run the following to reload your PATH with terraform:
  source ~/.bashrc
EOF

  success "Terraform installed successfully (version $LATEST_VERSION)"
}

terraform-install
