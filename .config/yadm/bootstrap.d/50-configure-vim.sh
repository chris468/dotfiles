#!/bin/bash

script=$(readlink -e "${BASH_SOURCE[0]}")
script_dir="$(cd "$(dirname "$script")" && pwd)"
config_dir="$(dirname $(dirname $(dirname $script_dir)))"

vim -c PlugInstall -c qa

