#!/bin/bash

script_dir="$(cd "$(dirname "$(readlink -e "$0")")" && pwd)"
config_file=$script_dir/gitconfig

function has-include {
    git config --global -l | grep -q "include.path=$config_file"
}

function add-include {
    git config --global --add include.path "$config_file"
}

if ! command -v git &> /dev/null ; then
    echo "git not installed, skipping"
    exit
fi

has-include || add-include

