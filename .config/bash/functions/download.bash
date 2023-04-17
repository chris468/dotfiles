function download {
  set -x
  curl --progress-bar -L "$@"
}
