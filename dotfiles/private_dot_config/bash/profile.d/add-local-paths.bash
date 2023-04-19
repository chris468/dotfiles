function __add_local_paths {
    local local_paths=(
        "$HOME/.local/bin"
        "$HOME/.local/opt/bin"
        "$HOME/bin"
     )

     for (( idx=${#local_paths[@]}-1; idx>=0 ; idx-- ))
     do
         local p=${local_paths[$idx]}
         PATH="$p:$PATH"
     done
}

__add_local_paths
