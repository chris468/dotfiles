#!/usr/bin/env bash

set -e

REPO=https://github.com/chris468/dotfiles
YADM_VERSION=3.2.1
CLASS=()
BRANCH=main
BOOTSTRAP=

function usage {
    cat << EOF
usage: $1 [option1] [option2] ...

options:
    -b|--branch <branch>
        Branch to install. Default: $BRANCH

    -c|--class <class>
        Yadm class to set. Can be specified multiple times. Default: none.

    -h|--help
        Display this message and exit.

    -r|--repo <repo>
        Dotfiles repo to install. Default: $REPO

    -v|--version <version>
        Yadm version/tag to install. Default: $YADM_VERSION

    --bootstrap|--no-bootstrap
        Bootstrap or not without prompt. Default will prompt.

any other options are passed to yadm.

EOF
}

function install_yadm {

    echo "Downloading yadm..."
    mkdir -p $install_location
    curl -Ls -o $yadm $url
    chmod +x $yadm
}

while [ $# -gt 0 ]; do
    case $1 in
        -b|--branch)
            BRANCH="$2"
            shift
            shift
            ;;
        -c|--class)
            CLASS+=("$2")
            shift
            shift
            ;;
        -h|--help)
            usage
            exit
            ;;
        -r|--repo)
            REPO="$2"
            shift
            shift
            ;;
        -v|--version)
            YADM_VERSION="$2"
            shift
            shift
            ;;
        --bootstrap|--no-bootstrap)
            BOOTSTRAP=$1
            shift
            ;;
        *)
            echo unknown argument $1 >&2
            usage
            exit 1
            ;;
    esac
done

function install_dotfiles {
    if grep -qi "win" <<< "$OS" ; then
        MSYS=winsymlinks:nativestrict
        git config --global core.symlinks true
    fi

    $yadm clone $BOOTSTRAP -b $BRANCH $REPO

    for c in ${CLASS[@]} ; do
        $yadm config --add local.class $c
    done
}

function backup_dotfiles {
    df=(~/.inputrc ~/.bash_completion ~/.bash_logout ~/.bashrc ~/.profile)
    for f in "${df[@]}"
    do
        if [ -e $f ]
        then
            echo "Moving existing $f -> $f.bkp..."
            mv $f $f.bkp
        fi
    done
}

url=https://raw.githubusercontent.com/TheLocehiliosan/yadm/$YADM_VERSION/yadm
install_location=$HOME/.local/bin
yadm=$install_location/yadm

install_yadm
backup_dotfiles
install_dotfiles
