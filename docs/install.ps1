function Check-SymbolicLinks {
    $tmp = New-TemporaryFile
    $link = New-Item -Type SymbolicLink -Target "$tmp" -Path "$tmp.link"
    if (-not $?) {
        Write-Error "Symbolic Link creation failed. Ensure that 'Create Symbolic Links' permission is granted for your user.
See Local Computer Policy -> Computer Configuration -> Windows Settings -> Security Settings -> Local Policies -> User Rights Assignment
in group policy editor."
        exit 1
    }
}

function Install-Git {
  function Create-Inf {
    $inf = New-TemporaryFile
    Set-Content -Path "$inf" -Value @"
[Setup]
Lang=default
Dir=C:\Program Files\Git
Group=Git
NoIcons=0
SetupType=default
Components=ext,ext\shellhere,ext\guihere,gitlfs,assoc,assoc_sh,autoupdate,windowsterminal,scalar
Tasks=
EditorOption=VIM
CustomEditorPath=
DefaultBranchOption=main
PathOption=Cmd
SSHOption=OpenSSH
TortoiseOption=false
CURLOption=OpenSSL
CRLFOption=CRLFAlways
BashTerminalOption=ConHost
GitPullBehaviorOption=FFOnly
UseCredentialManager=Enabled
PerformanceTweaksFSCache=Enabled
EnableSymlinks=Enabled
EnablePseudoConsoleSupport=Disabled
EnableFSMonitor=Disabled

"@
    $inf
  }

  $git_install_status=(winget list Git.Git)
  if ($?) {
      $git_install_status
  } else {
    $inf = Create-Inf
    winget install Git.Git --override "/LoadInf=$inf /Silent"
  }
}

function Install-Scoop {
  $env:SCOOP="$HOME/.local/opt/scoop"
  if (!(Get-Command scoop 2>$null)) {
    Write-Host "Installing scoop..."
    Set-ExecutionPolicy RemoteSigned -Scope CurrentUser
    Invoke-RestMethod https://get.scoop.sh | Invoke-Expression
  }
}

function Install-Dotfiles {
  '$params="-BinDir `"$HOME\.local\bin`" init --apply chris468 $params"', `
    (Invoke-RestMethod -UseBasicParsing https://get.chezmoi.io/ps1) | pwsh -c -
}


Check-SymbolicLinks
Install-Git
Install-Scoop
Install-Dotfiles
