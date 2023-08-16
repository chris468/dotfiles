if command -v oh-my-posh &>/dev/null; then
	eval "$(oh-my-posh init bash)"
fi

function set_poshcontext {
	[ "$COLUMNS" -ge 90 ] && export POSH_WIDE=1 || export POSH_WIDE=0
}
