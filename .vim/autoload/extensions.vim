let s:vim_plug_path = expand('<sfile>:p:h') . '/../.extensions'

function! extensions#load()

    call plug#begin(s:vim_plug_path)

        " Register vim-plug in order to automatically install help.
        " https://github.com/junegunn/vim-plug/wiki/tips#vim-help
        Plug 'junegunn/vim-plug'

        " colors
        Plug 'dracula/vim'

        " general utilities
        Plug 'tpope/vim-surround'
        Plug 'tommcdo/vim-exchange'
        Plug 'jacquesbh/vim-showmarks'

        " file explorer
        Plug 'preservim/nerdtree'

        " core ide utilities
        Plug 'junegunn/fzf', { 'do': { -> fzf#install() } }
        Plug 'junegunn/fzf.vim'
        Plug 'prabirshrestha/asyncomplete.vim'

        Plug 'dense-analysis/ale'
        Plug 'airblade/vim-rooter'

        " Languages
        Plug 'OmniSharp/omnisharp-vim'
        Plug 'hashivim/vim-terraform'
        Plug 'digitaltoad/vim-pug'

        " git
        Plug 'tpope/vim-fugitive'

        if has('python3')
            Plug 'puremourning/vimspector'
        endif

    call plug#end()

endfunction

