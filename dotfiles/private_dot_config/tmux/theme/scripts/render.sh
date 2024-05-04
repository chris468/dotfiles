function execute_module {
	local module_spec="$1"

	module="${module_spec%%:*}"
	module_args=${module_spec:${#module}+1}
	module_path="$modules_path/$module.tmux"

	echo "$("$module_path" $module_args)"
}

function render_content {
	local content=$1
	local foreground=$2
	local background=$3
	local prefix=$4
	local suffix=$5

	local content_style="#[fg=$foreground,bg=$background]"
	local separator_style="#[fg=$background,bg=$status_background]"

	echo "$separator_style$prefix$content_style$content$separator_style$suffix"
}

function render_module {
	module=$1
	shift
	render_content "$(execute_module "$module")" "$@"
}

function render_status_module {
	local index=$1
	local side=$2
	local module=$3

	local prefix suffix
	if [[ "$side" == "left" ]]; then
		suffix=$status_left_separator_right
		if [[ "$index" == "0" ]]; then
			prefix=$status_left_separator_outer
		else
			prefix=$status_left_separator_left
		fi
	else
		prefix=$status_right_separator_left
		if [[ "$index" == "0" ]]; then
			suffix=$status_right_separator_outer
		else
			suffix=$status_right_separator_right
		fi
	fi

	local foreground background
	if [[ "$index" == "0" ]]; then
		foreground="$status_outer_dynamic_foreground"
		background="$status_outer_dynamic_background"
	else
		foreground="$status_segment_foreground"
		background="$status_segment_background"
	fi

	render_module "$module" "$foreground" "$background" "$prefix" "$suffix"
}
