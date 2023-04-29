'$params="-BinDir `"$(Join-Path $env:TEMP $(New-Guid))`" init --apply --branch chezmoi chris468 $params"', `
  (Invoke-RestMethod -UseBasicParsing https://get.chezmoi.io/ps1) | pwsh -c -
