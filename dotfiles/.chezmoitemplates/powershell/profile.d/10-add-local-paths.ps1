function __add_local_paths {
    $local_paths=@(
        "$HOME/.local/bin",
        "$HOME/.local/opt/nvim/current/bin",
        "$HOME/.local/opt/bin",
        "$HOME/scoop/shims"
    )

    prepend-path $local_paths -Persist
}

__add_local_paths
