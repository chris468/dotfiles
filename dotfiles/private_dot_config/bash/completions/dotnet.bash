# bash parameter completion for the dotnet CLI

function _dotnet_bash_complete()
{
  if command -v dotnet &> /dev/null
  then
    local cur="${COMP_WORDS[COMP_CWORD]}" IFS=$'\n'
    local candidates

    read -d '' -ra candidates < <(dotnet complete --position "${COMP_POINT}" "${COMP_LINE}" 2>/dev/null)

    read -d '' -ra COMPREPLY < <(compgen -W "${candidates[*]:-}" -- "$cur")
  fi
}

complete -f -F _dotnet_bash_complete dotnet
