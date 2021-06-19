#!/bin/bash

worktree=$HOME/.config/dotfiles
branch=origin/main

function worktree_exists {
    git worktree list | awk '{ print $1 }' | grep -q $worktree
}

if worktree_exists ; then
    echo "Already installed ($worktree already exists)"
    exit 0
fi

echo "Creating installation $worktree using branch $branch..."
git worktree add --detach $worktree $branch

echo
echo "Configuring..."
$worktree/configure-all.sh $@

echo
echo "Complete."
