#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
# shellcheck source=tests/incus-common.sh
source "$SCRIPT_DIR/incus-common.sh"

DISTRO="${DISTRO:?DISTRO is required}"
IMAGE="${IMAGE:?IMAGE is required}"
INSTALL_TOOLS_ARGS="${INSTALL_TOOLS_ARGS:-}"
TEST_ROOT="${TEST_ROOT:-$(cd "$SCRIPT_DIR/.." && pwd)}"

SNAPSHOT_NAME="prereq-ready"
VM_NAME_PREFIX="dotfiles-test-${DISTRO}"
VM_LOG_DIR="/home/ci/test-logs"
VM_REPO_DIR="/home/ci/.local/share/chezmoi"

require_incus
build_vm_filters "$DISTRO" "$IMAGE"
matching_vms="$(find_matching_vms)"
match_count="$(count_lines_or_zero "$matching_vms")"

if [[ "$match_count" -gt 1 ]]; then
  echo "[incus-test] multiple cached VMs match ${DISTRO}/${IMAGE}; refusing to continue:" >&2
  print_vm_list_indented "$matching_vms"
  exit 1
fi

install_prereqs() {
  local target_vm="$1"
  incus exec "$target_vm" -- bash -lc '
    set -euo pipefail

    if command -v apt-get >/dev/null 2>&1; then
      apt-get update
      DEBIAN_FRONTEND=noninteractive apt-get install -y curl git python3 python3-pip python3-venv pipx sudo ca-certificates
    elif command -v dnf >/dev/null 2>&1; then
      dnf -y install curl git python3 python3-pip pipx sudo ca-certificates shadow-utils
    elif command -v pacman >/dev/null 2>&1; then
      pacman -Sy --noconfirm curl git python python-pip sudo ca-certificates
      python -m pip install --break-system-packages pipx
    elif command -v zypper >/dev/null 2>&1; then
      zypper --non-interactive install -y curl git python3 python3-pip sudo ca-certificates shadow
      python3 -m pip install --break-system-packages pipx
    else
      echo "Unsupported package manager in VM" >&2
      exit 1
    fi

    useradd --create-home --shell /bin/bash ci || true
    usermod -aG sudo ci || true
    echo "ci ALL=(ALL) NOPASSWD:ALL" >/etc/sudoers.d/ci
    chmod 0440 /etc/sudoers.d/ci
  '
}

if [[ "$match_count" -eq 0 ]]; then
  vm_name="${VM_NAME_PREFIX}-$(date +%s)"
  echo "[incus-test] creating cached VM: $vm_name"
  incus launch "$IMAGE" "$vm_name" \
    -c user.dotfiles.test=true \
    -c user.dotfiles.test-suite=install-tools \
    -c user.dotfiles.test-distro="$DISTRO" \
    -c user.dotfiles.test-image="$IMAGE"
  echo "[incus-test] installing prerequisite packages"
  install_prereqs "$vm_name"
  echo "[incus-test] creating snapshot: $SNAPSHOT_NAME"
  incus snapshot create "$vm_name" "$SNAPSHOT_NAME" --reuse
else
  vm_name="$(printf '%s\n' "$matching_vms" | head -n1)"
  echo "[incus-test] reusing cached VM: $vm_name"
  if ! incus snapshot list "$vm_name" -f csv -c n | grep -Fxq "$SNAPSHOT_NAME"; then
    echo "[incus-test] snapshot $SNAPSHOT_NAME not found on existing VM $vm_name; refusing to continue." >&2
    exit 1
  fi

  echo "[incus-test] restoring snapshot: $SNAPSHOT_NAME"
  incus stop "$vm_name" --force >/dev/null 2>&1 || true
  incus snapshot restore "$vm_name" "$SNAPSHOT_NAME"
  incus start "$vm_name"
fi

echo "[incus-test] preparing source tree"
incus exec "$vm_name" -- rm -rf "$VM_REPO_DIR" "$VM_LOG_DIR"
incus exec "$vm_name" -- mkdir -p "$VM_REPO_DIR" "$VM_LOG_DIR"
tar -C "$TEST_ROOT" -cf - . | incus exec "$vm_name" -- tar -C "$VM_REPO_DIR" -xf -
incus exec "$vm_name" -- mkdir -p /home/ci/.local/bin /home/ci/.local/share
incus exec "$vm_name" -- chown -R ci:ci /home/ci/.local "$VM_REPO_DIR" "$VM_LOG_DIR"

install_cmd=(./tests/test-install-tools.sh)
if [[ -n "$INSTALL_TOOLS_ARGS" ]]; then
  # shellcheck disable=SC2206
  install_tools_args_array=($INSTALL_TOOLS_ARGS)
  install_cmd+=("${install_tools_args_array[@]}")
fi
printf -v install_cmd_quoted '%q ' "${install_cmd[@]}"

echo "[incus-test] running install-tools test"
set +e
incus exec "$vm_name" -- sudo -u ci bash -lc '
  set -euo pipefail
  export GITHUB_WORKSPACE='"$VM_REPO_DIR"'
  cd '"$VM_REPO_DIR"'
  TEST_LOG_DIR='"$VM_LOG_DIR"' '"$install_cmd_quoted"'
'
test_rc=$?
set -e

if [[ "$test_rc" -ne 0 ]]; then
  echo "[incus-test] test failed in VM: $vm_name" >&2
  echo "[incus-test] inspect logs in VM path: $VM_LOG_DIR" >&2
  exit "$test_rc"
fi

echo "[incus-test] test completed successfully"
