Param([switch]$force=$false, $statusFile)

function Run-Git {
    git -C $PSScriptRoot $args
    $result = $LASTEXITCODE
    if ($result -ne 0) {
        throw "Git exited with code $result"
    }
}

function has_updates {
    Run-Git fetch origin
    Run-Git status --porcelain -b | select-string -quiet "\[behind"
}

try {
    if ( has_updates ) {
        Write-Output "dotfiles are out of date. Updating..."
        $mode = $force ? "-force" : "-quiet"
        Run-Git pull
        & $PSScriptRoot\configure-all.ps1 $mode
        if ( $statusFile ) {
            Set-Content $statusFile "dotfiles updated on $(Get-Date -Format f)"
        }
    }
    else {
        Write-Output "dotfiles are up to date."
        if ( $statusFile ) {
            Set-Content $statusFile "dotfiles were up to date when checked on $(Get-Date -Format f)"
        }
    }
}
catch {
    if  ( $statusFile ) {
        Set-Content $statusFile "failed to update dotfiles on $(Get-Date -Format f). Error: $_"
    }
    else {
        throw
    }
}

