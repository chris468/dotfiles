let g:lsp_diagnostics_float_cursor = 1
let g:lsp_diagnostics_highlights_enabled = 0
let g:lsp_settings = { 'pylsp-all': { 'workspace_config': { 'pylsp': { 'configurationSources': ['flake8'] }}}}
let g:lsp_settings_root_markers = [
\   '.git',
\   '.git/',
\   'pyproject.toml'
\    ]
