autocmd Filetype cpp setlocal noet
autocmd Filetype h setlocal noet
autocmd Filetype c setlocal noet

function s:set_yaml_tabs()
    autocmd Filetype yaml set ts=4 sw=4 sts=4
endfunction

autocmd BufRead,BufNewFile,BufEnter */Infrastructure/* call s:set_yaml_tabs()
