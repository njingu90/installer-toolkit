#!/usr/bin/env bash

LOG_FILE="/tmp/installer-toolkit.txt"

log()     { echo -e "ℹ️  $*"; }
success() { echo -e "✅  $*"; }
warn()    { echo -e "⚠️  $*"; }
error()   { echo -e "❌  $*"; exit 1; }

setup_logging() {
  : >"$LOG_FILE"
  exec > >(tee -a "$LOG_FILE") 2>&1
  log "Logging to $LOG_FILE"
}
