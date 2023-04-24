function set-kubeconfig {
    function join {
        local IFS=':'
        echo "$*"
    }

    if [ -d ~/.kube ]
    then
        readarray -d '' files < <(find ~/.kube/ -maxdepth 1 -type f,l -print0)
        if (( ${#files[@]} ))
        then
            export KUBECONFIG=$(join "${files[@]}")
        fi
    fi
}
