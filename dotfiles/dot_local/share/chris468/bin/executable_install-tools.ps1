[CmdletBinding()]
param(
  [switch]$All,

  # Categories. Each must have a folder in .local/shared/chris468/tools
  [Switch]$Aws,
  [Switch]$Azure,
  [Switch]$Container,
  [switch]$Essential,
  [Switch]$Kubernetes
)
$allCategories = @(
  "Essential",
  "Container",
  "Kubernetes",
  "Aws",
  "Azure"
)

Set-PSRepository PSGallery https://www.powershellgallery.com/api/v2 -InstallationPolicy Trusted

$yamlModuleName = "PowerShell-Yaml"
if (-not (Get-Module -ListAvailable -Name $yamlModuleName)) {
  Install-Module -Name $yamlModuleName -Scope CurrentUser
}

$toolsRoot = "$env:XDG_DATA_HOME/chris468/tools"

$categories = @(foreach ($category in $allCategories) {
  if ($All -or (Get-Variable -Scope Script -Name $category).Value.IsPresent) {
    $category.ToLower()
  }
})
$categories = if ($categories) { $categories } else { @("Essential") }

$wingetPackageIds = @()
$wingetSourceDetails = $null
$psModules = @()
$nerdFonts = @()
$toolsYamlPath = "$toolsRoot/tools.yaml"
if (!(Test-Path $toolsYamlPath)) {
  throw "Missing tools definition: $toolsYamlPath"
}
$tools = Get-Content $toolsYamlPath -Raw | ConvertFrom-Yaml

foreach ($category in $categories.ToLower()) {
  $categoryTools = $tools.tools.$category.packages
  if ($categoryTools) {
    foreach ($tool in $categoryTools.PSObject.Properties.Value) {
      if ($tool.packages.os.windows) {
        $wingetPackageIds += $tool.packages.os.windows
      }
      if ($tool.psmodules.windows) {
        $psModules += @($tool.psmodules.windows)
      }
    }
  }

  $categoryNerdFonts = $tools.tools.$category.nerdfonts
  if ($categoryNerdFonts) {
    if ($categoryNerdFonts -is [string]) {
      $categoryNerdFonts = @($categoryNerdFonts)
    }
    $nerdFonts += $categoryNerdFonts
  }
}

if ($wingetPackageIds.Count -gt 0) {
  $wingetPackageIds = $wingetPackageIds | Sort-Object -Unique
  $wingetSourceDetails = $wingetSourceDetails ?? @{
    Argument   = "https://cdn.winget.microsoft.com/cache"
    Identifier = "Microsoft.Winget.Source_8wekyb3d8bbwe"
    Name       = "winget"
    Type       = "Microsoft.PreIndexed.Package"
  }
  $wingetImportPayload = [ordered]@{
    '$schema' = "https://aka.ms/winget-packages.schema.2.0.json"
    Sources   = @(
      [ordered]@{
        SourceDetails = $wingetSourceDetails
        Packages      = @(
          foreach ($pkg in $wingetPackageIds) {
            @{ PackageIdentifier = $pkg }
          }
        )
      }
    )
  }
  $wingetImportFile = New-TemporaryFile
  $wingetImportPayload | ConvertTo-Json -Depth 6 | Set-Content -Path $wingetImportFile -Encoding utf8

  Write-Host "`nInstalling tool winget packages..." -ForegroundColor Green
  winget import `
    --import-file $wingetImportFile `
    --accept-package-agreements `
    --accept-source-agreements
}

if ($psModules.Count -gt 0) {
  $psModules = $psModules | Sort-Object -Unique
  Write-Host "`nInstalling tool powershell modules..." -ForegroundColor Green
  Install-Module -Name $psModules
}

if ($nerdFonts.Count -gt 0) {
  Write-Host "`nInstalling nerdfonts..." -ForegroundColor Green
  foreach ($font in $nerdFonts) {
    oh-my-posh font install "$font"
  }
}
