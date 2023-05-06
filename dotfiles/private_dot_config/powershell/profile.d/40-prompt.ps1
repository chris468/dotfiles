function Script:On-VIModeChange {
    if ($args[0] -eq 'Command') {
        # Set the cursor to a blinking block.
        Write-Host -NoNewLine "`e[1 q"
    } else {
        # Set the cursor to a blinking line.
        Write-Host -NoNewLine "`e[5 q"
    }
}

function Script:Configure-PSReadline {
    Set-PSReadLineOption -Editmode vi
    Set-PSReadLineOption -ViModeIndicator Script -ViModeChangeHandler ${Function:On-VIModeChange}
    Set-PSReadLineOption -HistorySavePath "$HOME/.cache/pwsh/history.txt"
}


function Initialize-InteractiveSession {
    if (! $global:InteractiveSession ) {
        $global:InteractiveSession = $true

        Configure-PSReadLine
    }
}

if (Get-Command oh-my-posh 2>&1 | Out-Null) {
    New-Alias -Name 'Set-PoshContext' -Value 'Initialize-InteractiveSession' -Scope Global -Force

    $theme = "$config_dir/oh-my-posh/current-theme.omp.json"
    oh-my-posh init pwsh --config $theme | Invoke-Expression
} else {
    Initialize-InteractiveSession
}
