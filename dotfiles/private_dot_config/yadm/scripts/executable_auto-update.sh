#!/bin/bash

auto_update_log_dir=~/.cache/yadm/auto-update
auto_update_status=$auto_update_log_dir/status
auto_update_last_update=$auto_update_log_dir/last_update
auto_update_in_progress=$auto_update_log_dir/in_progress
auto_update_log=$auto_update_log_dir/auto-update.log

function set-status {
    echo "$@" > $auto_update_status
}

function update-dotfiles  {
    yadm fetch --no-prune -v

    if [ "$(yadm branch --show-current)" == "main" ]
    then
      yadm checkout yadm/main
    fi

    if yadm status -sb | grep behind ; then
        set-status "UPDATING"
        yadm pull -q --no-prune

        yadm bootstrap
        set-status "UPDATED"
    else
        set-status "UPTODATE"
    fi
}

function remove_inprogress {
    rm -f $auto_update_in_progress
}

function update-dotfiles-in-background {
    trap remove_inprogress err exit
    update-dotfiles >$auto_update_log 2>&1 || set-status "FAILED"
}

function is-recent {
    [ -e "$auto_update_last_update" ] && [ -n "$(find $auto_update_last_update -mmin -30)" ]
}

mkdir -p $auto_update_log_dir

[ ! -e "$auto_update_in_progress" ] || exit

if [ "$1" = "-reset" ] ; then
    if is-recent ; then
        set-status "RECENT"
        rm -f $auto_update_in_progress
    else
        set-status "CHECKING"
    fi
    exit
fi

if is-recent
then
    exit
fi

touch $auto_update_in_progress
touch $auto_update_last_update
update-dotfiles-in-background &

