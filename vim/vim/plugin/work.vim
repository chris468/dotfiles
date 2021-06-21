if !exists("g:work")
    finish
endif

autocmd Filetype cpp setlocal noet
autocmd Filetype h setlocal noet
autocmd Filetype c setlocal noet

packadd vim-elixir
