HELM_VERSION="v3.11.3"
HELM_URI="https://get.helm.sh/helm-$HELM_VERSION-linux-arm64.tar.gz"

if [ "$1" == "--install" ]
then
  install-download "$HELM_URI" helm "$HELM_VERSION" linux-arm64/helm bin/helm
fi
