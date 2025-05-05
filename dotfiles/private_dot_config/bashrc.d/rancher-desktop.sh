if [[ $PATH != *$HOME/.rd/bin:$PATH*: ]] && [[ -d $HOME/.rd/bin ]]; then
  export PATH="$HOME/.rd/bin:$PATH"
fi
