#!/usr/bin/env bash

tmux set -g default-shell "$(command -v zsh || command -v bash)"
tmux set -g default-command "$SHELL"
