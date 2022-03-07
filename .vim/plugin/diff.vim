" Disable moving to last line when opening in diff mode
if &diff
    augroup vimStartup | au! | augroup END
endif
