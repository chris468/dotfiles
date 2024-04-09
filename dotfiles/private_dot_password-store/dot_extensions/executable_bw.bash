#!/usr/bin/env bash

set -e -o pipefail

function die() {
	local msg="$1"
	local code=${2:-1}

	echo "$msg" >&2
	exit $code
}

function save_bw_session() {
	local name="$1"
	local session="$2"

	pass insert -m -f "bw/$name" >/dev/null <<-EOF
		$session
	EOF
}

function get_saved_session() {
	local name="$1"
	pass show "bw/$name" || true
}

function bw_login() {
	if ! bw login --raw; then
		die "error: bitwarden login failed."
	fi
}

function bw_unlock() {
	if ! bw unlock --raw; then
		die "error: bitwarden login failed."
	fi
}

function get_bw_status() {
	local session="$1"
	BW_SESSION="$session" bw status | jq -r .status
}

function get_bw_session() {
	local name="${1:-default}"
	local original_session="$(get_saved_session "$name")"
	local status="$(get_bw_status "$original_session")"

	if [ "$status" == "unauthenticated" ]; then
		session="$(bw_login)"
	elif [ "$status" != "unlocked" ]; then
		session="$(bw_unlock)"
	else
		session="$original_session"
	fi

	if [ "$session" != "$original_session" ]; then
		save_bw_session "$name" "$session"
	fi

	cat <<-EOF
		"$session"
	EOF
}

function main() {
	BW_SESSION=$(get_bw_session) bw "$@"
}

main "$@"
