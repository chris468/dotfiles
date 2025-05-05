NPM_PACKAGES="${HOME}/.local/share/npm-packages"
if [[ $PATH != *:$NPM_PACKAGES/bin* ]] && [[ -d $NPM_PACKAGES/bin ]]; then
  export PATH="$PATH:$NPM_PACKAGES/bin"
  export MANPATH="${MANPATH-$(manpath)}:$NPM_PACKAGES/share/man"
fi
