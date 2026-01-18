[CmdletBinding()]
param(
  [switch]$All,
  [Switch]$NoFonts,

  # Categories. Each must have a folder in .local/shared/chris468/tools
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

$ToolsRoot = "$env:XDG_DATA_HOME/chris468/tools"

$categories = @(foreach ($category in $AllCategories) {
  if ($All -or (Get-Variable -Scope Script -Name $category).Value.IsPresent) {
    $category.ToLower()
  }
})
$categories = if ($categories) { $categories } else { @("Essential") }

foreach ($category in $categories.ToLower()) {
  $CategoryRoot = "$ToolsRoot/$category"
  $CategoryOSRoot = "$CategoryRoot/win"

  $WingetPackages = "$CategoryOSRoot/winget.json"
  if (Test-Path $WingetPackages) {
    Write-Host "`nInstalling $category tool winget packages..." -ForegroundColor Green
    winget import `
      --import-file $WingetPackages `
      --accept-package-agreements `
      --accept-source-agreements
  }

  $PowerShellModules = "$CategoryOSRoot/ps-modules.json"
  if (Test-Path $PowerShellModules) {
    Write-Host "`nInstalling $category tool powershell modules..." -ForegroundColor Green
    Set-PSRepository PSGallery https://www.powershellgallery.com/api/v2 -InstallationPolicy Trusted
    $modules = @(Get-Content $PowerShellModules | ConvertFrom-Json)
    Install-Module $modules
  }

  $NerdFonts = "$CategoryRoot/nerdfonts.txt"
  if (!$NoFonts -and (Test-Path $NerdFonts)) {
    Write-Host "`nInstalling $category nerdfonts..." -ForegroundColor Green
    foreach ($font in (Get-Content $NerdFonts)) {
      oh-my-posh font install "$font"
    }
  }
}
