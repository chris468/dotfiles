let s:path = fnamemodify(resolve(expand('<sfile>:p')), ':h:h:h') . '/netrw-fix'
"echom s:path

if v:version < 802
    exe 'set runtimepath^=' . s:path
endif

