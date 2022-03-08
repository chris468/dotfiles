if not set -q TMUX ; and status --is-login
    cd ~
    exec tmux
end
