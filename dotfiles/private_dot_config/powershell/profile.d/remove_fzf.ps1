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

Set-PSReadLineKeyHandler -Chord "ctrl+r" -ScriptBlock {
  $line = $null
  $cursor = $null
  [Microsoft.PowerShell.PSConsoleReadLine]::GetBufferState([ref]$line, [ref]$cursor)
  if ($result = Select-HistoryItem -Line $line) {
    [Microsoft.PowerShell.PSConsoleReadLine]::RevertLine()
    [Microsoft.PowerShell.PSConsoleReadLine]::Insert($result)
  }
}
