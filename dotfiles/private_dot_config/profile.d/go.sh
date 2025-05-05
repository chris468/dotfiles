if [[ $PATH != *$HOME/go/bin:* ]] && [[ -d "$HOME/go/bin" ]]; then
  export PATH="$HOME/go/bin:$PATH"
fi
