if !has('win32')
    finish
endif

if executable('pwsh')
    set shell=pwsh
elseif executable('powershell')
    set shell=powershell
endif
