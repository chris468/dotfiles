function install-devtools {
  brew install \
    awscli \
    azure-cli \
    dotnet \
    gh \
    helm \
    k9s \
    kubectl \
    node \
    rust

  install-dotnet --channel LTS
}
