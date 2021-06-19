#!/bin/bash

script_dir="$(cd "$(dirname "$(readlink -e "$0")")" && pwd)"

for configurator in $(find "$script_dir" -maxdepth 2 -name configure.sh) ; do
    echo Running "$configurator"...
    "$configurator" $@
done

