#!/usr/bin/env bash
set -euo pipefail

# ── Logging helpers ─────────────────────────────────────────────────────────────
log()     { echo -e "ℹ️  awscli: $*"; }
success() { echo -e "✅  awscli: $*"; }
warn()    { echo -e "⚠️  awscli: $*" >&2; }
error()   { echo -e "❌  awscli: $*" >&2; exit 1; }

# ── Parse version argument ───────────────────────────────────────────────────────
VERSION="${1:-LATEST}"

# ── Detect OS and ARCH ──────────────────────────────────────────────────────────
OS="$(uname | tr '[:upper:]' '[:lower:]')"
case "$OS" in
  linux|darwin) ;;
  *) error "unsupported OS: $OS" ;;
esac

ARCH_RAW="$(uname -m)"
case "$ARCH_RAW" in
  x86_64)   ARCH="x86_64" ;;
  aarch64)  ARCH="arm64"  ;;
  arm64)    ARCH="arm64"  ;;
  *)        error "unsupported architecture: $ARCH_RAW" ;;
esac

# ── Helper to fetch the real latest version tag via GitHub API ───────────────────
fetch_latest() {
  curl -sL https://api.github.com/repos/aws/aws-cli/releases/latest \
    | grep '"tag_name":' \
    | sed -E 's/.*"([^"]+)".*/\1/'
}

TAG="$VERSION"
if [[ "$VERSION" == "LATEST" || -z "$VERSION" ]]; then
  TAG="$(fetch_latest)"
  log "resolved latest version → $TAG"
fi

# ── Build download URL & filename ───────────────────────────────────────────────
if [[ "$OS" == "linux" ]]; then
  FILENAME="awscli-exe-${OS}-${ARCH}-${TAG}.zip"
  URL="https://awscli.amazonaws.com/${FILENAME}"
else
  # macOS
  FILENAME="AWSCLIV2-${TAG}.pkg"
  URL="https://awscli.amazonaws.com/${FILENAME}"
fi

# ── Download (with fallback to latest if specific version missing) ───────────────
log "downloading from $URL"
if ! curl --fail -L "$URL" -o "$FILENAME"; then
  warn "version '$TAG' not found, falling back to latest"
  TAG="$(fetch_latest)"
  log "resolved latest version → $TAG"
  if [[ "$OS" == "linux" ]]; then
    FILENAME="awscli-exe-linux-${ARCH}-${TAG}.zip"
    URL="https://awscli.amazonaws.com/${FILENAME}"
  else
    FILENAME="AWSCLIV2.pkg"
    URL="https://awscli.amazonaws.com/AWSCLIV2.pkg"
  fi
  curl -L "$URL" -o "$FILENAME"
fi

# ── Install ─────────────────────────────────────────────────────────────────────
if [[ "$OS" == "linux" ]]; then
  unzip -q "$FILENAME"
  sudo ./aws/install --update
  rm -rf "$FILENAME" aws
else
  sudo installer -pkg "$FILENAME" -target /
  rm -f "$FILENAME"
fi

success "installed awscli $TAG"
