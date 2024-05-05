if command -v carapace >/dev/null 2>&1; then
	export CARAPACE_BRIDGES='zsh,fish,bash,powershell'
	source <(carapace _carapace)
fi
