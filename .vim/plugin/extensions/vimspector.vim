let g:vimspector_enable_mappings = 'VISUAL_STUDIO'

" Prioritize breakpoint signs over vim-lsp diagnostic signs
let g:vimspector_sign_priority = {
  \    'vimspectorBP':         33,
  \    'vimspectorBPCond':     32,
  \    'vimspectorBPDisabled': 31,
  \ }

" ensure menus show up
if &mouse !~ 'a\|n'
    set mouse+=n
endif
