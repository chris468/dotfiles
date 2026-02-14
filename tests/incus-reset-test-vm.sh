#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
# shellcheck source=tests/incus-common.sh
source "$SCRIPT_DIR/incus-common.sh"

DISTRO="${DISTRO:?DISTRO is required}"
IMAGE="${IMAGE:?IMAGE is required}"

require_incus
build_vm_filters "$DISTRO" "$IMAGE"
matching_vms="$(find_matching_vms)"
match_count="$(count_lines_or_zero "$matching_vms")"

if [[ "$match_count" -gt 1 ]]; then
  echo "[incus-reset] multiple cached VMs match ${DISTRO}/${IMAGE}; refusing to delete:" >&2
  print_vm_list_indented "$matching_vms"
  exit 1
fi

if [[ "$match_count" -eq 0 ]]; then
  echo "[incus-reset] no cached VM found for ${DISTRO}/${IMAGE}."
  exit 0
fi

vm_name="$(printf '%s\n' "$matching_vms" | head -n1)"
echo "[incus-reset] deleting cached VM: $vm_name"
incus delete -f "$vm_name"
