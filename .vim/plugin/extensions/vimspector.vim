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

nmap <leader>vg           <Plug>VimspectorContinue
nmap <leader>vs           <Plug>VimspectorStop
nmap <leader>vr           <Plug>VimspectorRestart
nmap <leader>vp           <Plug>VimspectorPause
" nmap <leader><F8>         <Plug>VimspectorJumpToNextBreakpoint
" nmap <leader><S-F8>       <Plug>VimspectorJumpToPreviousBreakpoint
nmap <leader>vb           <Plug>VimspectorToggleBreakpoint
" nmap <leader><S-F9>       <Plug>VimspectorAddFunctionBreakpoint
nmap <leader>o            <Plug>VimspectorStepOver
nmap <leader>i            <Plug>VimspectorStepInto
nmap <leader>u            <Plug>VimspectorStepOut
" nmap <leader><M-8>        <Plug>VimspectorDisassemble
nmap <leader>vk            <Plug>VimspectorUpFrame
nmap <leader>vj            <Plug>VimspectorDownFrame
nmap <leader>vv            <Plug>VimspectorBalloonEval
xmap <leader>vv            <Plug>VimspectorBalloonEval
nmap <leader>vx            :call vimspector#Reset( {'interactive': v:false } )<CR>
nmap <leader>vc            <Plug>VimspectorJumpToProgramCounter
