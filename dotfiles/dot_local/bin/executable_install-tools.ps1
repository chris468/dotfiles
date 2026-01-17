winget import `
  --import-file "$env:XDG_DATA_HOME/chris468/tools/essential/win/winget.json" `
  --accept-package-agreements `
  --accept-source-agreements

Set-PSRepository PSGallery https://www.powershellgallery.com/api/v2 -InstallationPolicy Trusted
$modules = @(Get-Content "$env:XDG_DATA_HOME/chris468/tools/essential/win/ps-modules.json" | ConvertFrom-Json)
Install-Module $modules
