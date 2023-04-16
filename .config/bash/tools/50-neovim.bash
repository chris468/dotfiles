#!/usr/bin/bash 

NEOVIM_VERSION="v0.8.3"
NEOVIM_DESTINATION="$HOME/.local/opt/bin/nvim-$NEOVIM_VERSION"
NEOVIM_LINK="$HOME/.local/opt/bin/nvim"

if [ "$1" == "--install" ]
then
  if [ ! -f "$NEOVIM_DESTINATION" ]
  then
      curl -L -o "$NEOVIM_DESTINATION" https://github.com/neovim/neovim/releases/download/$NEOVIM_VERSION/nvim.appimage
      chmod +x "$NEOVIM_DESTINATION"

      ln -sfr "$NEOVIM_DESTINATION" "$NEOVIM_LINK"
  fi
fi
