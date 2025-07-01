#!/usr/bin/env bash
set -euo pipefail

# ── Logging helpers ───────────────────────────────
log()     { echo -e "ℹ️  awscli: $*"; }
success() { echo -e "✅  awscli: $*"; }
warn()    { echo -e "⚠️  awscli: $*" >&2; }
error()   { echo -e "❌  awscli: $*" >&2; exit 1; }

# ── Detect OS and ARCH ────────────────────────────
OS="$(uname | tr '[:upper:]' '[:lower:]')"
case "$OS" in
  linux|darwin) ;;
  *) error "unsupported OS: $OS" ;;
esac

ARCH_RAW="$(uname -m)"
case "$ARCH_RAW" in
  x86_64|amd64) ARCH="x86_64" ;;
  arm64|aarch64) ARCH="arm64" ;;
  *) error "unsupported architecture: $ARCH_RAW" ;;
esac

# ── Download & install ────────────────────────────
if [[ "$OS" == "linux" ]]; then
  TMP_DIR="$(mktemp -d)"
  cd "$TMP_DIR"
  log "downloading AWS CLI latest zip for Linux $ARCH"
  curl -s "https://awscli.amazonaws.com/awscli-exe-linux-${ARCH}.zip" -o "awscliv2.zip"
  unzip -q awscliv2.zip
  sudo ./aws/install --update
  cd -
  rm -rf "$TMP_DIR"
else
  # macOS
  PKG_FILE="AWSCLIV2.pkg"
  log "downloading AWS CLI latest pkg for macOS"
  curl -s "https://awscli.amazonaws.com/AWSCLIV2.pkg" -o "$PKG_FILE"
  sudo installer -pkg "$PKG_FILE" -target /
  rm -f "$PKG_FILE"
fi

success "AWS CLI installed successfully (latest version)"
