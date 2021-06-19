#!/bin/bash

# Created by argbash-init v2.10.0
# ARG_OPTIONAL_BOOLEAN([force],[f],[Force overwriting existing files])
# ARG_HELP([Updates to the latest dotfiles])
# ARGBASH_GO()
# needed because of Argbash --> m4_ignore([
### START OF CODE GENERATED BY Argbash v2.10.0 one line above ###
# Argbash is a bash code generator used to get arguments parsing right.
# Argbash is FREE SOFTWARE, see https://argbash.io for more info


die()
{
	local _ret="${2:-1}"
	test "${_PRINT_HELP:-no}" = yes && print_help >&2
	echo "$1" >&2
	exit "${_ret}"
}


begins_with_short_option()
{
	local first_option all_short_options='fh'
	first_option="${1:0:1}"
	test "$all_short_options" = "${all_short_options/$first_option/}" && return 1 || return 0
}

# THE DEFAULTS INITIALIZATION - OPTIONALS
_arg_force="off"


print_help()
{
	printf '%s\n' "Updates to the latest dotfiles"
	printf 'Usage: %s [-f|--(no-)force] [-h|--help]\n' "$0"
	printf '\t%s\n' "-f, --force, --no-force: Force overwriting existing files (off by default)"
	printf '\t%s\n' "-h, --help: Prints help"
}


parse_commandline()
{
	while test $# -gt 0
	do
		_key="$1"
		case "$_key" in
			-f|--no-force|--force)
				_arg_force="on"
				test "${1:0:5}" = "--no-" && _arg_force="off"
				;;
			-f*)
				_arg_force="on"
				_next="${_key##-f}"
				if test -n "$_next" -a "$_next" != "$_key"
				then
					{ begins_with_short_option "$_next" && shift && set -- "-f" "-${_next}" "$@"; } || die "The short option '$_key' can't be decomposed to ${_key:0:2} and -${_key:2}, because ${_key:0:2} doesn't accept value and '-${_key:2:1}' doesn't correspond to a short option."
				fi
				;;
			-h|--help)
				print_help
				exit 0
				;;
			-h*)
				print_help
				exit 0
				;;
			*)
				_PRINT_HELP=yes die "FATAL ERROR: Got an unexpected argument '$1'" 1
				;;
		esac
		shift
	done
}

parse_commandline "$@"

# OTHER STUFF GENERATED BY Argbash

### END OF CODE GENERATED BY Argbash (sortof) ### ])
# [ <-- needed because of Argbash


set -e

script_dir="$(cd "$(dirname "$(readlink -e "$0")")" && pwd)"
git="git -C $script_dir"

function has_updates {
    $git fetch origin
    $git status --porcelain -b | grep -q "\[behind"
}

if has_updates ; then
    echo "dotfiles are out of date. Updating..."
    $git pull
    [ $_arg_force == "on" ] && mode="-f" || mode="-q"
    $script_dir/configure-all.sh $mode
else
    echo "dotfiles are up to date."
fi

# ] <-- needed because of Argbash