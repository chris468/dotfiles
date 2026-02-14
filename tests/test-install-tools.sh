#!/usr/bin/env bash
set -euo pipefail

LOG_DIR="${TEST_LOG_DIR:-$(mktemp -d "${TMPDIR:-/tmp}/install-tools.XXXXXX")}"
mkdir -p "$LOG_DIR"

cleanup() {
  local rc=$?
  if [[ $rc -ne 0 ]]; then
    echo "Test failed. Logs are in: $LOG_DIR" >&2
  else
    echo "Test succeeded. Logs are in: $LOG_DIR"
  fi
  exit "$rc"
}
trap cleanup EXIT

export XDG_DATA_HOME="${XDG_DATA_HOME:-$HOME/.local/share}"
export PATH="$HOME/.local/bin:$PATH"

mkdir -p "$HOME/.local/bin" "$XDG_DATA_HOME"

repo_root="${GITHUB_WORKSPACE:-$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)}"

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
  if command -v chezmoi >/dev/null 2>&1; then
    return 0
  fi

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
  local tgz="$LOG_DIR/$tarball"

  curl -fsSL "$url" -o "$tgz"
  tar -xzf "$tgz" -C "$HOME/.local/bin" chezmoi
  chmod +x "$HOME/.local/bin/chezmoi"
}

install_chezmoi 2>&1 | tee "$LOG_DIR/chezmoi-install.log"

chezmoi init --promptDefaults --apply --source "$repo_root" 2>&1 | tee "$LOG_DIR/chezmoi-init.log"

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
bash -lc "$install_cmd_quoted" 2>&1 | tee "$LOG_DIR/install-tools.log"
