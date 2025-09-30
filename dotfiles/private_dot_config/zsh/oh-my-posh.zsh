if [ -z "$SIMPLE_PROMPT" ]; then
  eval "$(oh-my-posh init zsh --config ~/.config/oh-my-posh/chris468.omp.yaml)"

  function set_poshcontext {
    [ "$COLUMNS" -ge 90 ] && export POSH_WIDE=1 || export POSH_WIDE=0
  }
else
  PS1="%% "
fi
