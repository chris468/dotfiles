let s:vim_plug_path = expand('<sfile>:p:h') . '/../plugged'

function! extensions#load()

    call plug#begin(s:vim_plug_path)

        " Register vim-plug in order to automatically install help.
        " https://github.com/junegunn/vim-plug/wiki/tips#vim-help
        Plug 'junegunn/vim-plug'

        Plug 'dracula/vim'

        Plug 'tpope/vim-surround'
        Plug 'ctrlpvim/ctrlp.vim'
        Plug 'preservim/nerdtree'

        Plug 'prabirshrestha/vim-lsp'
        Plug 'mattn/vim-lsp-settings'
        Plug 'prabirshrestha/asyncomplete.vim'
        Plug 'prabirshrestha/asyncomplete-lsp.vim'

        if has('python3')
            Plug 'puremourning/vimspector'
        endif

    call plug#end()

endfunction

