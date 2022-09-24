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
