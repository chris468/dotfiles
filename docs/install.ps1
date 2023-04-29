'$params="-BinDir `"$(Join-Path $env:TEMP $(New-Guid))`" init --apply chris468 $params"', `
  (Invoke-RestMethod -UseBasicParsing https://get.chezmoi.io/ps1) | pwsh -c -
