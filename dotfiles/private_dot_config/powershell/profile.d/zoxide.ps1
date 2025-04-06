if (Get-Command zoxide 2>$null) {
  Invoke-Expression (& { (zoxide init powershell | Out-String) })
}
