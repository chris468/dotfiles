function __find_editor {
    editors=('nvim' 'vim.bat' 'gvim.bat' 'vim' 'vi' )
    for e in ${editors[@]}
    do
        if command -v "$e"
        then
            return
        fi
    done
}

__editor=$(__find_editor)
if [ -n "$__editor" ]
then
    export EDITOR="$__editor"
fi
unset __editor
