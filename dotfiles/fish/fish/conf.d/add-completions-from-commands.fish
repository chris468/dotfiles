function __fish_complete_aws
    env COMP_LINE=(commandline -pc) aws_completer | tr -d ' '
end

type -q helm ; and helm completion fish | source
type -q kubectl; and kubectl completion fish | source
type -q aws_completer; and complete -c aws -f -a "(__fish_complete_aws)"
