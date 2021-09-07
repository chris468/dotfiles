set signcolumn=yes

if (has('win32'))
    set encoding=utf-8
endif

let g:vimspector_enable_mappings = 'VISUAL_STUDIO'

" Prioritize breakpoint signs over vim-lsp diagnostic signs
let g:vimspector_sign_priority = {
  \    'vimspectorBP':         33,
  \    'vimspectorBPCond':     32,
  \    'vimspectorBPDisabled': 31,
  \ }


" Don't require explicit selection
let g:asyncomplete_auto_completeopt = 0
set completeopt=menuone,noinsert

" Require at least 1 character before showing the popup
let g:asyncomplete_min_chars = 1

" Show fold indication
set foldcolumn=2

" Open files with all folds expanded
set foldlevelstart=99

" Preserve fold levels
" https://stackoverflow.com/questions/37552913/vim-how-to-keep-folds-on-save
set viewoptions=folds
augroup remember_folds
  autocmd!
  autocmd BufWinLeave * silent! mkview
  autocmd BufWinEnter * silent! loadview
augroup END

let g:rooter_patterns = ['.git', 'package.json', '*.sln']
let g:rooter_manual_only = 1

function s:find_files()
    let root = FindRootDirectory()
    echom 'root' root
    if !empty(glob('.git'))
        execute 'GFiles' root
    else
       execute 'Files' root
   endif
endfunction

nmap <silent> <leader>f :call <SID>find_files()<CR>
