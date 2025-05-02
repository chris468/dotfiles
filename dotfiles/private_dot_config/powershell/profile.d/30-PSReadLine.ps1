function Script:On-VIModeChange {
    if ($args[0] -eq 'Command') {
        # Set the cursor to a blinking block.
        Write-Host -NoNewLine "`e[1 q"
    } else {
        # Set the cursor to a blinking line.
        Write-Host -NoNewLine "`e[5 q"
    }
}

function script:Get-UniqueItems {
  begin {
    $seen = [System.Collections.Generic.HashSet[string]]::new()
  }
  process {
    $trimmed = $_.Trim()
    if ($seen.Add($trimmed)) { $trimmed }
  }
}

function script:Get-UniqueHistory {
  [Microsoft.PowerShell.PSConsoleReadLine]::GetHistoryItems().CommandLine | Get-UniqueItems
}

function script:Select-HistoryItem {
  param([string]$Line)
  Get-UniqueHistory | fzf --query=$Line
}

Set-PSReadLineOption -Editmode vi
Set-PSReadLineOption -ViModeIndicator Script -ViModeChangeHandler ${Function:On-VIModeChange}
Set-PSReadLineOption -HistorySavePath "$HOME/.cache/pwsh/history.txt"
Set-PSReadLineKeyHandler -Chord "ctrl+r" -ScriptBlock {
  $line = $null
  $cursor = $null
  [Microsoft.PowerShell.PSConsoleReadLine]::GetBufferState([ref]$line, [ref]$cursor)
  if ($result = Select-HistoryItem -Line $line) {
    [Microsoft.PowerShell.PSConsoleReadLine]::RevertLine()
    [Microsoft.PowerShell.PSConsoleReadLine]::Insert($result)
  }
}
