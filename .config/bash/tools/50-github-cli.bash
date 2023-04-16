GITHUB_CLI_VERSION="2.27.0"
GITHUB_CLI_DIR="gh_${GITHUB_CLI_VERSION}_linux_amd64"
GITHUB_CLI_URL="https://github.com/cli/cli/releases/download/v$GITHUB_CLI_VERSION/${GITHUB_CLI_DIR}.tar.gz"

function install-github-cli {
  install-download "$GITHUB_CLI_URL" github-cli "$GITHUB_CLI_VERSION"
}

if [ "$1" == "--install" ]
then
  install-github-cli
fi

GITHUB_CLI_BIN="$(installed-download-destination github-cli $GITHUB_CLI_VERSION)/$GITHUB_CLI_DIR/bin"
if [ -d "$GITHUB_CLI_BIN" ]
then
  # add to path instead of linking so that the man page will be found
  prepend-path "$GITHUB_CLI_BIN"
fi
