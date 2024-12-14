#!/usr/bin/env bash

[ -n "$(find ~/.terminfo -name wezter)" ] ||
  (echo "Installing wezterm terminfo" &&
    tempfile=$(mktemp) &&
    curl -o $tempfile https://raw.githubusercontent.com/wez/wezterm/main/termwiz/data/wezterm.terminfo &&
    tic -x -o ~/.terminfo $tempfile &&
    rm $tempfile)
