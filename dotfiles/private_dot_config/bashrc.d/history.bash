# Append history instead of overwriting
# https://www.gnu.org/software/bash/manual/html_node/The-Shopt-Builtin.html'
shopt -s histappend

# Ignore duplicates and commands that start with a space
# https://www.gnu.org/software/bash/manual/html_node/Bash-Variables.html
export HISTCONTROL=ignoreboth

# for setting history length see HISTSIZE and HISTFILESIZE in bash(1)
HISTSIZE=1000
HISTFILESIZE=2000
