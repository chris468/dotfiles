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

function condition {
	local condition="$1"
	local positive="$2"
	local negative="$3"

	local format=
	if [[ -n "$positive" ]]; then
		format="#{?$condition,$positive,"
	fi

	format="$format$negative"

	if [[ -n "$positive" ]]; then
		format="$format}"
	fi

	echo "$format"
}
