function install-tools {
  for f in ~/.config/bash/bashrc.d/install/*.bash
  do
    echo installing $f...
    . $f --install || return 1
  done
}
