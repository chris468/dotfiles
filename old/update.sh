#!/bin/bash

script_dir="$(cd "$(dirname "$(readlink -e "$0")")" && pwd)"

(cd $script_dir && python3.9 -m manager update $@)

