#!/usr/bin/env bash

CURRENT=$(realpath --no-symlinks ${1:-$(pwd)})
STOP=$(dirname $HOME)

if get-command -v poetry >/dev/null 2>&1; then
  poetry -C "$CURRENT" env list --full-path 2>/dev/null |
    sed -E -e "s/ \(Activated\)//" -e "s|(.+)|\1/bin/python|"
fi

while [[ $CURRENT != "$STOP" ]]; do
  if [[ -e $CURRENT/.venv/bin/python ]]; then
    echo "$CURRENT/.venv/bin/python"
    break
  fi

  CURRENT="$(dirname "$CURRENT")"
done

echo "${VENVS[@]}"

for i in ${VENVS[0]}; do echo "$i"; done
