if [ -z "$TMUX" ]
then
    echo
    echo "tmux sessions:"
    tmux list-sessions
fi
