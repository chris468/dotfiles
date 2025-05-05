if [ -f "$HOME/.cargo/env" ]; then
  source "$HOME/.cargo/env"
fi

if [[ $PATH != *$HOME/.cargo/bin:* ]] && [[ -d "$HOME/.cargo/bin" ]]; then
  export PATH="$HOME/.cargo/bin:$PATH"
fi
