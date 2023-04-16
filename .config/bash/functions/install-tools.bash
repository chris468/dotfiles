function install-tools {
  for f in ~/.config/bash/tools/*.bash
  do
    echo installing $f...
    . $f --install || return 1
  done
}
