#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
SCRIPTS_DIR="${SCRIPT_DIR}/scripts"

source "${SCRIPT_DIR}/lib/common.sh"
source "${SCRIPT_DIR}/lib/tools.sh"

usage() {
  cat <<USAGE
Usage:
  $(basename "$0") --all

Notes:
  * --all is required and will only install tools that are missing.
  * Logs are written to ${LOG_FILE}.
USAGE
}

if [[ "${1:-}" == "help" || "${1:-}" == "-h" || "${1:-}" == "--help" ]]; then
  usage
  exit 0
fi

if [[ "${1:-}" != "--all" || "$#" -ne 1 ]]; then
  usage
  error "This script only supports the --all flag"
fi

setup_logging
log "Starting installer-toolkit with --all"

for tool in "${TOOLS[@]}"; do
  if is_installed "$tool"; then
    success "$tool is already installed; skipping"
    continue
  fi

  script="$(installer_for "$tool")"
  if [[ ! -x "$script" ]]; then
    warn "Installer missing or not executable: $script"
    continue
  fi

  log "Installing missing tool: $tool"
  if bash "$script"; then
    success "$tool installed successfully"
  else
    error "$tool installation failed"
  fi
done

success "Installer run complete"
