# Append history instead of overwriting
# https://www.gnu.org/software/bash/manual/html_node/The-Shopt-Builtin.html'
shopt -s histappend

# Ignore duplicates and commands that start with a space
# https://www.gnu.org/software/bash/manual/html_node/Bash-Variables.html
export HISTCONTROL=ignoreboth

# Immediately append to history file
export PROMPT_COMMAND="history -a; $PROMPT_COMMAND"
