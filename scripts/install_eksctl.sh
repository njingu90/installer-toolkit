#!/usr/bin/env bash
set -euo pipefail

# ── Logging helpers ───────────────────────────────
log()     { echo -e "ℹ️  eksctl: $*"; }
success() { echo -e "✅  eksctl: $*"; }
warn()    { echo -e "⚠️  eksctl: $*" >&2; }
error()   { echo -e "❌  eksctl: $*" >&2; exit 1; }

# ── Detect OS & ARCH ─────────────────────────────
OS="$(uname -s)"  # Linux or Darwin
ARCH_RAW="$(uname -m)"

case "$ARCH_RAW" in
  x86_64|amd64)      ARCH="amd64" ;;
  arm64|aarch64)     ARCH="arm64" ;;
  *) error "unsupported architecture: $ARCH_RAW" ;;
esac

FILE="eksctl_${OS}_${ARCH}.tar.gz"
URL="https://github.com/eksctl-io/eksctl/releases/latest/download/${FILE}"

# ── Download ─────────────────────────────────────
log "downloading eksctl from $URL"
curl -sL --fail "$URL" -o "$FILE"

# ── Extract & install ────────────────────────────
log "extracting $FILE"
tar -xzf "$FILE" -C /tmp

log "installing eksctl to /usr/local/bin (requires sudo)"
sudo install -m 0755 /tmp/eksctl /usr/local/bin/eksctl

# ── Cleanup ──────────────────────────────────────
rm -f "$FILE" /tmp/eksctl

success "eksctl installed successfully (latest version)"
