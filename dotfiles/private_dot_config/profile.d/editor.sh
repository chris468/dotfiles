function __find_editor {
  declare -la editors
  editors=('nvim' 'vim' 'vi' 'gvim')
  declare -l e
  for e in ${editors[@]}; do
    if command -v "$e" &>/dev/null; then
      export EDITOR="$e"
      break
    fi
  done
  unset -f __find_editor
}

__find_editor
