$env:SCOOP="$HOME/.local/opt/scoop"
if (!(Get-Command scoop 2>$null)) {
  Write-Host "Installing scoop..."
  Set-ExecutionPolicy RemoteSigned -Scope CurrentUser
  Invoke-RestMethod https://get.scoop.sh | Invoke-Expression
}

Write-Host "Installing git..."
& $env:SCOOP\shims\scoop.ps1 install git

'$params="-BinDir `"$HOME\.local\opt\bin`" init --apply chris468 $params"', `
  (Invoke-RestMethod -UseBasicParsing https://get.chezmoi.io/ps1) | pwsh -c -
