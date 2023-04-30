'$params="-BinDir `"$HOME\.local\opt\bin`" init --apply chris468 $params"', `
  (Invoke-RestMethod -UseBasicParsing https://get.chezmoi.io/ps1) | pwsh -c -
