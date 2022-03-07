#!/bin/bash

script=$(readlink -e "${BASH_SOURCE[0]}")
script_dir="$(cd "$(dirname "$script")" && pwd)"
git_config_dir="$(dirname $(dirname $script_dir))"/git
include_file_name=yadm-config
include_file_path=$git_config_dir/$include_file_name

git config --get-all include.path | grep -q $include_file_name || git config --global --add include.path $include_file_path
