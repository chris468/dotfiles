eval "$(oh-my-posh init zsh)"

function set_poshcontext {
    [ "$COLUMNS" -ge 90 ] && export POSH_WIDE=1 || export POSH_WIDE=0
}
