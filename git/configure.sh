#!/bin/bash

script_dir="$(cd "$(dirname "$(readlink -e "$0")")" && pwd)"
config_file=$script_dir/dotfiles-gitconfig

function has-include {
    git config --global --get-all include.path | grep -q "$config_file"
}

function add-include {
    git config --global --add include.path "$config_file"
}

function cleanup-duplicates {
    for include in $(git config --global --get-all include.path | grep dotfiles-gitconfig) ; do
        if [ "$config_file" != "$include" ] ; then
            git config --global --unset include.path "$include"
        fi
    done
}

if ! command -v git &> /dev/null ; then
    echo "git not installed, skipping"
    exit
fi

cleanup-duplicates
has-include || add-include

