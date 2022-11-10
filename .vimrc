" Note:
"  - extension configuration is in .vim/autoload/extension.vim
"  - configuration to run before extensions load is in .vim/plugin
"  - configuration to run after extension load is in .vim/after/plugin
"

call extensions#load()

source $VIMRUNTIME/defaults.vim
let mapleader = " "

" Decrease update time to make gitgutter show up more quickly
set updatetime=250
