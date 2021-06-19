#!/bin/bash

set -e

script_dir="$(cd "$(dirname "$(readlink -e "$0")")" && pwd)"
git="git -C $script_dir"

function has_updates {
    branch=$($git branch --show-current)
    $git fetch origin $branch
    current_revision=$($git rev-parse HEAD)
    remote_revision=$($git ls-remote origin $branch | awk '{ print $1 }')
    [ "$current_revision" != "$remote_revision" ]
}

if has_updates ; then
    echo "dotfiles are out of date. Updating..."
else
    echo "dotfiles are up to date."
fi
