#!/usr/bin/env bats

setup() {
  REPO_ROOT="$(cd "${BATS_TEST_DIRNAME}/.." && pwd)"
  TMP_ROOT="$(mktemp -d)"
  WORKDIR="${TMP_ROOT}/repo"

  mkdir -p "$WORKDIR/lib" "$WORKDIR/scripts" "$TMP_ROOT/bin"
  cp "${REPO_ROOT}/main.sh" "$WORKDIR/main.sh"
  cp "${REPO_ROOT}/lib/common.sh" "$WORKDIR/lib/common.sh"
  cp "${REPO_ROOT}/lib/tools.sh" "$WORKDIR/lib/tools.sh"

  chmod +x "$WORKDIR/main.sh"
  chmod +x "$WORKDIR/lib/common.sh" "$WORKDIR/lib/tools.sh"

  export PATH="${TMP_ROOT}/bin:/usr/bin:/bin"
}

teardown() {
  rm -rf "$TMP_ROOT"
}

create_fake_cmd() {
  local name="$1"
  cat > "${TMP_ROOT}/bin/${name}" <<FAKE
#!/usr/bin/env bash
exit 0
FAKE
  chmod +x "${TMP_ROOT}/bin/${name}"
}

create_installer() {
  local tool="$1"
  local action="$2"
  cat > "${WORKDIR}/scripts/install_${tool}.sh" <<SCRIPT
#!/usr/bin/env bash
set -euo pipefail
${action}
SCRIPT
  chmod +x "${WORKDIR}/scripts/install_${tool}.sh"
}

@test "help prints usage" {
  run "$WORKDIR/main.sh" --help
  [ "$status" -eq 0 ]
  [[ "$output" == *"Usage:"* ]]
  [[ "$output" == *"--all"* ]]
}

@test "calling without --all fails with clear error" {
  run "$WORKDIR/main.sh"
  [ "$status" -eq 1 ]
  [[ "$output" == *"This script only supports the --all flag"* ]]
}

@test "--all skips tools that are already installed" {
  for tool_cmd in aws kubectl eksctl terraform velero docker; do
    create_fake_cmd "$tool_cmd"
  done

  for tool in awscli kubectl eksctl terraform velero docker; do
    create_installer "$tool" "echo should_not_run >> ${TMP_ROOT}/unexpected"
  done

  run "$WORKDIR/main.sh" --all
  [ "$status" -eq 0 ]
  [[ "$output" == *"awscli is already installed; skipping"* ]]
  [[ "$output" == *"docker is already installed; skipping"* ]]
  [ ! -f "${TMP_ROOT}/unexpected" ]
}

@test "--all installs missing tool and writes log file" {
  # Make every tool except velero appear installed.
  for tool_cmd in aws kubectl eksctl terraform docker; do
    create_fake_cmd "$tool_cmd"
  done

  create_installer awscli "echo should_not_run >> ${TMP_ROOT}/unexpected"
  create_installer kubectl "echo should_not_run >> ${TMP_ROOT}/unexpected"
  create_installer eksctl "echo should_not_run >> ${TMP_ROOT}/unexpected"
  create_installer terraform "echo should_not_run >> ${TMP_ROOT}/unexpected"
  create_installer docker "echo should_not_run >> ${TMP_ROOT}/unexpected"
  create_installer velero "echo velero_installed > ${TMP_ROOT}/velero-installed"

  run "$WORKDIR/main.sh" --all
  [ "$status" -eq 0 ]
  [ -f "${TMP_ROOT}/velero-installed" ]
  [ ! -f "${TMP_ROOT}/unexpected" ]
  [ -f "/tmp/installer-toolkit.txt" ]
  run grep -q "Starting installer-toolkit with --all" /tmp/installer-toolkit.txt
  [ "$status" -eq 0 ]
}
