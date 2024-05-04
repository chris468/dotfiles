function check_arg {
	local arg="$1"
	local opt="$2"

	[[ "$opt" != -* ]] || (
		echo "missing value for '$arg'" >&2
		return 1
	)
}
