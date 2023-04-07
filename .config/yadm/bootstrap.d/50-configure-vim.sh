#!/bin/bash

if command -v nvim &> /dev/null
then
    nvim -c 'autocmd User PackerComplete quitall' -c PackerSync
elif command -v vim &> /dev/null
then
    vim -c PlugInstall -c qa
fi
