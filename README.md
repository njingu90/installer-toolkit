#  🚀 Installer Toolkit
Simple Bash installer for dev tools

[![Lint & Test](https://github.com/njingu90/installer-toolkit/actions/workflows/lint-and-test.yml/badge.svg)](https://github.com/njingu90/installer-toolkit/actions/workflows/lint-and-test.yml) 
[![License: MIT](https://img.shields.io/badge/License-MIT-yellow.svg)](LICENSE)

> A simple, reliable toolkit to install the latest versions of popular developer and DevOps tools.

## 💡 Supported tools

* AWS CLI (`awscli`)
* kubectl (`kubectl`)
* eksctl (`eksctl`)
* Terraform (`terraform`)
* Velero (`velero`)
* Docker & Docker Compose (`docker`)

## ⚙️ Prerequisites

* Linux (Ubuntu/Debian) or macOS
* `bash` shell
* `sudo` access
* `fzf` (optional, for interactive selection)

## 🚀 Quick Start

```bash
# Clone the repository
git clone https://github.com/njingu90/installer-toolkit.git
cd installer-toolkit
chmod +x main.sh

# Install all tools
./main.sh --all

# Or install specific tools
./main.sh awscli terraform

# Or use interactive selection
./main.sh
```

## 📚 Usage Options

1. **Install all tools**:
   ```bash
   ./main.sh --all
   ```

2. **Install specific tools**:
   ```bash
   ./main.sh awscli terraform docker
   ```

3. **Interactive selection**:
   ```bash
   ./main.sh
   ```

4. **Show help**:
   ```bash
   ./main.sh help
   ```

## 🗂️ Project Structure

```
installer-toolkit/
├── scripts/
│   ├── install_awscli.sh
│   ├── install_docker.sh
│   ├── install_eksctl.sh
│   ├── install_kubectl.sh
│   ├── install_terraform.sh
│   └── install_velero.sh
├── main.sh
└── README.md
```

## ⚡ Automatic Installation

For automated installation (e.g., EC2 User Data):

```bash
#!/usr/bin/env bash
set -euo pipefail
LOG_DIR="/var/log/toolkit-install"
LOG_FILE="$LOG_DIR/install.log"
sudo mkdir -p "$LOG_DIR"

{
  echo "====== System update & prerequisites ======"
  sudo apt update -y && sudo apt upgrade -y
  sudo apt install -y git curl unzip

  echo "====== Installing toolkit ======"
  git clone https://github.com/njingu90/installer-toolkit.git
  cd installer-toolkit
  chmod +x main.sh
  ./main.sh --all

} 2>&1 | sudo tee "$LOG_FILE"
```

## 🔍 Troubleshooting

* Check logs at `/var/log/toolkit-install/install.log` for automated installations
* Run `./main.sh help` to see available tools
* Ensure you have sudo access
* For Docker issues on Linux, logout and login again after installation

## 📄 License

MIT License - feel free to use and modify

