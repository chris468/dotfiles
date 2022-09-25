if [ -z "$TMUX" ] && [ command -v tmux &> /dev/null ]
then
    echo
    echo "tmux sessions:"
    tmux list-sessions
fi
