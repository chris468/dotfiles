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

nmap <silent> <leader>vg           <Plug>VimspectorContinue
nmap <silent> <leader>vs           <Plug>VimspectorStop
nmap <silent> <leader>vr           <Plug>VimspectorRestart
nmap <silent> <leader>vp           <Plug>VimspectorPause
" nmap <silent> <leader><F8>         <Plug>VimspectorJumpToNextBreakpoint
" nmap <silent> <leader><S-F8>       <Plug>VimspectorJumpToPreviousBreakpoint
nmap <silent> <leader>vb           <Plug>VimspectorToggleBreakpoint
" nmap <silent> <leader><S-F9>       <Plug>VimspectorAddFunctionBreakpoint
nmap <silent> <leader>o            <Plug>VimspectorStepOver
nmap <silent> <leader>i            <Plug>VimspectorStepInto
nmap <silent> <leader>u            <Plug>VimspectorStepOut
" nmap <silent> <leader><M-8>        <Plug>VimspectorDisassemble
nmap <silent> <leader>vk            <Plug>VimspectorUpFrame
nmap <silent> <leader>vj            <Plug>VimspectorDownFrame
nmap <silent> <leader>vv            <Plug>VimspectorBalloonEval
xmap <silent> <leader>vv            <Plug>VimspectorBalloonEval
nmap <silent> <leader>vx            :call vimspector#Reset( {'interactive': v:false } )<CR>
nmap <silent> <leader>vc            <Plug>VimspectorJumpToProgramCounter
nmap <silent> <leader>vwo           :VimspectorShowOutput<CR>
nmap <silent> <leader>vws           :call chris468#focus_window('vimspector.StackTrace')<CR>
nmap <silent> <leader>vww           :call chris468#focus_window('vimspector.Watches')<CR>
nmap <silent> <leader>vwv           :call chris468#focus_window('vimspector.Variables')<CR>
