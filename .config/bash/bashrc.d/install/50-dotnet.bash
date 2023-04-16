#!/usr/bin/bash

DOTNET_INSTALL_PATH="$HOME/.local/opt/dotnet"

if [ "$1" == "--install" ]
then
  curl -L https://dot.net/v1/dotnet-install.sh \
    | bash -s -- --install-dir $HOME/.local/opt/dotnet --channel LTS

  ln -sfr "$DOTNET_INSTALL_PATH/dotnet" "$HOME/.local/opt/bin/dotnet"
fi

prepend-path "$HOME/.dotnet/tools"
