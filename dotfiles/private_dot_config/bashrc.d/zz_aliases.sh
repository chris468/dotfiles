function _chk() {
  command -v "$1" &>/dev/null
}

alias grep='grep --color=auto'
alias fgrep='fgrep --color=auto'
alias egrep='egrep --color=auto'

if _chk lsd; then
  alias ls='lsd --color=auto'
elif _chk gls; then
  alias ls='gls --color=auto'
else
  alias ls='ls --color=auto'
fi

! _chk batcat || alias cat=batcat
! _chk bat || alias cat=bat

unset -f _chk
