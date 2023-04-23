function install-tools {
  for f in ~/.config/bash/tools/*.bash
  do
    bash $f || return 1
  done
}
