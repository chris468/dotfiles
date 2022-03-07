#!/bin/bash

script=$(readlink -e "${BASH_SOURCE[0]}")
script_dir="$(cd "$(dirname "$script")" && pwd)"
config_dir="$(dirname $(dirname $(dirname $script_dir)))"

# git symbolic link to folder doesn't work on windows, so create it here.
if grep -qi "win" <<< "$OS" && test ! -e ~/vimfiles ; then
    (cd $config_dir && pwsh -NoProfile -Command '& { New-Item -Type SymbolicLink -Target $PWD/.vim -Path $PWD/vimfiles }')
fi

vim -c PlugInstall -c qa

