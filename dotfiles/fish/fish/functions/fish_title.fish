function fish_title
    if set -q SSH_CLIENT
        or set -q SSH_TTY
        set marker "*"
    end

    set command (status current-command)

    echo "$USER@$hostname$marker $command"
end
