#!/usr/bin/env bash
#script install velero on ubuntu
# This script installs the latest version of Velero on Linux.
# Velero is a tool for managing backups and restores of Kubernetes clusters.
set -euo pipefail

# ── Logging helpers ───────────────────────────────
log()     { echo -e "ℹ️  velero: $*"; }
success() { echo -e "✅  velero: $*"; }
warn()    { echo -e "⚠️  velero: $*" >&2; }
error()   { echo -e "❌  velero: $*" >&2; exit 1; }

# ── Config ────────────────────────────────────────
REPO="vmware-tanzu/velero"
INSTALL_DIR="/usr/local/bin"

# ── Detect OS & ARCH ─────────────────────────────
OS="$(uname | tr '[:upper:]' '[:lower:]')"
ARCH_RAW="$(uname -m)"
case "$ARCH_RAW" in
  x86_64)      ARCH="amd64" ;;
  aarch64)     ARCH="arm64" ;;
  armv7*|armv6*) ARCH="arm" ;;
  *) error "unsupported architecture: $ARCH_RAW" ;;
esac

# ── Fetch latest tag ─────────────────────────────
LATEST_TAG="$(curl -sL "https://api.github.com/repos/$REPO/releases/latest" \
  | grep '"tag_name":' \
  | sed -E 's/.*"([^"]+)".*/\1/')"

if [[ -z "$LATEST_TAG" ]]; then
  error "failed to determine latest Velero release"
fi

log "resolved latest version → $LATEST_TAG"

# ── Build download URL ───────────────────────────
TARBALL="velero-${LATEST_TAG}-${OS}-${ARCH}.tar.gz"
URL="https://github.com/${REPO}/releases/download/${LATEST_TAG}/${TARBALL}"

# ── Download ─────────────────────────────────────
log "downloading from $URL"
curl -sL --fail "$URL" -o "$TARBALL"

# ── Extract & install ───────────────────────────
log "extracting $TARBALL"
tar -xzf "$TARBALL"

EXTRACTED_DIR="velero-${LATEST_TAG}-${OS}-${ARCH}"
sudo mv "${EXTRACTED_DIR}/velero" "${INSTALL_DIR}/velero"

# ── Cleanup ──────────────────────────────────────
rm -rf "$TARBALL" "$EXTRACTED_DIR"

success "Velero ${LATEST_TAG} installed to ${INSTALL_DIR}/velero"
