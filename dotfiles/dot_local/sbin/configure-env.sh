#!/usr/bin/env bash

function set-environment() {
	local cmd=
	if [[ "$1" == "--export" ]]; then
		cmd="export "
		shift
	fi

	local name="$1"
	shift
	cmd="$cmd$name=\"\$@\""
	eval "$cmd"
}

function unset-environment() {
	if [[ "$1" == "--export" ]]; then
		shift
	fi

	local name=$1
	unset $name
}

function prepend-environment() {
	local cmd=
	if [[ "$1" == "--export" ]]; then
		cmd="export "
		shift
	fi

	local name="$1"
	shift

	cmd="$cmd$name=\""

	local current="$(eval "echo \$$name")"
	local i
	local update=
	for i in "$@"; do
		if [[ "$current" != *"$i"* ]]; then
			update="$update$i:"
		fi
	done

	if [[ -n "$update" ]]; then
		cmd="$cmd$update$current\""
        echo $cmd
		eval "$cmd"
	fi
}

function main() {
	local cmd=$1
	shift

	$cmd-environment "$@"

}

main "$@"

for i in {set,unset,prepend}-environment main; do
	unset -f $i
done
