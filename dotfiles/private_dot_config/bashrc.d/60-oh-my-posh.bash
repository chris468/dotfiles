if command -v oh-my-posh &>/dev/null; then
  eval "$(oh-my-posh init bash --config ~/.config/oh-my-posh/chris468.omp.yaml)"
fi

function set_poshcontext {
  [ "$COLUMNS" -ge 90 ] && export POSH_WIDE=1 || export POSH_WIDE=0
}
