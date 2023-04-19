#!/usr/bin/env bash

function die {
    echo "$@" >&2
    exit 1
}

if [ $# -lt 2 ]
then
    die "usage: $0 <template dir> <dest dir 1> [... <dest dir N>]"
fi

root="$(chezmoi source-path)"
template_root="$1"
templates="$(cd "$root/.chezmoitemplates/$template_root" && find * ! -type d)"
shift
destinations="$@"

for source in $templates
do
  for destination in $destinations
  do
    full_destination="$root/$destination/${source}.tmpl"
    mkdir -p "$(dirname "$full_destination")"
    echo "{{- template \"$template_root/$source\" . -}}" > "$full_destination"
  done
done

