[CmdletBinding()]
param(
  [switch]$All,
  [Switch]$Aws,
  [Switch]$Azure,
  [Switch]$Container,
  [switch]$Essential,
  [Switch]$Kubernetes
)
$AllCategories = @(
  "Essential",
  "Container",
  "Kubernetes",
  "Aws",
  "Azure"
)

$categories = @(foreach ($category in $AllCategories) {
  if ($All -or (Get-Variable -Scope Script -Name $category).Value.IsPresent) {
    $category.ToLower()
  }
})
$categories = if ($categories) { $categories } else { @("Essential") }

foreach ($category in $categories) {
  $WingetPackages = "$env:XDG_DATA_HOME/chris468/tools/$category/win/winget.json"
  if (Test-Path $WingetPackages) {
    Write-Host "`nInstalling $category tool winget packages..." -ForegroundColor Green
    winget import `
      --import-file $WingetPackages `
      --accept-package-agreements `
      --accept-source-agreements
  }

  $PowerShellModules = "$env:XDG_DATA_HOME/chris468/tools/$category/win/ps-modules.json"
  if (Test-Path $PowerShellModules) {
    Write-Host "`nInstalling $category tool powershell modules..." -ForegroundColor Green
    Set-PSRepository PSGallery https://www.powershellgallery.com/api/v2 -InstallationPolicy Trusted
    $modules = @(Get-Content $PowerShellModules | ConvertFrom-Json)
    Install-Module $modules
  }
}
