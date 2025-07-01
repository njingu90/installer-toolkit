#!/usr/bin/env bash
set -euo pipefail

# ── Configuration ────────────────────────────────
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
SCRIPTS_DIR="${SCRIPT_DIR}/scripts"

# ── Helpers ───────────────────────f──────────────
log()     { echo -e "ℹ️  $*"; }
success() { echo -e "✅  $*"; }
warn()    { echo -e "⚠️  $*" >&2; }
error()   { echo -e "❌  $*" >&2; exit 1; }

# usage / help
usage() {
  cat <<EOF
Usage:
  $(basename "$0") help
  $(basename "$0") TOOL [TOOL...]
  $(basename "$0") (no args → fzf)

Examples:
  $(basename "$0") help
  $(basename "$0") awscli terraform docker
  $(basename "$0") (and select with fzf)

If you run with no arguments and have 'fzf' installed, you can select tools interactively.
EOF
}

# ── Pick tools ───────────────────────────────────
if (( $# == 0 )); then
  if command -v fzf &>/dev/null; then
    log "Select tool(s) to install (multi-select with TAB, ENTER when done):"
    mapfile -t tools < <(
      ls "$SCRIPTS_DIR"/install_*.sh 2>/dev/null \
        | xargs -n1 basename \
        | sed -E 's/install_(.*)\.sh/\1/' \
        | fzf --multi --prompt="→ "
    )
    (( ${#tools[@]} )) || { usage; exit; }
  else
    usage; exit
  fi
else
  case "$1" in
    help|-h|--help) usage; exit ;;
    *) tools=("$@") ;;
  esac
fi

# ── Install loop ────────────────────────────────
for tool in "${tools[@]}"; do
  script="${SCRIPTS_DIR}/install_${tool}.sh"
  if [[ ! -x "$script" ]]; then
    warn "installer not found or not executable: $script"
    continue
  fi

  log "→ Installing $tool (latest version)"
  if bash "$script"; then
    success "$tool installed successfully"
  else
    error "$tool install failed!"
  fi
done
