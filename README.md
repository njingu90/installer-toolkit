#  🚀 Installer Toolkit
Simple Bash installer for dev tools
````markdown
# Multi-Installer CLI

[![Lint & Test](https://github.com/owner/repo/actions/workflows/lint-and-test.yml/badge.svg)](https://github.com/owner/repo/actions/workflows/lint-and-test.yml)  
[![License: MIT](https://img.shields.io/badge/License-MIT-yellow.svg)](LICENSE)  

> This repository provides simple, clean, and reliable shell scripts to install the **latest version** of popular developer and DevOps tools.

---

Sure! Here’s a clean, well-structured **README.md** file you can drop directly into your repo to explain how to use your installer toolkit.

---

---

## 💡 Supported tools

* AWS CLI
* kubectl
* eksctl
* Terraform
* Velero
* Docker & Docker Compose

---

## ⚙️ Prerequisites

* Linux (Ubuntu preferred) or macOS (some scripts, like Docker, are Linux-focused).
* `bash` shell.
* `sudo` access for installing system binaries.
* [fzf](https://github.com/junegunn/fzf) (optional, for interactive tool selection).

---

## 🚀 Usage

### Clone this repository

```bash
git clone https://github.com/njingu90/installer-toolkit.git
cd installer-toolkit
```

---

### Run the main installer script

#### 📄 Show help

```bash
./main.sh help
```

---

#### ⚡ Install specific tools

```bash
./main.sh awscli terraform docker
```

This will install the **latest version** of each specified tool.

---

#### ✨ Interactive selection (if `fzf` is installed)

```bash
./main.sh
```

* You will be presented with an interactive list.
* Use `TAB` to select multiple tools and `ENTER` to confirm.

---

## 🗂️ Project structure

```
scripts/
├── install_awscli.sh
├── install_docker.sh
├── install_eksctl.sh
├── install_kubectl.sh
├── install_terraform.sh
├── install_velero.sh
main.sh
README.md
```

* **scripts/**: Contains individual install scripts (one per tool).
* **main.sh**: Main entry point that manages tool selection and execution.

---

## ✅ How it works

* Each `install_*.sh` script is designed to always download and install the **latest** official release for its tool.
* No manual version configuration needed.
* Each script logs progress clearly and exits on failure.

---

## 💬 Notes

* On Linux, these scripts may add or update system binaries in `/usr/local/bin`, so `sudo` is required.
* You may need to restart your shell session or run `source ~/.bashrc` after installing certain tools.

---

## ⭐ Contributing

Contributions and improvements are welcome! Feel free to open issues or PRs.

---

## 📄 License

This project is licensed under the [MIT License](LICENSE).

