function install-register-python-argcomplete {
  PIPX_HOME="$LOCAL_OPT/pipx" PIPX_BIN="$LOCAL_OPT/bin" pipx install argcomplete
}

if [ "$1" == "--install" ]
then
  install-register-python-argcomplete
fi
