#!/usr/bin/env bash
set -euo pipefail

# ── Logging helpers ─────────────────────────────────────────────────────────────
log()     { echo -e "ℹ️  kubectl: $*"; }
success() { echo -e "✅  kubectl: $*"; }
warn()    { echo -e "⚠️  kubectl: $*" >&2; }
error()   { echo -e "❌  kubectl: $*" >&2; exit 1; }

# ── Parse version argument ───────────────────────────────────────────────────────
VERSION="${1:-LATEST}"

# ── Resolve tag ─────────────────────────────────────────────────────────────────
if [[ -z "$VERSION" || "$VERSION" == "LATEST" ]]; then
  TAG="$(curl -sL https://dl.k8s.io/release/stable.txt)"
  log "resolved latest version → $TAG"
else
  # ensure leading "v"
  TAG="v${VERSION#v}"
  log "requested version → $TAG"
fi

# ── Detect OS & ARCH ─────────────────────────────────────────────────────────────
OS="$(uname | tr '[:upper:]' '[:lower:]')"
case "$OS" in
  linux|darwin) ;;
  *) error "unsupported OS: $OS";;
esac

ARCH_RAW="$(uname -m)"
case "$ARCH_RAW" in
  x86_64)    ARCH="amd64" ;;
  aarch64|arm64) ARCH="arm64" ;;
  armv7*|armv6*) ARCH="arm" ;;
  *) error "unsupported architecture: $ARCH_RAW";;
esac

# ── Download kubectl ────────────────────────────────────────────────────────────
URL="https://dl.k8s.io/release/${TAG}/bin/${OS}/${ARCH}/kubectl"
FILE="kubectl"

log "downloading from $URL"
if ! curl -sL --fail "$URL" -o "$FILE"; then
  warn "version '$TAG' not found, falling back to latest"
  TAG="$(curl -sL https://dl.k8s.io/release/stable.txt)"
  URL="https://dl.k8s.io/release/${TAG}/bin/${OS}/${ARCH}/kubectl"
  log "retrying with $TAG → $URL"
  curl -sL --fail "$URL" -o "$FILE" || error "download failed for latest version"
fi

# ── Install ─────────────────────────────────────────────────────────────────────
chmod +x "$FILE"
sudo mv "$FILE" /usr/local/bin/kubectl

success "installed kubectl ${TAG}"