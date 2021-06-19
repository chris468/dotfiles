nnoremap <leader>et :NERDTreeToggle<CR> " Explorer Toggle
nnoremap <leader>ef :NERDTreeFocus<CR> " Explorer Focus

function s:has_no_arguments()
    return argc() == 0
endfunction

function s:has_single_directory_argument()
    return argc() == 1 && isdirectory(argv()[0])
endfunction

function s:show_explorer_on_launch()
    if exists('s:std_in') || v:this_session != ''
        return
    endif

    if s:has_no_arguments()
        NERDTree
        wincmd p
    endif

    if s:has_single_directory_argument()
        execute 'NERDTree' argv()[0]
        wincmd p
        enew
        execute 'cd '.argv()[0]
    endif
endfunction

let s:nerd_tree_pattern='NERD_tree_\d\+'

function s:last_showed_explorer()
    return bufname('#') =~ s:nerd_tree_pattern
endfunction

function s:showing_explorer()
    return bufname('%') =~ s:nerd_tree_pattern
endfunction

function s:multiple_windows()
    return winnr('$') > 1
endfunction

function s:prevent_replacing_explorer()
    if s:last_showed_explorer() && !s:showing_explorer() && s:multiple_windows()
        let l:buf=bufnr()
        buffer#
        execute "normal! \<C-W>w"
        execute 'buffer'.buf
    endif
endfunction

function s:exit_when_only_explorer_remains()
    if tabpagenr('$') == 1 && winnr('$') == 1 && exists('b:NERDTree') && b:NERDTree.isTabTree()
        quit
    endif
endfunction

autocmd StdinReadPre * let s:std_in=1
autocmd VimEnter * call s:show_explorer_on_launch()
autocmd BufEnter * call s:prevent_replacing_explorer()
autocmd BufEnter * call s:exit_when_only_explorer_remains()
