if exists('g:asyncomplete_loaded')
    call asyncomplete#register_source(asyncomplete#sources#ultisnips#get_source_options({}))
endif

let g:UltiSnipsExpandTrigger='<tab>'
let g:UltiSnipsJumpForwardTrigger='<tab>'
let g:UltiSnipsJumpBackwardTrigger='<s-tab>'
