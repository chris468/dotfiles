function __title {
    if [ -n "$SSH_CLIENT" ] || [ -n "$SSH_TTY" ]
    then
        marker="*"
    else
        marker=""
    fi

    __title="\033]0;$USER@$(hostname)$marker $command $BASH_COMMAND\007"
    echo -ne "$__title"
}

trap 'echo -ne $(__title)' DEBUG
