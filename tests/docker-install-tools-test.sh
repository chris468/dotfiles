#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
# shellcheck source=tests/linux-test-common.sh
source "$SCRIPT_DIR/linux-test-common.sh"

DISTRO="${DISTRO:?DISTRO is required}"
DISTRO_VERSION="${DISTRO_VERSION:-}"
IMAGE="${IMAGE:?IMAGE is required}"
INSTALL_TOOLS_ARGS="${INSTALL_TOOLS_ARGS:-}"
TEST_ROOT="${TEST_ROOT:-$(cd "$SCRIPT_DIR/.." && pwd)}"
TEST_VERBOSE="${TEST_VERBOSE:-0}"

LOG_CONTEXT="${DISTRO}${DISTRO_VERSION:+-$DISTRO_VERSION}"
LOG_PREFIX="docker-test"
CONTAINER_NAME_PREFIX="dotfiles-${DISTRO}"
if [[ -n "$DISTRO_VERSION" ]]; then
  CONTAINER_NAME_PREFIX="${CONTAINER_NAME_PREFIX}-${DISTRO_VERSION}"
fi

CONTAINER_CLI="${CONTAINER_CLI:-}"
VM_LOG_DIR="/home/ci/test-logs"
VM_REPO_DIR="/home/ci/.local/share/chezmoi"
HOST_LOG_ROOT="$TEST_ROOT/tests/logs"
container_name=""
host_log_dest=""
copy_logs_rc=0
verbose_mode=0

parse_verbose_mode "$TEST_VERBOSE"

log_info() {
  echo "[${LOG_PREFIX}|${LOG_CONTEXT}] $*"
}

log_error() {
  echo "[${LOG_PREFIX}|${LOG_CONTEXT}] $*" >&2
}

detect_container_cli() {
  if [[ -n "$CONTAINER_CLI" ]]; then
    if command -v "$CONTAINER_CLI" >/dev/null 2>&1; then
      return 0
    fi
    log_error "container CLI not found: $CONTAINER_CLI"
    exit 1
  fi

  if command -v docker >/dev/null 2>&1; then
    CONTAINER_CLI="docker"
    return 0
  fi

  if command -v podman >/dev/null 2>&1; then
    CONTAINER_CLI="podman"
    return 0
  fi

  log_error "docker or podman is required for Linux container tests"
  exit 1
}

container_exec() {
  local target="$1"
  local script="$2"
  "$CONTAINER_CLI" exec "$target" bash -lc "$script"
}

cleanup_container() {
  if [[ -n "${container_name:-}" ]]; then
    "$CONTAINER_CLI" rm -f "$container_name" >/dev/null 2>&1 || true
  fi
}
trap cleanup_container EXIT

build_container_name() {
  local attempt hash candidate
  for attempt in $(seq 1 10); do
    hash="$(tr -dc 'a-f0-9' </dev/urandom | head -c 4 || true)"
    if [[ ${#hash} -ne 4 ]]; then
      continue
    fi
    candidate="${CONTAINER_NAME_PREFIX}-${hash}"
    if ! "$CONTAINER_CLI" ps -a --format '{{.Names}}' | grep -Fxq "$candidate"; then
      container_name="$candidate"
      return 0
    fi
  done
  log_error "could not generate unique container name for prefix: $CONTAINER_NAME_PREFIX"
  exit 1
}

build_host_log_base() {
  local base="$1"
  base="${base#dotfiles-}"
  base="$(printf '%s' "$base" | sed -E 's/-[a-f0-9]{4}$//')"
  if [[ -z "$base" ]]; then
    base="container"
  fi
  printf '%s' "$base"
}

copy_logs_from_container() {
  local base_name timestamp
  mkdir -p "$HOST_LOG_ROOT"
  base_name="$(build_host_log_base "$container_name")"
  timestamp="$(date '+%Y%m%d_%H%M%S')"
  host_log_dest="$HOST_LOG_ROOT/${base_name}-${timestamp}"
  mkdir -p "$host_log_dest"

  if ! "$CONTAINER_CLI" exec "$container_name" test -d "$VM_LOG_DIR"; then
    log_error "container log directory not found: $VM_LOG_DIR"
    return 1
  fi

  if ! "$CONTAINER_CLI" cp "$container_name:$VM_LOG_DIR/." "$host_log_dest"; then
    log_error "failed to copy logs from container path $VM_LOG_DIR to $host_log_dest"
    return 1
  fi

  log_info "copied container logs to: $host_log_dest"
}

detect_container_cli
build_container_name

log_info "pulling image: $IMAGE"
"$CONTAINER_CLI" pull "$IMAGE" >/dev/null 2>&1 || true

log_info "starting container: $container_name"
"$CONTAINER_CLI" run -d --name "$container_name" --hostname "$container_name" --entrypoint bash "$IMAGE" -lc "sleep infinity" >/dev/null

log_info "installing prerequisite packages"
run_prereqs container_exec "$container_name" "$LOG_CONTEXT" "$LOG_PREFIX"

log_info "preparing source tree"
container_exec "$container_name" "rm -rf '$VM_REPO_DIR' '$VM_LOG_DIR'"
container_exec "$container_name" "mkdir -p '$VM_REPO_DIR' '$VM_LOG_DIR' /home/ci/.local/bin /home/ci/.local/share"
"$CONTAINER_CLI" cp "$TEST_ROOT/." "$container_name:$VM_REPO_DIR"
container_exec "$container_name" "chown -R ci:ci /home/ci/.local '$VM_REPO_DIR' '$VM_LOG_DIR'"

install_cmd=(./tests/test-install-tools.sh)
if [[ -n "$INSTALL_TOOLS_ARGS" ]]; then
  # shellcheck disable=SC2206
  install_tools_args_array=($INSTALL_TOOLS_ARGS)
  install_cmd+=("${install_tools_args_array[@]}")
fi
printf -v install_cmd_quoted '%q ' "${install_cmd[@]}"

log_info "running install-tools test"
set +e
"$CONTAINER_CLI" exec -u ci "$container_name" bash -lc '
  set -euo pipefail
  export GITHUB_WORKSPACE='"$VM_REPO_DIR"'
  cd '"$VM_REPO_DIR"'
  TEST_LOG_DIR='"$VM_LOG_DIR"' TEST_VERBOSE='"$TEST_VERBOSE"' TEST_LOG_PREFIX='"$LOG_PREFIX"' TEST_LOG_CONTEXT='"$LOG_CONTEXT"' '"$install_cmd_quoted"'
'
test_rc=$?
set -e

if copy_logs_from_container; then
  copy_logs_rc=0
else
  copy_logs_rc=$?
fi

if [[ "$test_rc" -ne 0 ]]; then
  log_error "test failed in container: $container_name"
  if [[ "$copy_logs_rc" -ne 0 ]]; then
    log_error "failed to copy logs to host; inspect logs in container path: $VM_LOG_DIR"
  else
    log_error "copied logs to host path: $host_log_dest"
  fi
  exit "$test_rc"
fi

if [[ "$copy_logs_rc" -ne 0 ]]; then
  log_error "test passed but failed to copy logs from container path: $VM_LOG_DIR"
  exit "$copy_logs_rc"
fi

log_info "test completed successfully"
