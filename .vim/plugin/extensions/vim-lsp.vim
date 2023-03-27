let g:lsp_log_file = expand('~/vim-lsp.log')

function s:start_pylsp()
    if findfile('poetry.lock') isnot# ''
        echom 'poetry'
        return ['poetry', 'run', 'pylsp']
    endif

    echom 'normal'
    return ['pylsp']
endfunction

let g:lsp_settings = {
\ 'pylsp-all': {
\   'cmd': {server_info->s:start_pylsp()},
\   'workspace_config': {
\     'pylsp': {
\       'plugins': {
\         'pycodestyle': { 'enabled': v:false },
\         'pyflakes': { 'enabled': v:false },
\         'mccabe': { 'enabled': v:false },
\         'flake8': { 'enabled': v:true },
\       },
\       'configurationSources': [ 'flake8' ]
\     }
\   }
\ }
\}
