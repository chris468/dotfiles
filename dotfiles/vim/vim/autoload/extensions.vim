let s:vim_plug_path = expand('<sfile>:p:h') . '/../plugged'

function! extensions#load()

    call plug#begin(s:vim_plug_path)

        " Register vim-plug in order to automatically install help.
        " https://github.com/junegunn/vim-plug/wiki/tips#vim-help
        Plug 'junegunn/vim-plug'

        Plug 'dracula/vim'

        Plug 'tpope/vim-surround'
        Plug 'tommcdo/vim-exchange'
        Plug 'ctrlpvim/ctrlp.vim'
        Plug 'preservim/nerdtree'

        Plug 'prabirshrestha/asyncomplete.vim'
        Plug 'elixir-editors/vim-elixir'

        Plug 'jacquesbh/vim-showmarks'

        if has('python3')
            Plug 'puremourning/vimspector'
        endif

    call plug#end()

endfunction

