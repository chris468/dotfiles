function install-neovim {
  NEOVIM_VERSION="${1:-v0.8.3}"
  if [ "$(uname -o)" == "Msys" ]
  then
      NEOVIM_ARCHIVE=nvim-win64.zip
      NEOVIM_TARGET=nvim-win64
      NEOVIM_LINK=nvim/current
  else
      NEOVIM_ARCHIVE=nvim.appimage
      NEOVIM_TARGET=nvim
      NEOVIM_LINK=bin/nvim
  fi
  NEOVIM_URL="https://github.com/neovim/neovim/releases/download/$NEOVIM_VERSION/$NEOVIM_ARCHIVE"

  install-download "$NEOVIM_URL" nvim $NEOVIM_VERSION $NEOVIM_TARGET $NEOVIM_LINK
}

function install-lunarvim {

  function install-deps {
    if [ "$(uname -o)" == "Msys" ]
    then
        ensure-scoop
        scoop install python nodejs rust make gcc
    else
        brew install python node rust
    fi
  }

  function install-lvim {
    LVIM_VERSION='release-1.2/neovim-0.8'
    LVIM_INSTALLER_VERSION="fc6873809934917b470bff1b072171879899a36b"

    if [ "$(uname -o)" == "Msys" ]
    then
        LVIM_INSTALLER_URL="https://raw.githubusercontent.com/lunarvim/lunarvim/$LVIM_INSTALLER_VERSION/utils/installer/install.ps1"

        local cmd
        cmd='& { $LV_BRANCH='"'$LVIM_VERSION'; Invoke-WebRequest $LVIM_INSTALLER_URL -UseBasicParsing | Invoke-Expression } \""
        echo $cmd
        pwsh -c "$cmd"
    else
        LVIM_INSTALLER_URL="https://raw.githubusercontent.com/lunarvim/lunarvim/$LVIM_INSTALLER_VERSION/utils/installer/install.sh"

        download $LVIM_INSTALLER_URL \
          | INSTALL_PREFIX="$LOCAL_OPT" LV_BRANCH=$LVIM_VERSION \
          bash -s -- -y --install-dependencies
    fi
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
