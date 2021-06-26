Import-Module posh-git

# For performance, disable untracked files in the prompt.
# Just disabling doesn't hide the +0 - need to set the
# option to hide 0 statuses as well.
$GitPromptSettings.UntrackedFilesMode="no"
$GitPromptSettings.ShowStatusWhenZero=$false

function Update-Dotfiles {
    Param([switch]$background=$false,$profileLocation)

    $dotfiles = Split-Path (Split-Path (Get-Item $PSCommandPath).Target)
    $options = $args | Where-Object { $_ -ne "-background" }
    $job = Start-Job -ArgumentList $dotfiles,$PROFILE,($options) -ScriptBlock {
        Param($dotfiles, $PROFILE, [string[]]$options)

        if (!$profileLocation) {
            $profileLocation = $PROFILE.CurrentUserAllHosts
        }
        & $dotfiles\update.ps1 -ProfileLocation $profileLocation $options
    }

    if ( ! $background) {
        Receive-Job -Wait $job
    }
}

function Auto-Update-Dotfiles {
    $status_dir = "$HOME\.cache\dotfiles"
    $logfile = "$status_dir\auto-update.log"
    $statusfile = "$status_dir\auto-update-status.txt"
    $interval_minutes = 120

    function log_exists {
        Test-Path $logfile
    }

    function log_updated_since_interval {
        $age = $(Get-Date) - $(Get-Item $logfile).LastWriteTime
        $age -lt $(New-TimeSpan -Minutes $interval_minutes)
    }

    function should_update {
        -not $(log_exists) -or -not $(log_updated_since_interval)
    }

    function update {
        New-Item -Force -Type Directory $status_dir > $null
        Set-Content $logfile "Starting update at $(Get-Date)"
        $dotfiles = Split-Path (Split-Path (Get-Item $PSCommandPath).Target)
        $profileLocation = $PROFILE.CurrentUserAllHosts
        Start-Job -ArgumentList $statusfile,$logfile,$dotfiles,$profileLocation -ScriptBlock {
            Param($statusfile, $logfile, $dotfiles, $profileLocation)

            & $dotfiles\update.ps1 -statusFile "$statusfile" -profileLocation $profileLocation 2>&1 >> "$logfile"
        } >$null
    }

    if ( should_update ) {
        Write-Output "Updating dotfiles in background. See $logfile"
        update
    }
    else {
        Get-Content $statusfile
    }
}

function On-VIModeChange {
    if ($args[0] -eq 'Command') {
        # Set the cursor to a blinking block.
        Write-Host -NoNewLine "`e[1 q"
    } else {
        # Set the cursor to a blinking line.
        Write-Host -NoNewLine "`e[5 q"
    }
}

function Configure-PSReadline {
    Set-PSReadLineOption -Editmode vi
    Set-PSReadLineOption -ViModeIndicator Script -ViModeChangeHandler ${Function:On-VIModeChange}
}

$global:GitPromptSettings.DefaultPromptBeforeSuffix.ForegroundColor=$global:GitPromptSettings.ErrorColor.ForegroundColor
$global:GitPromptSettings.DefaultPromptBeforeSuffix.BackgroundColor=$global:GitPromptSettings.ErrorColor.BackgroundColor

function prompt {
    $failure = $?
    $err = $LASTEXITCODE
    if ( ! $failure ) {
        if ( $err -ne 0 ) {
            $lastCommandResult = " [$err]"
        }
        else {
            $lastCommandResult = " [F]"
        }
    }
    else {
        $lastCommandResult = ""
    }

    $global:GitPromptSettings.DefaultPromptBeforeSuffix.Text=$lastCommandResult

    & $GitPromptScriptBlock
}

Auto-Update-Dotfiles
Configure-PSReadline
