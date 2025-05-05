#!/usr/bin/env bash
set -euo pipefail

# ── Configuration ──────────────────────────────────────────────────────────────
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
SCRIPTS_DIR="${SCRIPT_DIR}/scripts"
VERSIONS_FILE="${SCRIPT_DIR}/versions.txt"

# ── Helpers ────────────────────────────────────────────────────────────────────
log()   { echo -e "ℹ️  $*"; }
success(){ echo -e "✅  $*"; }
warn()   { echo -e "⚠️  $*" >&2; }
error(){ echo -e "❌  $*" >&2; exit 1; }

# load versions.txt into associative array
declare -A VERSIONS
if [[ -f "$VERSIONS_FILE" ]]; then
  while IFS='=' read -r key val; do
    [[ -z "$key" || "$key" =~ ^[[:space:]]*# ]] && continue
    VERSIONS["${key^^}"]="${val:-LATEST}"
  done <"$VERSIONS_FILE"
else
  warn "No versions.txt found; all tools will use latest."
fi

# usage / help
usage(){
  cat <<EOF
Usage:
  $(basename "$0") help
  $(basename "$0") [install] TOOL [TOOL...]
  $(basename "$0") (no args → fzf)

Examples:
  $(basename "$0") help
  $(basename "$0") install velero terraform awscli
  $(basename "$0") kubectl docker

If you run with no arguments and have 'fzf' installed, you can select tools interactively.
EOF
}

# ── Pick tools ──────────────────────────────────────────────────────────────────
if (( $# == 0 )); then
  if command -v fzf &>/dev/null; then
    log "Select tool(s) to install (multi-select with TAB, ENTER when done):"
    mapfile -t tools < <(
      ls "$SCRIPTS_DIR"/install_*.sh 2>/dev/null \
        | xargs -n1 basename \
        | sed -E 's/install_(.*)\.sh/\1/' \
        | fzf --multi --prompt="→ " 
    )
    (( ${#tools[@]} )) || usage && exit
  else
    usage; exit
  fi
else
  case "$1" in
    help|-h|--help) usage; exit ;;
    install) shift; (( $# )) || { warn "no tools specified"; usage; exit 1; }; tools=("$@") ;;
    *) tools=("$@") ;;
  esac
fi

# ── Install loop ────────────────────────────────────────────────────────────────
for tool in "${tools[@]}"; do
  script="${SCRIPTS_DIR}/install_${tool}.sh"
  if [[ ! -x "$script" ]]; then
    warn "installer not found or not executable: $script"
    continue
  fi

  # look up version (uppercase key)
  key="${tool^^}"
  version="${VERSIONS[$key]:-LATEST}"
  log "→ $tool: requested version '$version'"

  # call the installer with version as first arg
  if bash "$script" "$version"; then
    success "$tool installed (version: $version)"
  else
    warn "$tool installer failed for version '$version', retrying with latest…"
    bash "$script" "LATEST" \
      && success "$tool installed (latest fallback)" \
      || error "$tool install even with latest failed!"
  fi
done
