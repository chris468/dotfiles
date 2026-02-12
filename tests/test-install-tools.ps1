[CmdletBinding()]
param(
  [Parameter(ValueFromRemainingArguments = $true)]
  [string[]]$InstallToolsArgs
)

$ErrorActionPreference = 'Stop'
Set-StrictMode -Version Latest

$logsRoot = Join-Path ([System.IO.Path]::GetTempPath()) ("install-tools-" + [Guid]::NewGuid().ToString('N'))
$null = New-Item -ItemType Directory -Path $logsRoot -Force

$testHome = if ($env:TEST_HOME) {
  $env:TEST_HOME
} else {
  $path = Join-Path ([System.IO.Path]::GetTempPath()) ("install-tools-home-" + [Guid]::NewGuid().ToString('N'))
  $null = New-Item -ItemType Directory -Path $path -Force
  $path
}

$env:HOME = $testHome
$env:USERPROFILE = $testHome
$env:XDG_DATA_HOME = if ($env:XDG_DATA_HOME) { $env:XDG_DATA_HOME } else { Join-Path $env:HOME '.local/share' }

$localBin = Join-Path $env:HOME '.local/bin'
$null = New-Item -ItemType Directory -Path $localBin -Force
$null = New-Item -ItemType Directory -Path $env:XDG_DATA_HOME -Force
$env:PATH = "$localBin;$env:PATH"

$repoRoot = if ($env:GITHUB_WORKSPACE) {
  $env:GITHUB_WORKSPACE
} else {
  Split-Path -Parent $PSScriptRoot
}

function Get-ChezmoiArch {
  switch ($env:PROCESSOR_ARCHITECTURE.ToLowerInvariant()) {
    'amd64' { return 'amd64' }
    'arm64' { return 'arm64' }
    default { throw "Unsupported architecture: $($env:PROCESSOR_ARCHITECTURE)" }
  }
}

function Install-Chezmoi {
  if (Get-Command chezmoi -ErrorAction SilentlyContinue) {
    return
  }

  $releaseApi = 'https://api.github.com/repos/twpayne/chezmoi/releases/latest'
  $release = Invoke-RestMethod -Uri $releaseApi
  if (-not $release.tag_name) {
    throw 'Failed to determine latest chezmoi release'
  }

  $tag = [string]$release.tag_name
  $version = $tag.TrimStart('v')
  $arch = Get-ChezmoiArch
  $zipName = "chezmoi_${version}_windows_${arch}.zip"
  $zipUrl = "https://github.com/twpayne/chezmoi/releases/download/$tag/$zipName"
  $zipPath = Join-Path $logsRoot $zipName

  Invoke-WebRequest -Uri $zipUrl -OutFile $zipPath
  Expand-Archive -Path $zipPath -DestinationPath $logsRoot -Force

  $chezmoiExe = Join-Path $logsRoot 'chezmoi.exe'
  if (-not (Test-Path $chezmoiExe)) {
    throw "chezmoi.exe was not found in extracted archive: $zipPath"
  }

  Copy-Item -Path $chezmoiExe -Destination (Join-Path $localBin 'chezmoi.exe') -Force
}

try {
  Install-Chezmoi 2>&1 | Tee-Object -FilePath (Join-Path $logsRoot 'chezmoi-install.log') | Out-Host

  & (Join-Path $localBin 'chezmoi.exe') init --promptDefaults --apply --source $repoRoot 2>&1 |
    Tee-Object -FilePath (Join-Path $logsRoot 'chezmoi-init.log') | Out-Host

  $toolsFile = Join-Path $env:XDG_DATA_HOME 'chris468/tools/tools.yaml'
  if (-not (Test-Path $toolsFile)) {
    throw "Missing expected tools file: $toolsFile"
  }

  $installTools = Join-Path $localBin 'install-tools.ps1'
  if (-not (Test-Path $installTools)) {
    throw "Missing install-tools.ps1 script: $installTools"
  }

  & pwsh -NoLogo -NoProfile -File $installTools -All @InstallToolsArgs 2>&1 |
    Tee-Object -FilePath (Join-Path $logsRoot 'install-tools.log') | Out-Host

  Write-Host "Test succeeded. Logs are in: $logsRoot"
} catch {
  Write-Error $_
  Write-Host "Test failed. Logs are in: $logsRoot"
  exit 1
}
