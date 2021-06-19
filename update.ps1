function has_updates {
    git -C $PSScriptRoot fetch origin
    git -C $PSScriptRoot status --porcelain -b | select-string -quiet "\[behind"
}

if ( has_updates ) {
    Write-Host "dotfiles are out of date. Updating..."
    git -C $PSScriptRoot pull
    & $PSScriptRoot\configure-all.ps1 -quiet
}
else {
    Write-Host "dotfiles are up to date."
}
