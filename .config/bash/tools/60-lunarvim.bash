#!/usr/bin/bash

LVIM_VERSION='release-1.2/neovim-0.8'
LVIM_INSTALLER_VERSION="fc6873809934917b470bff1b072171879899a36b"

if [ "$1" == "--install" ]
then
  __lvim_config_changes="$(yadm status -s -unormal ~/.config/lvim)"

  download https://raw.githubusercontent.com/lunarvim/lunarvim/$LVIM_INSTALLER_VERSION/utils/installer/install.sh \
          | LV_BRANCH=$LVIM_VERSION bash -s -- -y --install-dependencies

  if [ -z "$__lvim_config_changes" ]
  then
    echo "Restoring config from yadm..."
    yadm restore -- ~/.config/lvim
    # echo "Removing old packer cache..."
    # rm ~/.config/lvim/plugin/packer_compiled.lua
    echo "Rebuilding packer cache..."
    lvim --headless +PackerSync +"autocmd User PackerComplete qa"
  else
    echo "~/.config/lvim had changes, manually yadm estore or copy from lvim.old" >&2
  fi
fi
