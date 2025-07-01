#!/usr/bin/env bash
set -euo pipefail

# ── Logging helpers ───────────────────────────────
log()     { echo -e "ℹ️  docker: $*"; }
success() { echo -e "✅  docker: $*"; }
warn()    { echo -e "⚠️  docker: $*" >&2; }
error()   { echo -e "❌  docker: $*" >&2; exit 1; }

# ── Check OS ─────────────────────────────────────
if [[ "$(uname -s)" != "Linux" ]]; then
  error "This script currently supports Linux (Ubuntu) only"
fi

# ── Remove old versions ──────────────────────────
log "removing old Docker versions if present"
sudo apt-get remove -y docker docker-engine docker.io containerd runc || true

# ── Update package index ─────────────────────────
log "updating package index"
sudo apt-get update -y

# ── Install dependencies ─────────────────────────
log "installing required packages"
sudo apt-get install -y \
    ca-certificates \
    curl \
    gnupg \
    lsb-release

# ── Add Docker GPG key ───────────────────────────
log "adding Docker GPG key"
sudo install -m 0755 -d /etc/apt/keyrings
curl -fsSL https://download.docker.com/linux/ubuntu/gpg | \
  sudo gpg --dearmor -o /etc/apt/keyrings/docker.gpg

# ── Add Docker repository ────────────────────────
log "setting up Docker repository"
echo \
  "deb [arch=\"$(dpkg --print-architecture)\" signed-by=/etc/apt/keyrings/docker.gpg] \
  https://download.docker.com/linux/ubuntu \
  $(lsb_release -cs) stable" | \
  sudo tee /etc/apt/sources.list.d/docker.list > /dev/null

# ── Update and install Docker ────────────────────
log "updating package index again"
sudo apt-get update -y

log "installing latest Docker packages"
sudo apt-get install -y docker-ce docker-ce-cli containerd.io docker-buildx-plugin docker-compose-plugin

# ── Enable and start Docker ──────────────────────
log "enabling and starting Docker service"
sudo systemctl enable docker
sudo systemctl start docker

# ── Verify installation ──────────────────────────
docker --version
docker compose version

success "Docker and Docker Compose installed successfully"
