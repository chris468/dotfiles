function prepend-path {
  if [ -z "$1" ];
  then
    return 
  fi

  case "$PATH" in
    *$1:*) true ;;
    *) PATH="$1:$PATH"
  esac
}
