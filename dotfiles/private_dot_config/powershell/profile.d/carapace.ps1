if (Get-Command oh-my-posh 2>$null) {
    $env:CARAPACE_BRIDGES = 'zsh,fish,bash,powershell'
    # Set-PSReadLineOption -Colors @{ "Selection" = "`e[7m" }
    Set-PSReadlineKeyHandler -Key Tab -Function MenuComplete
    carapace _carapace | Out-String | Invoke-Expression
}
