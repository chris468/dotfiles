#!/usr/bin/bash

K9S_VERSION="v0.27.3"
K9S_DESTINATION="$HOME/.local/opt/k9s/$K9S_VERSION"
K9S_LINK="$HOME/.local/bin/k9s"

if [ "$1" == "--install" ]
then
  mkdir -p "$K9S_DESTINATION"

  curl -L https://github.com/derailed/k9s/releases/download/$K9S_VERSION/k9s_Linux_amd64.tar.gz \
    | tar -C "$K9S_DESTINATION" -xz

  ln -sf "$K9S_DESTINATION/k9s" "$K9S_LINK"
fi
