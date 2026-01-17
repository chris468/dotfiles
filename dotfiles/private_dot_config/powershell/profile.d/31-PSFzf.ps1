if (Get-Command fzf 2>$null) {
  Import-Module PSFzf 2>$null
  if ($?) {
    Set-PsFzfOption -PSReadlineChordProvider 'Ctrl+t' -PSReadlineChordReverseHistory 'Ctrl+r'
  }
}
