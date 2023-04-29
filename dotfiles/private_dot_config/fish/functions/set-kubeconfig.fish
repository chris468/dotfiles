function set-kubeconfig
    if test -d ~/.kube
        set -l files (string join ':' (find ~/.kube/ -maxdepth 1 -type f,l))
        if test -n "$files"
            set -x -g KUBECONFIG "$files"
        end
    end
end
