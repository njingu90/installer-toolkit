# Codebase Study: installer-toolkit

## What this repository does

`installer-toolkit` is a Bash-based CLI that installs common developer/DevOps tools (AWS CLI, kubectl, eksctl, Terraform, Velero, and Docker) by orchestrating per-tool install scripts under `scripts/`.

## High-level flow

1. `main.sh` discovers available installer scripts named `install_*.sh`.
2. It determines target tools from:
   - `--all`
   - explicit positional tool names
   - interactive `fzf` selection when no args are passed.
3. For each selected tool, `main.sh` runs `scripts/install_<tool>.sh`.
4. Each installer script resolves latest version/source, downloads binaries/packages, and installs with `sudo` when needed.

## Key components

- `main.sh`
  - CLI entrypoint.
  - Help/usage output generated from files in `scripts/`.
  - Validation: warns and skips non-existent/non-executable installers.
  - Exit behavior: fails immediately if any selected installer script fails.

- `scripts/install_awscli.sh`
  - Detects Linux/macOS + arch.
  - Downloads official AWS CLI package and installs via vendor installer.

- `scripts/install_kubectl.sh`
  - Fetches latest stable Kubernetes tag (`stable.txt`).
  - Downloads and installs matching `kubectl` for detected OS/arch.

- `scripts/install_eksctl.sh`
  - Downloads latest release tarball from GitHub release redirect URL.
  - Installs binary into `/usr/local/bin`.

- `scripts/install_terraform.sh`
  - Uses HashiCorp `index.json` + `jq` to determine latest compatible version.
  - Installs binary into `$HOME/bin` and appends PATH export to `~/.bashrc`.

- `scripts/install_velero.sh`
  - Queries GitHub API for latest tag.
  - Downloads release tarball and installs to `/usr/local/bin`.

- `scripts/install_docker.sh`
  - Ubuntu-oriented apt repository setup.
  - Installs Docker Engine + Compose plugin and enables service with systemd.

## Observations

- The project is intentionally simple and script-driven (no package manager wrapper).
- Most installers target "latest" versions instead of pinned versions.
- `main.sh` is generic and extensible: adding `scripts/install_newtool.sh` automatically surfaces in help and `--all` behavior.
- There is currently no substantive automated test coverage in `test/main.bats`.
