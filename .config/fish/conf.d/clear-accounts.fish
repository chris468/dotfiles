if not status is-interactive
   or not status is-login
    exit
end

set -e AWS_PROFILE
set -e KUBECONFIG
