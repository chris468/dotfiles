#!/usr/bin/bash

KUBECTL_VERSION=v1.25.0
KUBECTL_URI="https://dl.k8s.io/release/$KUBECTL_VERSION/bin/linux/amd64/kubectl"

if [ "$1" == "--install" ]
then
  install-download "$KUBECTL_URI" kubectl "$KUBECTL_VERSION" kubectl bin/kubectl
fi
