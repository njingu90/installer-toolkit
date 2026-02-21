#!/usr/bin/env bash

# shellcheck disable=SC2034 # Referenced by main.sh after sourcing this file.
TOOLS=(awscli kubectl eksctl terraform velero docker)

installer_for() {
  local tool="$1"
  echo "${SCRIPTS_DIR}/install_${tool}.sh"
}

is_installed() {
  local tool="$1"

  case "$tool" in
    awscli)
      command -v aws >/dev/null 2>&1
      ;;
    kubectl)
      command -v kubectl >/dev/null 2>&1
      ;;
    eksctl)
      command -v eksctl >/dev/null 2>&1
      ;;
    terraform)
      command -v terraform >/dev/null 2>&1 || [[ -x "${HOME}/bin/terraform" ]]
      ;;
    velero)
      command -v velero >/dev/null 2>&1
      ;;
    docker)
      command -v docker >/dev/null 2>&1
      ;;
    *)
      return 1
      ;;
  esac
}
