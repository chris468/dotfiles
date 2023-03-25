function! chris468#restore_relative_line_numbers(target)
    let current=winnr()
    execute a:target . 'windo set relativenumber'
    execute current . 'wincmd w'
endfunction

function! chris468#temporarily_show_absolute_line_numbers()
    let target=winnr()
    set norelativenumber
    call timer_start(2000, {-> chris468#restore_relative_line_numbers(target) })
endfunction

function! chris468#focus_window(name)
    let target=bufwinnr(a:name)
    if target > 0
        execute target . 'wincmd w'
    endif
endfunction
