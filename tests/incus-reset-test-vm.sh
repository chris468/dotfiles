#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
# shellcheck source=tests/incus-common.sh
source "$SCRIPT_DIR/incus-common.sh"

DISTRO="${DISTRO:?DISTRO is required}"
DISTRO_VERSION="${DISTRO_VERSION:-}"
IMAGE="${IMAGE:?IMAGE is required}"
LOG_CONTEXT="${DISTRO}${DISTRO_VERSION:+-$DISTRO_VERSION}"

log_info() {
  echo "[incus-reset|${LOG_CONTEXT}] $*"
}

log_error() {
  echo "[incus-reset|${LOG_CONTEXT}] $*" >&2
}

require_incus
build_vm_filters "$DISTRO" "$IMAGE"
matching_vms="$(find_matching_vms)"
match_count="$(count_lines_or_zero "$matching_vms")"

if [[ "$match_count" -gt 1 ]]; then
  log_error "multiple cached VMs match ${DISTRO}/${IMAGE}; refusing to delete:"
  print_vm_list_indented "$matching_vms"
  exit 1
fi

if [[ "$match_count" -eq 0 ]]; then
  log_info "no cached VM found for ${DISTRO}/${IMAGE}."
  exit 0
fi

vm_name="$(printf '%s\n' "$matching_vms" | head -n1)"
log_info "deleting cached VM: $vm_name"
incus delete -f "$vm_name"
