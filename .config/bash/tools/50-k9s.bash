K9S_VERSION="v0.27.3"
K9S_URI="https://github.com/derailed/k9s/releases/download/$K9S_VERSION/k9s_Linux_amd64.tar.gz"

if [ "$1" == "--install" ]
then
  install-download $K9S_URI k9s "$K9S_VERSION" k9s bin/k9s
fi
