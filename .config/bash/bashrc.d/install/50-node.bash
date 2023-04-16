#!/usr/bin/bash

NVM_VERSION="v0.39.3"
NVM_DIR="$LOCAL_OPT/nvm"

if [ "$1" == "--install" ]
then
  mkdir -p "$NVM_DIR"

  curl -o- https://raw.githubusercontent.com/nvm-sh/nvm/$NVM_VERSION/install.sh \
    | NVM_DIR="$NVM_DIR" PROFILE=/dev/null bash
fi

[ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh"  # This loads nvm
[ -s "$NVM_DIR/bash_completion" ] && \. "$NVM_DIR/bash_completion"  # This loads nvm bash_completion

if [ "$1" == "--install" ]
then
  nvm install --lts
  nvm use --lts
fi
