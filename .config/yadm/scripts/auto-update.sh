#!/bin/bash

function update-dotfiles  {
    yadm fetch --no-prune

    if yadm status -sb | grep behind ; then
        yadm pull -q --no-prune
        yadm bootstrap
    fi
}

update-dotfiles 2>&1 > ~/.cache/update-dotfiles.log &

