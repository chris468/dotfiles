if (Get-Command oh-my-posh 2>$null) {
    oh-my-posh init pwsh --config $HOME\.config\oh-my-posh\chris468.omp.yaml --eval | Invoke-Expression
}

function Set-PoshParameters {
    $env:POSH_WIDE = if ($Host.UI.RawUI.WindowSize.Width -ge 90) { 1 } else { 0 }
}

New-Alias -Name 'Set-PoshContext' -Value 'Set-PoshParameters' -Scope Global -Force
