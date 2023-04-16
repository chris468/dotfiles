function install-aws {
  local aws_download
  aws_download=$(mktemp -d)
  download "https://awscli.amazonaws.com/awscli-exe-linux-x86_64.zip" -o "$aws_download/awscliv2.zip"
  (cd $aws_download && \
    unzip -q awscliv2.zip && \
    ./aws/install --install-dir "$LOCAL_OPT/aws" --bin-dir "$LOCAL_OPT/bin" "$@")
}

if [ "$1" == "--install" ]
then
  install_aws
fi

if command -v aws_completer &> /dev/null
then
    complete -C aws_completer aws
fi



