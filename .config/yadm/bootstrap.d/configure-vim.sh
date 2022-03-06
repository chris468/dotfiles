#!/bin/bash

# git symbolic link to folder doesn't work on windows, so create it here.
if grep -qi "win" <<< "$OS" && test ! -e ~/vimfiles ; then
    pwsh -NoProfile -Command "& { New-Item -Type SymbolicLink -Target ~/.vim -Path ~/vimfiles }"
fi

vim -c PlugInstall -c qa

