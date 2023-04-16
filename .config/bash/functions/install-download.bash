function install-download {
  uri="$1"
  name="$2"
  version="$3"
  link_src="$4"
  link_dest="$5"

  dest="$LOCAL_OPT/$name/$version"

  function unpack {
    case "$uri" in
      *.tar.gz | *.tgz) tar -C "$dest" -xz ;;
      *) cat > "$dest/$name" && chmod +x "$dest/$name" ;;
    esac
  }

  mkdir -p "$dest"

  download "$uri" | unpack

  if [ -n "$link_src" ] && [ -n "$link_dest" ]
  then
    ln -sf "$dest/$link_src" "$LOCAL_OPT/$link_dest"
  fi
}
