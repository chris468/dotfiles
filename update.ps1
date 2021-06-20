Param([switch]$force=$false, $statusFile)

function has_updates {
    git -C $PSScriptRoot fetch origin
    git -C $PSScriptRoot status --porcelain -b | select-string -quiet "\[behind"
}

if ( has_updates ) {
    Write-Host "dotfiles are out of date. Updating..."
    $mode = $force ? "-force" : "-quiet"
    git -C $PSScriptRoot pull
    & $PSScriptRoot\configure-all.ps1 $mode
    if ( $statusFile ) {
        Set-Content $statusFile "dotfiles updated on $(Get-Date -Format f)"
    }
}
else {
    Write-Host "dotfiles are up to date."
    if ( $statusFile ) {
        Set-Content $statusFile "dotfiles were up to date when checked on $(Get-Date -Format f)"
    }
}
