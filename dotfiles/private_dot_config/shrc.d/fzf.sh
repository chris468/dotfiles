if [[ -n "$BASH_VERSION" && -f ~/.config/fzf/fzf.bash ]]
then
  source ~/.config/fzf/fzf.bash
elif [[ -n "$ZSH_VERSION" && -f ~/.config/fzf/fzf.zsh ]]
then
  source ~/.config/fzf/fzf.zsh
fi
