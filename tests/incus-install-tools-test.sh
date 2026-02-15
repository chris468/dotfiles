#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
# shellcheck source=tests/incus-common.sh
source "$SCRIPT_DIR/incus-common.sh"

DISTRO="${DISTRO:?DISTRO is required}"
DISTRO_VERSION="${DISTRO_VERSION:-}"
IMAGE="${IMAGE:?IMAGE is required}"
INSTALL_TOOLS_ARGS="${INSTALL_TOOLS_ARGS:-}"
TEST_ROOT="${TEST_ROOT:-$(cd "$SCRIPT_DIR/.." && pwd)}"
TEST_VERBOSE="${TEST_VERBOSE:-0}"

SNAPSHOT_NAME="prereq-ready"
VM_NAME_PREFIX="dotfiles-${DISTRO}"
if [[ -n "$DISTRO_VERSION" ]]; then
  VM_NAME_PREFIX="${VM_NAME_PREFIX}-${DISTRO_VERSION}"
fi
LOG_CONTEXT="${DISTRO}${DISTRO_VERSION:+-$DISTRO_VERSION}"
VM_LOG_DIR="/home/ci/test-logs"
VM_REPO_DIR="/home/ci/.local/share/chezmoi"
HOST_LOG_ROOT="$TEST_ROOT/tests/logs"
vm_name=""

log_info() {
  echo "[incus-test|${LOG_CONTEXT}] $*"
}

log_error() {
  echo "[incus-test|${LOG_CONTEXT}] $*" >&2
}

host_log_dest=""
copy_logs_rc=0
verbose_mode=0

shopt -s nocasematch
case "$TEST_VERBOSE" in
1 | true | yes | on) verbose_mode=1 ;;
*) verbose_mode=0 ;;
esac
shopt -u nocasematch

stop_vm_on_exit() {
  if [[ -n "${vm_name:-}" ]]; then
    incus stop "$vm_name" >/dev/null 2>&1 || true
  fi
}
trap stop_vm_on_exit EXIT

require_incus
build_vm_filters "$DISTRO" "$IMAGE"
matching_vms="$(find_matching_vms)"
match_count="$(count_lines_or_zero "$matching_vms")"

if [[ "$match_count" -gt 1 ]]; then
  log_error "multiple cached VMs match ${DISTRO}/${IMAGE}; refusing to continue:"
  print_vm_list_indented "$matching_vms"
  exit 1
fi

install_prereqs() {
  local target_vm="$1"
  local prereq_log
  local rc=0
  prereq_log="$(mktemp "${TMPDIR:-/tmp}/incus-install-prereqs.XXXXXX.log")"

  if incus exec "$target_vm" -- bash -lc '
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
      zypper --non-interactive install -y curl git python3 python3-pip sudo ca-certificates shadow ncurses-devel
      python3 -m pip install --break-system-packages pipx
    else
      echo "Unsupported package manager in VM" >&2
      exit 1
    fi

    useradd --create-home --shell /bin/bash ci || true
    usermod -aG sudo ci || true
    echo "ci ALL=(ALL) NOPASSWD:ALL" >/etc/sudoers.d/ci
    chmod 0440 /etc/sudoers.d/ci
  ' >"$prereq_log" 2>&1; then
    if [[ "$verbose_mode" -eq 1 ]]; then
      sed "s/^/[incus-test|${LOG_CONTEXT}] [install-prereqs] /" "$prereq_log"
    fi
  else
    rc=$?
    log_error "install prerequisite step failed in VM: $target_vm"
    if [[ -s "$prereq_log" ]]; then
      sed "s/^/[incus-test|${LOG_CONTEXT}] [install-prereqs] /" "$prereq_log" >&2
    fi
    rm -f "$prereq_log"
    return "$rc"
  fi

  rm -f "$prereq_log"
}

wait_for_cloud_init() {
  local target_vm="$1"
  local attempt
  local max_attempts=60
  local cloud_init_log
  local cloud_init_rc
  log_info "waiting for cloud-init in VM: $target_vm"
  for attempt in $(seq 1 "$max_attempts"); do
    log_info "cloud-init check attempt ${attempt}/${max_attempts} for VM: $target_vm"
    if cloud_init_log="$(incus exec "$target_vm" -- bash -lc '
      set -euo pipefail
      if command -v cloud-init >/dev/null 2>&1; then
        cloud-init status --wait
      else
        echo "cloud-init is not installed; skipping wait"
      fi
    ' 2>&1)"; then
      cloud_init_rc=0
    else
      cloud_init_rc=$?
    fi
    log_info "cloud-init check exit code for VM $target_vm: $cloud_init_rc"
    if [[ $cloud_init_rc -eq 0 || $cloud_init_rc -eq 2 ]]; then
      if [[ -n "$cloud_init_log" ]]; then
        echo "$cloud_init_log" | sed "s/^/[incus-test|${LOG_CONTEXT}]   /"
      fi
      log_info "cloud-init ready in VM: $target_vm (exit=$cloud_init_rc)"
      return
    fi
    log_error "cloud-init not ready yet for VM: $target_vm (exit=$cloud_init_rc)"
    if [[ -n "$cloud_init_log" ]]; then
      echo "$cloud_init_log" | sed "s/^/[incus-test|${LOG_CONTEXT}]   /" >&2
    fi
    sleep 2
  done
  log_error "cloud-init did not complete in time after ${max_attempts} attempts for VM: $target_vm"
  exit 1
}

