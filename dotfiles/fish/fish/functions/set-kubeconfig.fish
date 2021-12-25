function set-kubeconfig
    set -x -g KUBECONFIG (string join ':' (find ~/.kube/ -maxdepth 1 -type f))
end
