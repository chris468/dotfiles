if command -v gem &>/dev/null; then
  if ! _gem_dir="$(gem environment user_gemhome 2>/dev/null)/bin"; then
    for __candidate in $(gem environment gempath 2>/dev/null | tr ":" "\n "); do
      if [[ "$__candidate" == "$HOME"* ]]; then
        _gem_dir="$__candidate/bin"
        break
      fi
    done
  fi
  if [[ -n "$_gem_dir" ]] && [[ $PATH != *"$_gem_dir"* ]] && [[ -d "$_gem_dir" ]]; then
    export PATH="$_gem_dir:$PATH"
  fi
  unset _gem_dir
fi
