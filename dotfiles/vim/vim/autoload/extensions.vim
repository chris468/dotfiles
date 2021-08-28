let s:vim_plug_path = expand('<sfile>:p:h') . '/../plugged'

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
        Plug 'vim-syntastic/syntastic'

        " specific language support
        Plug 'elixir-editors/vim-elixir'


        if has('python3')
            Plug 'puremourning/vimspector'
        endif

    call plug#end()

endfunction

