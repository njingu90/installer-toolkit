#!/usr/bin/env bash
#script install velero on ubuntu
# This script installs the latest version of Velero on Linux.
# Velero is a tool for managing backups and restores of Kubernetes clusters.
set -euo pipefail

# === Configuration ===
REPO="vmware-tanzu/velero"
INSTALL_DIR="/usr/local/bin"    # adjust if you prefer another location

# === Detect platform ===
OS="$(uname | tr '[:upper:]' '[:lower:]')"
ARCH="$(uname -m)"
case "$ARCH" in
  x86_64) ARCH="amd64" ;;
  aarch64) ARCH="arm64" ;;
  armv7*|armv6*) ARCH="arm" ;;
  *) echo "Unsupported architecture: $ARCH"; exit 1 ;;
esac

# === Fetch latest tag ===
LATEST_TAG="$(curl -sL "https://api.github.com/repos/$REPO/releases/latest" \
  | grep '"tag_name":' \
  | sed -E 's/.*"([^"]+)".*/\1/')"

if [[ -z "$LATEST_TAG" ]]; then
  echo "Failed to determine latest Velero release."
  exit 1
fi

# === Build download URL ===
TARBALL="velero-${LATEST_TAG}-${OS}-${ARCH}.tar.gz"
DOWNLOAD_URL="https://github.com/${REPO}/releases/download/${LATEST_TAG}/${TARBALL}"

echo "Downloading Velero ${LATEST_TAG} for ${OS}/${ARCH}..."
curl -L --progress-bar "$DOWNLOAD_URL" -o "$TARBALL"

echo "Extracting..."
tar -xzf "$TARBALL"

# The extracted folder is named like velero-<tag>-<os>-<arch>/
EXTRACTED_DIR="velero-${LATEST_TAG}-${OS}-${ARCH}"

echo "Installing to ${INSTALL_DIR} (requires sudo)..."
sudo mv "${EXTRACTED_DIR}/velero" "${INSTALL_DIR}/velero"

# Cleanup
rm -rf "$TARBALL" "$EXTRACTED_DIR"

echo "✅ Velero ${LATEST_TAG} installed to ${INSTALL_DIR}/velero"
#!/usr/bin/env bash
set -euo pipefail

VERSION="${1:-LATEST}"
REPO="vmware-tanzu/velero"

# detect OS/ARCH
OS="$(uname | tr '[:upper:]' '[:lower:]')"
ARCH="$(uname -m)"
case "$ARCH" in
  x86_64) ARCH="amd64" ;;
  aarch64) ARCH="arm64" ;;
  *) ARCH="arm" ;;
esac

fetch_latest_tag(){
  curl -sL "https://api.github.com/repos/$REPO/releases/latest" \
    | grep '"tag_name":' \
    | sed -E 's/.*"([^"]+)".*/\1/'
}

TAG="$VERSION"
if [[ "$VERSION" == "LATEST" ]]; then
  TAG="$(fetch_latest_tag)"
  echo "ℹ️  velero: resolved latest tag $TAG"
fi

TARBALL="velero-${TAG}-${OS}-${ARCH}.tar.gz"
URL="https://github.com/${REPO}/releases/download/${TAG}/${TARBALL}"

curl --fail -L "$URL" -o "$TARBALL" || {
  echo "⚠️  velero: version '$TAG' not found, will retry latest"
  TAG="$(fetch_latest_tag)"
  URL="https://github.com/${REPO}/releases/download/${TAG}/velero-${TAG}-${OS}-${ARCH}.tar.gz"
  curl -L "$URL" -o "$TARBALL"
}

echo "ℹ️  Extracting $TARBALL…"
tar -xzf "$TARBALL"
sudo mv "velero-${TAG}-${OS}-${ARCH}/velero" /usr/local/bin/velero
rm -rf "$TARBALL" "velero-${TAG}-${OS}-${ARCH}"
echo "✅  velero ${TAG} installed"
