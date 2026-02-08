[CmdletBinding()]
param(
  [switch]$All,
  [switch]$DryRun,

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

$wingetPackageIds = @()
$wingetSourceDetails = $null
$psModules = @()
$toolsYaml = "$ToolsRoot/tools.yaml"
if (!(Test-Path $toolsYaml)) {
  throw "Missing tools definition: $toolsYaml"
}
$toolsData = Get-Content $toolsYaml -Raw | ConvertFrom-Yaml

foreach ($category in $categories.ToLower()) {
  $CategoryRoot = "$ToolsRoot/$category"

  $catTools = $toolsData.tools.$category.packages
  if ($catTools) {
    foreach ($tool in $catTools.PSObject.Properties) {
      $meta = $tool.Value
      if ($meta.packages.os.windows) {
        $wingetPackageIds += $meta.packages.os.windows
      }
      if ($meta.psmodules.windows) {
        $psModules += @($meta.psmodules.windows)
      }
    }
  }

  $nerdFonts = $toolsData.tools.$category.nerdfonts
  if ($nerdFonts) {
    if ($nerdFonts -is [string]) {
      $nerdFonts = @($nerdFonts)
    }
    Write-Host "`nInstalling $category nerdfonts..." -ForegroundColor Green
    foreach ($font in $nerdFonts) {
      oh-my-posh font install "$font"
    }
  }
}

if ($wingetPackageIds.Count -gt 0) {
  $wingetPackages = $wingetPackageIds | Sort-Object -Unique
  $wingetSourceDetails = $wingetSourceDetails ?? @{
    Argument   = "https://cdn.winget.microsoft.com/cache"
    Identifier = "Microsoft.Winget.Source_8wekyb3d8bbwe"
    Name       = "winget"
    Type       = "Microsoft.PreIndexed.Package"
  }
  $wingetPayload = [ordered]@{
    '$schema' = "https://aka.ms/winget-packages.schema.2.0.json"
    Sources   = @(
      [ordered]@{
        SourceDetails = $wingetSourceDetails
        Packages      = @(
          foreach ($pkg in $wingetPackages) {
            @{ PackageIdentifier = $pkg }
          }
        )
      }
    )
  }
  $wingetFile = New-TemporaryFile
  $wingetPayload | ConvertTo-Json -Depth 6 | Set-Content -Path $wingetFile -Encoding utf8

  if ($DryRun) {
    Write-Host "`nDry run winget packages:" -ForegroundColor Yellow
    $wingetPackages | ForEach-Object { Write-Host "  $_" }
  } else {
  Write-Host "`nInstalling tool winget packages..." -ForegroundColor Green
  winget import `
    --import-file $wingetFile `
    --accept-package-agreements `
    --accept-source-agreements
  }
}

if ($psModules.Count -gt 0) {
  $psModules = $psModules | Sort-Object -Unique
  if ($DryRun) {
    Write-Host "`nDry run powershell modules:" -ForegroundColor Yellow
    $psModules | ForEach-Object { Write-Host "  $_" }
    return
  }
  Write-Host "`nInstalling tool powershell modules..." -ForegroundColor Green
  Set-PSRepository PSGallery https://www.powershellgallery.com/api/v2 -InstallationPolicy Trusted
  Install-Module -Name $psModules
}
