#!/usr/bin/env bash
set -euo pipefail

LOG_DIR="${TEST_LOG_DIR:-$(mktemp -d "${TMPDIR:-/tmp}/install-tools.XXXXXX")}"
mkdir -p "$LOG_DIR"

log_prefix="${TEST_LOG_PREFIX:-install-test}"
log_context="${TEST_LOG_CONTEXT:-}"
if [[ -z "$log_context" ]]; then
  log_context="$(uname -s | tr '[:upper:]' '[:lower:]')"
fi

TEST_VERBOSE_VALUE="${TEST_VERBOSE:-0}"
shopt -s nocasematch
case "$TEST_VERBOSE_VALUE" in
1 | true | yes | on) verbose_mode=1 ;;
*) verbose_mode=0 ;;
esac
shopt -u nocasematch

progress() {
  printf '[%s|%s] %s\n' "$log_prefix" "$log_context" "$*"
}

run_and_log() {
  local logfile="$1"
  shift
  : >"$logfile"
  if [[ "$verbose_mode" -eq 1 ]]; then
    "$@" 2>&1 | tee "$logfile"
  else
    "$@" >>"$logfile" 2>&1
  fi
}

cleanup() {
  local rc=$?
  if [[ $rc -ne 0 ]]; then
    printf '[%s|%s] Test failed. Logs are in: %s\n' "$log_prefix" "$log_context" "$LOG_DIR" >&2
  else
    printf '[%s|%s] Test succeeded. Logs are in: %s\n' "$log_prefix" "$log_context" "$LOG_DIR"
  fi
  exit "$rc"
}
trap cleanup EXIT

export XDG_DATA_HOME="${XDG_DATA_HOME:-$HOME/.local/share}"
export PATH="$HOME/.local/bin:$PATH"

mkdir -p "$HOME/.local/bin" "$XDG_DATA_HOME"

normalize_arch() {
  case "$(uname -m)" in
  x86_64) echo "amd64" ;;
  aarch64 | arm64) echo "arm64" ;;
  *)
    echo "Unsupported architecture: $(uname -m)" >&2
    return 1
    ;;
  esac
}

normalize_os() {
  case "$(uname -s)" in
  Linux) echo "linux" ;;
  Darwin) echo "darwin" ;;
  *)
    echo "Unsupported operating system: $(uname -s)" >&2
    return 1
    ;;
  esac
}

install_chezmoi() {
  local api_url="https://api.github.com/repos/twpayne/chezmoi/releases/latest"
  local tag
  tag="$(curl -fsSL "$api_url" | sed -nE 's/.*"tag_name"[[:space:]]*:[[:space:]]*"([^"]+)".*/\1/p' | head -n1)"
  if [[ -z "$tag" ]]; then
    echo "Failed to determine latest chezmoi release" >&2
    return 1
  fi

  local version="${tag#v}"
  local arch
  arch="$(normalize_arch)"
  local os
  os="$(normalize_os)"
  local tarball="chezmoi_${version}_${os}_${arch}.tar.gz"
  local url="https://github.com/twpayne/chezmoi/releases/download/${tag}/${tarball}"

  curl -fsSL "$url" | tar -xzf - -C "$HOME/.local/bin" chezmoi
  chmod +x "$HOME/.local/bin/chezmoi"
}

if command -v chezmoi >/dev/null 2>&1; then
  progress "using existing chezmoi"
  printf '[%s|%s] using existing chezmoi\n' "$log_prefix" "$log_context" >"$LOG_DIR/chezmoi-install.log"
else
  progress "downloading chezmoi"
  run_and_log "$LOG_DIR/chezmoi-install.log" install_chezmoi
fi

progress "applying dotfiles"
if [[ -n "${DOTFILES:-}" ]]; then
  progress "using source directory from DOTFILES: $DOTFILES"
  run_and_log "$LOG_DIR/chezmoi-init.log" chezmoi init --promptDefaults --apply --source "$DOTFILES"
else
  run_and_log "$LOG_DIR/chezmoi-init.log" chezmoi init --promptDefaults --apply
fi

tools_file="$XDG_DATA_HOME/chris468/tools/tools.yaml"
if [[ ! -f "$tools_file" ]]; then
  echo "Missing expected tools file: $tools_file" >&2
  exit 1
fi

install_tools="$XDG_DATA_HOME/chris468/bin/install-tools"
if [[ ! -x "$install_tools" ]]; then
  echo "Missing install-tools script: $install_tools" >&2
  exit 1
fi

install_cmd=("$install_tools" --all "$@")
printf -v install_cmd_quoted '%q ' "${install_cmd[@]}"
progress "running install-tools"
run_and_log "$LOG_DIR/install-tools.log" bash -lc "$install_cmd_quoted"
