#!/usr/bin/env bash

REPO=https://github.com/chris468/dotfiles
YADM_VERSION=3.2.1
CLASS=
BRANCH=main

function usage {
    cat << EOF
usage: $1 [option1] [option2] ...

options:
    -b|--branch <branch>
        Branch to install. Default: $BRANCH

    -c|--class <class>
        Yadm class to set. Default: none.

    -h|--help
        Display this message and exit.

    -r|--repo <repo>
        Dotfiles repo to install. Default: $REPO

    -v|--version <version>
        Yadm version/tag to install. Default: $YADM_VERSION

EOF
}

function install_yadm {

    mkdir -p $install_location
    curl -L -o $destination $url
    chmod +x $destination
}

while [ $# -gt 0 ]; do
    case $1 in
        -b|--branch)
            BRANCH="$2"
            ;;
        -c|--class)
            CLASS="$2"
            ;;
        -h|--help)
            usage
            exit
            ;;
        -r|--repo)
            REPO="$2"
            ;;
        -v|--version)
            YADM_VERSION="$2"
            ;;
        *)
            echo unknown argument $1 >&2
            usage
            exit 1
            ;;
    esac

    shift
    shift

done

function install_dotfiles {
    if grep -qi "win" <<< "$OS" ; then
        MSYS=winsymlinks:nativestrict
        git config --global core.symlinks true
    fi

    $yadm clone -b $BRANCH $REPO

    if [ -n "$CLASS" ] ; then
        $yadm config local.class $CLASS
    fi
}

url=https://raw.githubusercontent.com/TheLocehiliosan/yadm/$YADM_VERSION/yadm
install_location=$HOME/.local/bin
yadm=$install_location/yadm

install_yadm
install_dotfiles
