#!/bin/bash

script_dir="$(cd "$(dirname "$(readlink -e "$0")")" && pwd)"

for installer in $(find "$script_dir" -maxdepth 2 -name install.sh) ; do
    echo Running "$installer"...
    "$installer" $@
done

