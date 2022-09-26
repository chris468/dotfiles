function __add_local_paths {
    local local_paths=(
        "$HOME/bin"
        "$HOME/.local/bin"
        "/home/linuxbrew/.linuxbrew/bin"
        "$HOME/.linuxbrew/bin"
     )

     for (( idx=${#local_paths[@]}-1; idx>=0 ; idx-- ))
     do
         local p=${local_paths[$idx]}
         if [ -d "$p" ]
         then
             PATH="$p:$PATH"
         fi
     done
}

__add_local_paths
