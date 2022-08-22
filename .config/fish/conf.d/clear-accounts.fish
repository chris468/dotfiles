if not status is-interactive
   or not status is-login
   or test -n "$TMUX"
    exit
end

set -e AWS_PROFILE
set -e KUBECONFIG
