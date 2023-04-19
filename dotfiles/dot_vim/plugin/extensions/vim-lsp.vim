let g:lsp_preview_float = 0
let g:lsp_diagnostics_float_cursor = 1
let g:lsp_diagnostics_echo_cursor = 1
let g:lsp_document_highlight_enabled = 1

function s:start_pylsp()
    if findfile('poetry.lock') isnot# ''
        return ['poetry', 'run', 'pylsp']
    endif

    return ['pylsp']
endfunction

let g:lsp_settings = {
\ 'pylsp-all': {
\   'cmd': {server_info->s:start_pylsp()},
\   'workspace_config': {
\     'pylsp': {
\       'configurationSources': [ 'flake8' ]
\     }
\   }
\ }
\}

" logging
" let g:lsp_log_file = expand('~/.cache/vim-lsp.log')
