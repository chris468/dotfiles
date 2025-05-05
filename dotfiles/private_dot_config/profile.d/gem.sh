if command -v gem &>/dev/null; then
  _gem_dir="$(gem environment user_gemhome)/bin"
  if [[ $PATH != *$(gem environment user_gemhome)/bin:* ]] && [[ -d "$_gem_dir" ]]; then
    export PATH="$_gem_dir:$PATH"
  fi
  unset _gem_dir
fi
