function install-neovim {
  NEOVIM_VERSION="${1:-v0.8.3}"
  NEOVIM_URL="https://github.com/neovim/neovim/releases/download/$NEOVIM_VERSION/nvim.appimage"

  if [ ! -f "$NEOVIM_DESTINATION" ]
  then
    install-download "$NEOVIM_URL" nvim $NEOVIM_VERSION nvim bin/nvim
  fi
}

function install-lunarvim {

  function install-deps {
    brew install python node rust
  }

  function install-lvim {
    LVIM_VERSION='release-1.2/neovim-0.8'
    LVIM_INSTALLER_VERSION="fc6873809934917b470bff1b072171879899a36b"
    LVIM_INSTALLER_URL="https://raw.githubusercontent.com/lunarvim/lunarvim/$LVIM_INSTALLER_VERSION/utils/installer/install.sh"

    download $LVIM_INSTALLER_URL | LV_BRANCH=$LVIM_VERSION bash -s -- -y --install-dependencies
  }

  function check-for-config-changes {
    yadm status -s -unormal ~/.config/lvim
  }

  function restore-config {
    echo $1
    if [ -z "$1" ]
    then
      echo "Restoring config from yadm..."
      yadm restore -- ~/.config/lvim
      # echo "Removing old packer cache..."
      # rm ~/.config/lvim/plugin/packer_compiled.lua
      echo "Rebuilding packer cache..."
      lvim --headless +PackerSync +"autocmd User PackerComplete qa"
    else
      echo "~/.config/lvim had changes, manually 'yadm restore' or copy from lvim.old" >&2
    fi
  }

  local lvim_config_changes
  if ! lvim_config_changes="$(check-for-config-changes)"
  then
    return $?
  fi

  install-deps && install-neovim && install-lvim && restore-config "$lvim_config_changes"

}
