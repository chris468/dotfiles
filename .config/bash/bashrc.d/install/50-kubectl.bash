#!/usr/bin/bash

KUBECTL_VERSION=v1.25.0
KUBECTL_DESTINATION="$HOME/.local/opt/bin/kubectl-$KUBECTL_VERSION"
KUBECTL_LINK="$HOME/.local/opt/bin/kubectl"

if [ "$1" == "--install" ]
then
  curl -L https://dl.k8s.io/release/$KUBECTL_VERSION/bin/linux/amd6/kubectl -O "$KUBECTL_DESTINATION"
  ln -sfr "$KUBECTL_DESTINATION" "$KUBECTL_LINK"
fi
