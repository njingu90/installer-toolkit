#!/usr/bin/env bash
set -euo pipefail

REPO_URL="https://github.com/njingu90/installer-toolkit.git"
WORKDIR="$(mktemp -d)"

cleanup() {
  rm -rf "$WORKDIR"
}
trap cleanup EXIT

git clone --depth 1 "$REPO_URL" "$WORKDIR/installer-toolkit"
cd "$WORKDIR/installer-toolkit"
chmod +x main.sh scripts/*.sh
./main.sh --all
