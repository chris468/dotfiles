function s:find_files(check_for_git)
    let root = FindRootDirectory()
    echom 'root' root
    if a:check_for_git && !empty(glob('.git'))
        execute 'GFiles' root
    else
       execute 'Files' root
   endif
endfunction

nmap <silent> <leader>f :call <SID>find_files(1)<CR>
nmap <silent> <leader>F :call <SID>find_files(0)<CR>
