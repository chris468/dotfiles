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
        if g:enable_asyncomplete
            Plug 'prabirshrestha/asyncomplete.vim'
        endif
        if g:enable_coc
            Plug 'neoclide/coc.nvim', {'branch': 'release'}
        endif

        Plug 'airblade/vim-rooter'

        " Languages
        if g:enable_omnisharp
            Plug 'OmniSharp/omnisharp-vim'
        endif

        if g:enable_vim_lsp
            Plug 'prabirshrestha/vim-lsp'
            Plug 'mattn/vim-lsp-settings'
        endif

        if g:enable_ale
            Plug 'dense-analysis/ale'
            Plug 'digitaltoad/vim-pug'
            Plug 'jlcrochet/vim-razor'
        endif

        Plug 'hashivim/vim-terraform'

        " git
        Plug 'tpope/vim-fugitive'
        Plug 'airblade/vim-gitgutter'
        Plug 'jreybert/vimagit'

        if has('python3')
            Plug 'puremourning/vimspector'
        endif

    call plug#end()

endfunction

