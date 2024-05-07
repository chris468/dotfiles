function get_option {
	local option=$1
	shift

	local result
	if [[ "$option" == @* ]]; then
		result=$(tmux show-option -gqv "$option")
		if [[ -n "$result" ]]; then
			echo "$result"
		else
			get_option "$@"
		fi
	else
		echo "$option"
	fi

}
