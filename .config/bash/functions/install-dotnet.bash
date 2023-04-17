function install-dotnet {
  DOTNET_INSTALL_PATH="$HOME/.local/opt/dotnet"

  download https://dot.net/v1/dotnet-install.sh \
    | bash -s -- --install-dir $DOTNET_INSTALL_PATH "$@"

  ln -sfr "$DOTNET_INSTALL_PATH/dotnet" "$HOME/.local/opt/bin/dotnet"
}
