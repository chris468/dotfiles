if not status is-interactive
   or not status is-login
   or test -n "$TMUX"
    exit
end

echo
echo "tmux sessions:"
tmux list-sessions

