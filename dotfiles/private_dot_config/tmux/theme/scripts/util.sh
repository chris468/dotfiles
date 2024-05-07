function get_option {
	local option=$1
	shift

	local result
	if [[ "$option" == @* ]]; then
		result=$(tmux show-option -gqv "$option")
		if [[ -z "$result" ]]; then
			result=$(get_option "$@")
		fi
	else
		result="$option"
	fi

	echo "$result"
}
