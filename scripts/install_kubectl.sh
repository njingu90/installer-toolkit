#!/usr/bin/env bash
set -euo pipefail

# ── Logging helpers ───────────────────────────────
log()     { echo -e "ℹ️  kubectl: $*"; }
success() { echo -e "✅  kubectl: $*"; }
warn()    { echo -e "⚠️  kubectl: $*" >&2; }
error()   { echo -e "❌  kubectl: $*" >&2; exit 1; }

# ── Resolve latest stable version ────────────────
TAG="$(curl -sL https://dl.k8s.io/release/stable.txt)"
log "resolved latest version → $TAG"

# ── Detect OS & ARCH ─────────────────────────────
OS="$(uname | tr '[:upper:]' '[:lower:]')"
case "$OS" in
  linux|darwin) ;;
  *) error "unsupported OS: $OS" ;;
esac

ARCH_RAW="$(uname -m)"
case "$ARCH_RAW" in
  x86_64)         ARCH="amd64" ;;
  arm64|aarch64)  ARCH="arm64" ;;
  armv7*|armv6*)  ARCH="arm"   ;;
  *) error "unsupported architecture: $ARCH_RAW" ;;
esac

# ── Download ─────────────────────────────────────
URL="https://dl.k8s.io/release/${TAG}/bin/${OS}/${ARCH}/kubectl"
FILE="kubectl"

log "downloading from $URL"
curl -sL --fail "$URL" -o "$FILE"

# ── Install ──────────────────────────────────────
chmod +x "$FILE"
sudo mv "$FILE" /usr/local/bin/kubectl

success "kubectl installed successfully (version ${TAG})"
