let g:showmarks_marks = 'abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ{}()[]<>^''".'

augroup showmarks
    au!
    autocmd BufEnter * DoShowMarks
augroup end

