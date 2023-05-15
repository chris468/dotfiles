#!/usr/bin/bash

set -e
set -o pipefail

YADM_ROOT="$HOME/.local/share/yadm"
YADM_REPO="$YADM_ROOT/repo.git"
YADM_BACKUP="$YADM_ROOT/dotfiles.bkp"

if ! command -v git &> /dev/null
then
  echo "Git not found, cannot clean yadm files." >&2
  exit 1
fi

if [ -d "$YADM_REPO" ]
then
  echo "Moving yadm dotfiles to $YADM_BACKUP..."
  IFS=$'\n'
  for f in $(GIT_DIR="$YADM_REPO" git -C "$HOME" ls-tree --name-only -r HEAD "$HOME")
  do
    if [ -f "$HOME/$f" ] || [ -L "$HOME/$f" ]
    then
      parent="$YADM_BACKUP/$(dirname "$f")"
      mkdir -p "$parent"
      mv "$HOME/$f" "$YADM_BACKUP/$f"
    fi
  done
  mv "$YADM_REPO" "$YADM_REPO.bkp"
else
  echo "$YADM_REPO not found, skipping yadm cleanup"
fi
