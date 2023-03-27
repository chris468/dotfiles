if ! g:enable_ale
    finish
endif

let g:ale_python_pylsp_auto_poetry=1

let g:ale_linters = {
    \'python': ['pylsp']
\}

let g:ale_python_pylsp_config = {
    \'pylsp': {
        \'plugins': {
            \'pycodestyle': { 'enabled': v:false },
            \'mccabe': { 'enabled': v:false },
            \'pyflakes': { 'enabled': v:false },
            \'flake8': { 'enabled': v:true },
        \},
        \'configurationSources': [ 'flake8' ]
    \},
\}

let g:ale_fixers = {
\   'terraform': ['terraform']
\}

" Use ALE's function for asyncomplete defaults
augroup AleSetup
    autocmd!
    autocmd User asyncomplete_setup call asyncomplete#register_source(asyncomplete#sources#ale#get_source_options())
augroup end
