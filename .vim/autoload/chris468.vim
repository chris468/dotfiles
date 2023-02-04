function! chris468#restore_relative_line_numbers(target)
    echo('again')
    let current=winnr()
    execute a:target . 'windo set relativenumber'
    execute current . 'wincmd w'
endfunction

function! chris468#temporarily_show_absolute_line_numbers()
    echo('hi')
    let target=winnr()
    set norelativenumber
    call timer_start(2000, {-> chris468#restore_relative_line_numbers(target) })
endfunction


