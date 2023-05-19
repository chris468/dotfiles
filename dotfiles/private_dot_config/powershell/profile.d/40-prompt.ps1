if (Get-Command oh-my-posh 2>$null) {
    oh-my-posh init pwsh | Invoke-Expression
}
