[CmdletBinding()]
param(
  [switch]$VerboseLogs,

  [Parameter(ValueFromRemainingArguments = $true)]
  [string[]]$InstallToolsArgs
)

$ErrorActionPreference = 'Stop'
Set-StrictMode -Version Latest

$logsRoot = Join-Path ([System.IO.Path]::GetTempPath()) ("install-tools-" + [Guid]::NewGuid().ToString('N'))
$null = New-Item -ItemType Directory -Path $logsRoot -Force
$workRoot = Join-Path ([System.IO.Path]::GetTempPath()) ("install-tools-work-" + [Guid]::NewGuid().ToString('N'))
$null = New-Item -ItemType Directory -Path $workRoot -Force

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

$logPrefix = if ($env:TEST_LOG_PREFIX) { $env:TEST_LOG_PREFIX } else { 'install-test' }
$logContext = if ($env:TEST_LOG_CONTEXT) { $env:TEST_LOG_CONTEXT } else { 'windows' }

function Write-ProgressLine {
  param(
    [Parameter(Mandatory = $true)]
    [string]$Message
  )

  Write-Host "[$logPrefix|$logContext] $Message"
}

function Invoke-LoggedStep {
  param(
    [Parameter(Mandatory = $true)]
    [string]$LogFile,

    [Parameter(Mandatory = $true)]
    [scriptblock]$ScriptBlock
  )

  if ($VerboseLogs) {
    & $ScriptBlock 2>&1 | Tee-Object -FilePath $LogFile | Out-Host
  } else {
    & $ScriptBlock 2>&1 | Tee-Object -FilePath $LogFile | Out-Null
  }
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
  $zipPath = Join-Path $workRoot $zipName

  Invoke-WebRequest -Uri $zipUrl -OutFile $zipPath
  Expand-Archive -Path $zipPath -DestinationPath $workRoot -Force

  $chezmoiExe = Join-Path $workRoot 'chezmoi.exe'
  if (-not (Test-Path $chezmoiExe)) {
    throw "chezmoi.exe was not found in extracted archive: $zipPath"
  }

  Copy-Item -Path $chezmoiExe -Destination (Join-Path $localBin 'chezmoi.exe') -Force
}

try {
  $chezmoiCommandPath = $null
  if (Get-Command chezmoi -ErrorAction SilentlyContinue) {
    Write-ProgressLine 'using existing chezmoi'
    Set-Content -Path (Join-Path $logsRoot 'chezmoi-install.log') -Value "[$logPrefix|$logContext] using existing chezmoi"
    $chezmoiCommandPath = (Get-Command chezmoi -ErrorAction Stop).Source
  } else {
    Write-ProgressLine 'downloading chezmoi'
    Invoke-LoggedStep -LogFile (Join-Path $logsRoot 'chezmoi-install.log') -ScriptBlock {
      Install-Chezmoi
    }
    $chezmoiCommandPath = (Join-Path $localBin 'chezmoi.exe')
  }

  Write-ProgressLine 'applying dotfiles'
  Invoke-LoggedStep -LogFile (Join-Path $logsRoot 'chezmoi-init.log') -ScriptBlock {
    & $chezmoiCommandPath init --promptDefaults --apply --source $repoRoot
  }

  $toolsFile = Join-Path $env:XDG_DATA_HOME 'chris468/tools/tools.yaml'
  if (-not (Test-Path $toolsFile)) {
    throw "Missing expected tools file: $toolsFile"
  }

  $installTools = Join-Path $env:XDG_DATA_HOME 'chris468/bin/install-tools.ps1'
  if (-not (Test-Path $installTools)) {
    throw "Missing install-tools.ps1 script: $installTools"
  }

  Write-ProgressLine 'running install-tools'
  Invoke-LoggedStep -LogFile (Join-Path $logsRoot 'install-tools.log') -ScriptBlock {
    & pwsh -NoLogo -NoProfile -File $installTools -All @InstallToolsArgs
  }

  Write-Host "[$logPrefix|$logContext] Test succeeded. Logs are in: $logsRoot"
} catch {
  Write-Error $_
  Write-Host "[$logPrefix|$logContext] Test failed. Logs are in: $logsRoot"
  exit 1
} finally {
  if (Test-Path $workRoot) {
    Remove-Item -Path $workRoot -Recurse -Force
  }
}
