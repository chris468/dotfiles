#!/usr/bin/bash

DOTNET_INSTALL_PATH="$HOME/.local/opt/dotnet"

if [ "$1" == "--install" ]
then
  curl -L https://dot.net/v1/dotnet-install.sh \
    | bash -s -- --install-dir $HOME/.local/opt/dotnet --channel LTS

  ln -sfr "$DOTNET_INSTALL_PATH/dotnet" "$HOME/.local/opt/bin/dotnet"
fi

prepend-path "$HOME/.dotnet/tools"

function _dotnet_bash_complete()
{
  local cur="${COMP_WORDS[COMP_CWORD]}" IFS=$'\n'
  local candidates

  read -d '' -ra candidates < <(dotnet complete --position "${COMP_POINT}" "${COMP_LINE}" 2>/dev/null)

  read -d '' -ra COMPREPLY < <(compgen -W "${candidates[*]:-}" -- "$cur")
}

complete -f -F _dotnet_bash_complete dotnet
