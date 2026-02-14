#!/usr/bin/env bash
set -euo pipefail

require_incus() {
  if ! command -v incus >/dev/null 2>&1; then
    echo "incus is required for Linux VM tests" >&2
    exit 1
  fi
}

build_vm_filters() {
  local distro="$1"
  local image="$2"
  VM_FILTER=(
    "user.dotfiles.test-suite=install-tools"
    "user.dotfiles.test-distro=${distro}"
    "user.dotfiles.test-image=${image}"
  )
}

find_matching_vms() {
  local raw
  raw="$(incus list -f csv -c n "${VM_FILTER[@]}" | sed '/^$/d')"
  printf '%s' "$raw"
}

count_lines_or_zero() {
  local value="$1"
  if [[ -n "$value" ]]; then
    printf '%s\n' "$value" | wc -l | tr -d ' '
  else
    echo 0
  fi
}

print_vm_list_indented() {
  local value="$1"
  printf '%s\n' "$value" | sed 's/^/  /' >&2
}
