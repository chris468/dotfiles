export RUSTUP_HOME="$LOCAL_OPT/rustup"
CARGO_HOME="$LOCAL_OPT/cargo"

if [ "$1" == "--install" ]
then
  curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs \
    | RUSTUP_HOME=$RUSTUP_HOME CARGO_HOME=$CARGO_HOME sh -s -- -y --no-modify-path
fi

[ -s "$CARGO_HOME/env" ] && \. "$CARGO_HOME/env"
