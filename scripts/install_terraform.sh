#!/usr/bin/env bash
set -euo pipefail

# ── Logging helpers ───────────────────────────────
log()     { echo -e "ℹ️  terraform: $*"; }
success() { echo -e "✅  terraform: $*"; }
warn()    { echo -e "⚠️  terraform: $*" >&2; }
error()   { echo -e "❌  terraform: $*" >&2; exit 1; }

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

# ── Get latest Terraform version ────────────────
TAG="$(curl -sL https://releases.hashicorp.com/terraform/ | grep -oP 'terraform/\K[0-9]+\.[0-9]+\.[0-9]+' | head -n 1)"
if [[ -z "$TAG" ]]; then
  error "could not determine latest Terraform version"
fi
log "resolved latest version → $TAG"

# ── Build download URL ──────────────────────────
FILE="terraform_${TAG}_${OS}_${ARCH}.zip"
URL="https://releases.hashicorp.com/terraform/${TAG}/${FILE}"

# ── Download ────────────────────────────────────
log "downloading Terraform from $URL"
curl -sL --fail "$URL" -o "$FILE"

# ── Extract & install ──────────────────────────
unzip -q "$FILE"
sudo install -m 0755 terraform /usr/local/bin/terraform

# ── Cleanup ─────────────────────────────────────
rm -f "$FILE" terraform

success "Terraform installed successfully (version ${TAG})"
