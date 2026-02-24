#!/usr/bin/env bash
set -euo pipefail

parse_verbose_mode() {
  local value="${1:-0}"
  shopt -s nocasematch
  case "$value" in
  1 | true | yes | on) verbose_mode=1 ;;
  *) verbose_mode=0 ;;
  esac
  shopt -u nocasematch
}

linux_prereqs_script() {
  cat <<'EOF'
set -euo pipefail

if command -v apt-get >/dev/null 2>&1; then
  apt-get update
  DEBIAN_FRONTEND=noninteractive apt-get install -y curl git python3 python3-pip python3-venv pipx sudo ca-certificates
elif command -v dnf >/dev/null 2>&1; then
  dnf -y install curl git python3 python3-pip pipx sudo ca-certificates shadow-utils nix-daemon
elif command -v pacman >/dev/null 2>&1; then
  pacman -Sy --noconfirm curl git python python-pipx sudo ca-certificates
elif command -v zypper >/dev/null 2>&1; then
  zypper --non-interactive install -y curl git python3 python3-pipx sudo ca-certificates shadow ncurses-devel
else
  echo "Unsupported package manager in Linux target" >&2
  exit 1
fi

useradd --create-home --shell /bin/bash ci || true
usermod -aG sudo ci || true
echo "ci ALL=(ALL) NOPASSWD:ALL" >/etc/sudoers.d/ci
chmod 0440 /etc/sudoers.d/ci
EOF
}

run_prereqs() {
  local exec_fn="$1"
  local target="$2"
  local log_context="$3"
  local log_prefix="$4"
  local prereq_log
  local rc=0
  local script

  prereq_log="$(mktemp "${TMPDIR:-/tmp}/linux-install-prereqs.XXXXXX.log")"
  script="$(linux_prereqs_script)"

  if "$exec_fn" "$target" "$script" >"$prereq_log" 2>&1; then
    if [[ "$verbose_mode" -eq 1 ]]; then
      sed "s/^/[${log_prefix}|${log_context}] [install-prereqs] /" "$prereq_log"
    fi
  else
    rc=$?
    echo "[${log_prefix}|${log_context}] install prerequisite step failed in target: $target" >&2
    if [[ -s "$prereq_log" ]]; then
      sed "s/^/[${log_prefix}|${log_context}] [install-prereqs] /" "$prereq_log" >&2
    fi
    rm -f "$prereq_log"
    return "$rc"
  fi

  rm -f "$prereq_log"
}
