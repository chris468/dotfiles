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

      " if executable('node')
      "     Plug 'neoclide/coc.nvim', { 'branch': 'release' }
      " endif
      "

      " Plug 'prabirshrestha/vim-lsp'
      " Plug 'mattn/vim-lsp-settings'

        Plug 'dense-analysis/ale'
        Plug 'airblade/vim-rooter'

        if has('python3')
            Plug 'SirVer/ultisnips'
            Plug 'honza/vim-snippets'
            Plug 'prabirshrestha/asyncomplete-ultisnips.vim'
        end

        " specific language support
        Plug 'elixir-editors/vim-elixir'

        " C#
      " Plug 'OmniSharp/omnisharp-vim'

        " git
        Plug 'tpope/vim-fugitive'

        if has('python3')
            Plug 'puremourning/vimspector'
        endif

    call plug#end()

endfunction

