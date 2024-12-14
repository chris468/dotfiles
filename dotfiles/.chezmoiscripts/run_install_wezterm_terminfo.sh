#!/usr/bin/env bash

[ -n "$(find ~/.terminfo -name wezterm)" ] ||
  (echo "Installing wezterm terminfo" &&
    tempfile=$(mktemp) &&
    curl -s -o $tempfile https://raw.githubusercontent.com/wez/wezterm/main/termwiz/data/wezterm.terminfo &&
    tic -x -o ~/.terminfo $tempfile &&
    rm $tempfile)
