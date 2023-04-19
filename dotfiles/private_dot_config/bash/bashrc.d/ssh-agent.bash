# based on https://unix.stackexchange.com/questions/132065/how-do-i-get-ssh-agent-to-work-in-all-terminals/132117#132117

export SSH_AUTH_SOCK=~/.ssh/.socket
ssh-add -l >/dev/null 2>&1
if [ $? -ge 2 ]
then
     rm -f $SSH_AUTH_SOCK && ssh-agent -t 14400 -a $SSH_AUTH_SOCK >/dev/null
fi
