#!/bin/bash

auto_update_log_dir=~/.cache/yadm/auto-update
auto_update_status=$auto_update_log_dir/status.log

function set-status {
    echo "$@" > $auto_update_status
}

function update-dotfiles  {
    yadm fetch --no-prune

    if yadm status -sb | grep behind ; then
        set-status "UPDATING"
        yadm pull -q --no-prune
        yadm bootstrap
        set-status "UPDATED"
    else
        set-status "UPTODATE"
    fi
}

function update-dotfiles-in-background {
    update-dotfiles || set-status "FAILED"
}

mkdir -p $auto_update_log_dir

if [ "$1" = "-reset" ] ; then
    echo "CHECKING" > $auto_update_status
    exit
fi


update-dotfiles-in-background 2>&1 > ~/.cache/update-dotfiles.log &