wait_for_dns() {
  local target_vm="$1"
  local dns_name="${2:-api.github.com}"
  local attempt
  local max_attempts=60
  local dns_log
  local dns_rc

  log_info "waiting for DNS in VM: $target_vm (name=$dns_name)"
  for attempt in $(seq 1 "$max_attempts"); do
    log_info "DNS check attempt ${attempt}/${max_attempts} for VM: $target_vm (name=$dns_name)"
    if dns_log="$(incus exec "$target_vm" -- bash -lc '
      set -euo pipefail
      getent hosts "'"$dns_name"'"
    ' 2>&1)"; then
      dns_rc=0
    else
      dns_rc=$?
    fi

    log_info "DNS check exit code for VM $target_vm: $dns_rc"
    if [[ -n "$dns_log" ]]; then
      echo "$dns_log" | sed "s/^/[incus-test|${LOG_CONTEXT}]   /"
    fi
    if [[ "$dns_rc" -eq 0 ]]; then
      log_info "DNS ready in VM: $target_vm (name=$dns_name)"
      return
    fi

    log_error "DNS not ready yet for VM: $target_vm (name=$dns_name)"
    sleep 2
  done

  log_error "DNS did not become ready in time after ${max_attempts} attempts for VM: $target_vm (name=$dns_name)"
  exit 1
}

create_cached_vm() {
  for _ in $(seq 1 10); do
    vm_hash="$(tr -dc 'a-f0-9' </dev/urandom | head -c 4 || true)"
    if [[ ${#vm_hash} -ne 4 ]]; then
      continue
    fi
    candidate_name="${VM_NAME_PREFIX}-${vm_hash}"
    if ! incus info "$candidate_name" >/dev/null 2>&1; then
      vm_name="$candidate_name"
      break
    fi
  done
  if [[ -z "$vm_name" ]]; then
    log_error "could not generate unique VM name for prefix: $VM_NAME_PREFIX"
    exit 1
  fi
  log_info "creating cached VM: $vm_name"
  incus launch "$IMAGE" "$vm_name" \
    -c user.dotfiles.test=true \
    -c user.dotfiles.test-suite=install-tools \
    -c user.dotfiles.test-distro="$DISTRO" \
    -c user.dotfiles.test-image="$IMAGE"
  wait_for_cloud_init "$vm_name"
  log_info "installing prerequisite packages"
  install_prereqs "$vm_name"
  log_info "creating snapshot: $SNAPSHOT_NAME"
  incus snapshot create "$vm_name" "$SNAPSHOT_NAME" --reuse
}

build_host_log_base() {
  local base="$1"
  base="${base#dotfiles-}"
  base="$(printf '%s' "$base" | sed -E 's/-[a-f0-9]{4}$//')"
  if [[ -z "$base" ]]; then
    base="vm"
  fi
  printf '%s' "$base"
}

copy_logs_from_vm() {
  local base_name timestamp
  mkdir -p "$HOST_LOG_ROOT"
  base_name="$(build_host_log_base "$vm_name")"
  timestamp="$(date '+%Y%m%d_%H%M%S')"
  host_log_dest="$HOST_LOG_ROOT/${base_name}-${timestamp}"
  mkdir -p "$host_log_dest"

  if ! incus exec "$vm_name" -- test -d "$VM_LOG_DIR"; then
    log_error "VM log directory not found: $VM_LOG_DIR"
    return 1
  fi

  if ! incus exec "$vm_name" -- tar -C "$VM_LOG_DIR" -cf - . | tar -C "$host_log_dest" -xf -; then
    log_error "failed to copy logs from VM path $VM_LOG_DIR to $host_log_dest"
    return 1
  fi

  log_info "copied VM logs to: $host_log_dest"
}

if [[ "$match_count" -eq 0 ]]; then
  create_cached_vm
else
  vm_name="$(printf '%s\n' "$matching_vms" | head -n1)"
  log_info "reusing cached VM: $vm_name"
  if ! incus snapshot list "$vm_name" -f csv -c n | grep -Fxq "$SNAPSHOT_NAME"; then
    log_error "snapshot $SNAPSHOT_NAME not found on existing VM $vm_name; recreating VM."
    incus stop "$vm_name" --force >/dev/null 2>&1 || true
    incus delete "$vm_name"
    vm_name=""
    create_cached_vm
  else
    log_info "restoring snapshot: $SNAPSHOT_NAME"
    incus stop "$vm_name" --force >/dev/null 2>&1 || true
    incus snapshot restore "$vm_name" "$SNAPSHOT_NAME"
    incus start "$vm_name"
    wait_for_dns "$vm_name"
  fi
fi

log_info "preparing source tree"
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

log_info "running install-tools test"
set +e
incus exec "$vm_name" -- sudo -u ci bash -lc '
  set -euo pipefail
  export GITHUB_WORKSPACE='"$VM_REPO_DIR"'
  cd '"$VM_REPO_DIR"'
  TEST_LOG_DIR='"$VM_LOG_DIR"' TEST_VERBOSE='"$TEST_VERBOSE"' TEST_LOG_PREFIX=incus-test TEST_LOG_CONTEXT='"$LOG_CONTEXT"' '"$install_cmd_quoted"'
'
test_rc=$?
set -e

if copy_logs_from_vm; then
  copy_logs_rc=0
else
  copy_logs_rc=$?
fi

if [[ "$test_rc" -ne 0 ]]; then
  log_error "test failed in VM: $vm_name"
  if [[ "$copy_logs_rc" -ne 0 ]]; then
    log_error "failed to copy logs to host; inspect logs in VM path: $VM_LOG_DIR"
  else
    log_error "copied logs to host path: $host_log_dest"
  fi
  exit "$test_rc"
fi

if [[ "$copy_logs_rc" -ne 0 ]]; then
  log_error "test passed but failed to copy logs from VM path: $VM_LOG_DIR"
  exit "$copy_logs_rc"
fi

log_info "test completed successfully"
