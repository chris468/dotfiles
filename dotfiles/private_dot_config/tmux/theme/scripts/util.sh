function check_arg {
	local arg="$1"
	local opt="$2"

	[[ "$opt" != -* ]] || (
		echo "missing value for '$arg'" >&2
		return 1
	)
}

function get_option {
	local option=$1
	local fallback=$2

	local result=$(tmux show-option -gqv "$option")
	if [[ -z "$result" ]] && [[ -n "$fallback" ]]; then
		result=$(tmux show-option -gqv "$fallback")
	fi

	echo "$result"
}
