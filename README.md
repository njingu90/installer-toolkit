# installer-toolkit
Simple Bash installer for dev tools
````markdown
# Multi-Installer CLI

[![Lint & Test](https://github.com/owner/repo/actions/workflows/lint-and-test.yml/badge.svg)](https://github.com/owner/repo/actions/workflows/lint-and-test.yml)  
[![License: MIT](https://img.shields.io/badge/License-MIT-yellow.svg)](LICENSE)  

> A simple, pluggable Bash CLI for installing common developer tools with version pinning, automatic “latest” fallback, and optional interactive selection via fzf.

---

## 🚀 Features

- **Modular** — drop any `scripts/install_<tool>.sh` and have it picked up automatically.  
- **Version pinning** via `versions.txt`, with graceful fallback to the latest release.  
- **Interactive mode** — multi-select your tools with [fzf](https://github.com/junegunn/fzf) when you run `./main.sh` with no arguments.  

---

## ⚙️ Prerequisites

- **Bash** 4.0+  
- **curl**, **tar**, **sudo**  
- (Optional) **fzf** for interactive selection  

---

## 🛠️ Installation

```bash
git clone https://github.com/owner/repo.git
cd repo
chmod +x main.sh scripts/*.sh
````

---

## 🔧 Configuration

Create or edit `versions.txt` in the repo root:

```ini
# versions.txt — use LATEST or leave blank to always fetch the newest release
AWSCLI=2.11.16
TERRAFORM=1.4.6
DOCKER=20.10.24
KUBECTL=1.27.3
VELERO=LATEST
```

* Lines beginning with `#` are ignored.
* Lowercase or uppercase tool names both work (`velero` or `VELERO`).

---

## 🎯 Usage

```bash
# Show help
./main.sh help

# Install a single tool
./main.sh velero

# Install multiple tools
./main.sh install terraform awscli kubectl

# Interactive multi-select (requires fzf)
./main.sh
```

---

## ➕ Adding New Tools

1. Create an executable script at `scripts/install_<tool>.sh`.
2. Ensure it accepts a single argument (`$1` = requested version or “LATEST”).
3. Add a line in `versions.txt` with the desired default version.

Example:

```bash
# scripts/install_foo.sh
#!/usr/bin/env bash
set -euo pipefail
VERSION="${1:-LATEST}"
# …fetch and install foo at $VERSION…
```

---

## 🤝 Contributing

See [CONTRIBUTING.md](./CONTRIBUTING.md) for:

* Code style & linting (we use **shellcheck**).
* Branch & PR workflow.
* Issue templates for bugs & feature requests.

All contributions welcome!

---

## 📄 License

This project is licensed under the **MIT License**. See [LICENSE](./LICENSE) for details.

```
```
