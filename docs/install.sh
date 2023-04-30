#!/usr/bin/env bash

sh -c "$(curl -fsLS get.chezmoi.io)" -- \
    -b $HOME/.local/opt/bin \
    init --apply chris468 \
    "$@"
