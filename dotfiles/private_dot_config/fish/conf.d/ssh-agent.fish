# based on https://unix.stackexchange.com/questions/132065/how-do-i-get-ssh-agent-to-work-in-all-terminals/132117#132117

set -x SSH_AUTH_SOCK ~/.ssh/.socket
ssh-add -l >/dev/null 2>&1
test $status -ge 2 ; \
   and rm -f $SSH_AUTH_SOCK ; \
   and ssh-agent -t 14400 -a $SSH_AUTH_SOCK >/dev/null
