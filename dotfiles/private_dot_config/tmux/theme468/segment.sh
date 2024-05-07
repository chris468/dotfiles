function _style {
	local fg="$1"
	local bg="$2"
	local attr="$3"

	local style=

	[[ -z "$fg" ]] || style="fg=$fg"
	[[ -z "$bg" ]] || style="$style${style+,}bg=$bg"
	[[ -z "$attr" ]] || style="$style${style+,}$attr"

	[[ -n "$style" ]] || (
		echo "empty style" >&2
		return 1
	) && echo "#[$style]"
}

function segment {
	local fg="$1"
	local bg="$2"
	local attr="$3"
	local left="$4"
	local right="$5"
	local icon="$6"
	local content="$7"

	local pl_style="$(_style "$bg" "$(get_option @theme468-status-background "$default_status_background")")"

	local format=
	[[ -z "$left" ]] || format="$pl_style$left"
	format="$format$(_style "$fg" "$bg" "$attr")"
	[[ -z "$icon" ]] || format="$format$icon"
	[[ -z "$content" ]] || format="$format$content"
	[[ -z "$right" ]] || format="$format$pl_style$right"

	echo "$format"
}
