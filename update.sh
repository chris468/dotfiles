#!/bin/bash

set -e

script_dir="$(cd "$(dirname "$(readlink -e "$0")")" && pwd)"
git="git -C $script_dir"

function has_updates {
    $git fetch origin
    $git status --porcelain -b | grep -q "\[behind"
}

if has_updates ; then
    echo "dotfiles are out of date. Updating..."
    $git pull
    $script_dir/configure-all.sh -q
else
    echo "dotfiles are up to date."
fi
