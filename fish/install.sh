#!/bin/bash

# Created by argbash-init v2.8.1
# Rearrange the order of options below according to what you would like to see in the help message.
# ARG_OPTIONAL_BOOLEAN([force],[f],[Force overwriting existing files])
# ARG_OPTIONAL_BOOLEAN([quiet],[q],[Skip files that already exist])
# ARG_HELP([Installs the fish configuration])
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
	local first_option all_short_options='fqh'
	first_option="${1:0:1}"
	test "$all_short_options" = "${all_short_options/$first_option/}" && return 1 || return 0
}

# THE DEFAULTS INITIALIZATION - OPTIONALS
_arg_force="off"
_arg_quiet="off"


print_help()
{
	printf '%s\n' "Installs the fish configuration"
	printf 'Usage: %s [-f|--(no-)force] [-q|--(no-)quiet] [-h|--help]\n' "$0"
	printf '\t%s\n' "-f, --force, --no-force: Force overwriting existing files (off by default)"
	printf '\t%s\n' "-q, --quiet, --no-quiet: Skip files that already exist (off by default)"
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
			-q|--no-quiet|--quiet)
				_arg_quiet="on"
				test "${1:0:5}" = "--no-" && _arg_quiet="off"
				;;
			-q*)
				_arg_quiet="on"
				_next="${_key##-q}"
				if test -n "$_next" -a "$_next" != "$_key"
				then
					{ begins_with_short_option "$_next" && shift && set -- "-q" "-${_next}" "$@"; } || die "The short option '$_key' can't be decomposed to ${_key:0:2} and -${_key:2}, because ${_key:0:2} doesn't accept value and '-${_key:2:1}' doesn't correspond to a short option."
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

config_dir=~/.config/fish

if [ -e "$config_dir" ] ; then
    if [ "$_arg_quiet" == "on" ] ; then
        exit 0
    fi

    if [ "$_arg_force" != "on" ] ; then
        die "$config_dir already exists"
    fi
fi

rm -rf "$config_dir"
mkdir -p ~/.config

script_dir="$(cd "$(dirname "$(readlink -e "$0")")" && pwd)"

ln -sf $script_dir/fish "$config_dir"

# ] <-- needed because of Argbash
