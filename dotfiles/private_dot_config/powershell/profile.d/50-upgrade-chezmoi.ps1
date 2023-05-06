function Upgrade-Chezmoi {
    $local:last_chezmoi_upgrade="$HOME/.cache/dotfiles/last-chezmoi-upgrade"
    $local:yesterday = ((Get-Date).Date - (New-TimeSpan -Days 1))

    if (! (Test-Path $last_chezmoi_upgrade -NewerThan $yesterday)) {
        & $HOME/.local/opt/bin/chezmoi.exe upgrade `
         && New-Item -Force -Type Directory -Path (Split-Path $last_chezmoi_upgrade) | Out-Null `
         && Set-Content -Force -Path $last_chezmoi_upgrade -Value ""
    }
}

Upgrade-Chezmoi
