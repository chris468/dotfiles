#!/usr/bin/bash

if ! command -v git >/dev/null 2>&1; then
  echo "error: could not find git in PATH" >&2
  exit 1
fi

sh -c "$(curl -fsLS get.chezmoi.io)" -- \
  -b /tmp \
  init --apply chris468 \
  "$@"
