#!/bin/bash

script=$(readlink -f $0)
scriptpath=$(dirname $script)

vim -u $scriptpath/test-vimrc $@
