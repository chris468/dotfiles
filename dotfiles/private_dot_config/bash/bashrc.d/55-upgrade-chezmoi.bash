#!/usr/bin/bash

last_chezmoi_upgrade="$HOME/.cache/dotfiles/last-chezmoi-upgrade"

[ -e "$last_chezmoi_upgrade" ] \
  && [ -n "$(find $last_chezmoi_upgrade -daystart -mtime 0)" ] \
  || (chezmoi upgrade \
      && mkdir -p "$(dirname $last_chezmoi_upgrade)" >& /dev/null \
      && touch $last_chezmoi_upgrade)
