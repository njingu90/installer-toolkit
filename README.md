# 🚀 Installer Toolkit
Simple Bash installer for DevOps tools with a single `--all` workflow.

[![Lint & Test](https://github.com/njingu90/installer-toolkit/actions/workflows/lint-and-test.yml/badge.svg)](https://github.com/njingu90/installer-toolkit/actions/workflows/lint-and-test.yml)
[![License: MIT](https://img.shields.io/badge/License-MIT-yellow.svg)](LICENSE)

> Install common tools only when missing, and capture logs in `/tmp/installer-toolkit.txt`.

## 💡 Supported tools

* AWS CLI (`awscli`)
* kubectl (`kubectl`)
* eksctl (`eksctl`)
* Terraform (`terraform`)
* Velero (`velero`)
* Docker (`docker`)

## ⚙️ Prerequisites

* Linux (Ubuntu/Debian) or macOS
* `bash` shell
* `sudo` access
* `git`, `curl`, `jq`, and `unzip` available

## 🚀 Quick Start

### Option 1: one-liner (recommended)

```bash
curl -fsSL https://raw.githubusercontent.com/njingu90/installer-toolkit/main/install.sh | bash
```

### Option 2: clone and run

```bash
git clone https://github.com/njingu90/installer-toolkit.git
cd installer-toolkit
chmod +x main.sh scripts/*.sh
./main.sh --all
```

## 📚 Usage

The entrypoint supports **only** one command:

```bash
./main.sh --all
```

Behavior:

1. Checks whether each supported tool is already installed.
2. Installs only missing tools.
3. Logs all output to `/tmp/installer-toolkit.txt`.

## 🗂️ Project Structure

```text
installer-toolkit/
├── lib/
│   ├── common.sh
│   └── tools.sh
├── scripts/
│   ├── install_awscli.sh
│   ├── install_docker.sh
│   ├── install_eksctl.sh
│   ├── install_kubectl.sh
│   ├── install_terraform.sh
│   └── install_velero.sh
├── install.sh
├── main.sh
└── README.md
```

## 🔍 Logs

All runs write logs to:

```text
/tmp/installer-toolkit.txt
```

## 📄 License

MIT License - feel free to use and modify.
