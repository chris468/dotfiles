#!/usr/bin/env bash

sh -c "$(curl -fsLS get.chezmoi.io)" -- \
    -b $(mktemp -d /tmp/bootstrap-dotfiles-XXX) \
    init --apply --branch chezmoi chris468 \
    "$@"
