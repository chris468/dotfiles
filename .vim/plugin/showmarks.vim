let g:showmarks_marks = 'abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ[]<>^''".'

function s:showmarks()
    if exists('loaded_showmarks')
        DoShowMarks
    end
endfunction

augroup showmarks
    au!
    autocmd BufEnter * call s:showmarks()
augroup end

