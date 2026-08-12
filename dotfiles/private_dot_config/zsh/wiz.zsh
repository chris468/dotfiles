if command -v wizcli &>/dev/null; then
  autoload -U +X bashcompinit && bashcompinit
  complete -o nospace -C /home/chris/.local/bin/wiz wizcli
fi
