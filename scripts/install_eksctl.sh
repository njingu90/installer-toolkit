#!/usr/bin/env bash
set -euo pipefail

# ── Logging helpers ─────────────────────────────────────────────────────────────
log()     { echo -e "ℹ️  eksctl: $*"; }
success() { echo -e "✅  eksctl: $*"; }
warn()    { echo -e "⚠️  eksctl: $*" >&2; }
error()   { echo -e "❌  eksctl: $*" >&2; exit 1; }

# ── Parse version argument ───────────────────────────────────────────────────────
VERSION="${1:-LATEST}"

# ── Detect OS & ARCH ─────────────────────────────────────────────────────────────
OS="$(uname -s)"    # “Linux” or “Darwin”
ARCH_RAW="$(uname -m)"
case "$ARCH_RAW" in
  x86_64)       ARCH="amd64"  ;;
  aarch64|arm64) ARCH="arm64" ;;
  armv7* )      ARCH="armv7"  ;;
  armv6* )      ARCH="armv6"  ;;
  *)            error "unsupported architecture: $ARCH_RAW" ;;
esac

# ── Determine download base URL ────────────────────────────────────────────────
if [[ -z "$VERSION" || "$VERSION" == "LATEST" ]]; then
  BASE_URL="https://github.com/eksctl-io/eksctl/releases/latest/download"
  log "resolved latest release"
else
  TAG="${VERSION#v}"  # strip leading “v” if provided
  BASE_URL="https://github.com/eksctl-io/eksctl/releases/download/${TAG}"
  log "requested version → ${TAG}"
fi

FILE="eksctl_${OS}_${ARCH}.tar.gz"
URL="${BASE_URL}/${FILE}"

# ── Download (with fallback to latest) ──────────────────────────────────────────
log "downloading from $URL"
if ! curl -sL --fail "$URL" -o "$FILE"; then
  if [[ "$VERSION" != "LATEST" ]]; then
    warn "version '${TAG}' not found, falling back to latest"
    BASE_URL="https://github.com/eksctl-io/eksctl/releases/latest/download"
    URL="${BASE_URL}/${FILE}"
    log "retrying download from $URL"
    curl -sL --fail "$URL" -o "$FILE" || error "download failed for latest release"
  else
    error "download failed for latest release"
  fi
fi

# ── Extract & install ──────────────────────────────────────────────────────────
log "extracting $FILE"
tar -xzf "$FILE" -C /tmp
log "installing eksctl to /usr/local/bin (requires sudo)"
sudo install -m 0755 /tmp/eksctl /usr/local/bin/eksctl

# ── Cleanup ─────────────────────────────────────────────────────────────────────
rm -f "$FILE" /tmp/eksctl

success "eksctl installed"
