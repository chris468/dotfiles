let s:languages = {
    \ 'vim':    'npm install --global vim-language-server',
    \ 'python': 'pip install python-lsp-server pylsp-mypy flake8'
\ }

function s:install_language_support(name)
    if !has_key(s:languages, a:name)
        echo 'Unknown server "' . a:name . '".'
    else
        echo 'Installing ' . a:name . ' language support...'
        echo 'Running "' .s:languages[a:name] . '"...'
        silent let l:result = system(s:languages[a:name])
        echo l:result
        if v:shell_error
            echo "\n". a:name . ' language support install failed.'
        else
            echo "\n". a:name . ' language support installed.'
        endif
    endif
endfunction

command! -nargs=1 InstallLanguageSupport call <SID>install_language_support(<f-args>)
