function install-azure-cli {
  PIPX_HOME="$LOCAL_OPT/pipx" PIPX_BIN="$LOCAL_OPT/bin" pipx install azure-cli
}

if [ "$1" == "--install" ]
then
  install-azure-cli
fi

if command -v az &> /dev/null
then
  . az.completion.sh
fi
