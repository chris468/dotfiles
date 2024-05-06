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

	local pl_style="$(_style "$bg" "$status_background")"

	local format=
	[[ -z "$left" ]] || format="$pl_style$left"
	format="$format$(_style "$fg" "$bg" "$attr")"
	[[ -z "$icon" ]] || format="$format$icon"
	[[ -z "$content" ]] || format="$format$content"
	[[ -z "$right" ]] || format="$format$pl_style$right"

	echo "$format"
}

function theme_segment {
	local id="$1"
	local left="${2+$(tmux show-option -gvq $2)}"
	local right="${3+$(tmux show-option -gvq $3)}"
	local fallback_id="$4"
	local content="$(get_option "$id" "$fallback_id")"
	local icon="$(get_option "$id-icon" "${fallback_id:+$fallback_id-icon}")"
	local fg="$(get_option "$id-foreground" "${fallback_id:+$fallback_id-foreground}")"
	local bg="$(get_option "$id-background" "${fallback_id:+$fallback_id-background}")"
	local attr="$(get_option "$id-attr" "${fallback_id:+$fallback_id-attr}")"

	segment "$fg" "$bg" "$attr" "$left" "$right" "$icon" "$content"
}
