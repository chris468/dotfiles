Import-Module posh-git

# For performance, disable untracked files in the prompt.
# Just disabling doesn't hide the +0 - need to set the
# option to hide 0 statuses as well.
$GitPromptSettings.UntrackedFilesMode="no"
$GitPromptSettings.ShowStatusWhenZero=$false

function Update-Dotfiles {
    Param([switch]$background=$false)

    $dotfiles = Split-Path (Split-Path (Get-Item $PSCommandPath).Target)
    $options = $args | Where-Object { $_ -ne "-background" }
    $job = Start-Job -ScriptBlock { Param($dotfiles, [string[]]$options) & $dotfiles\update.ps1 $options } -ArgumentList $dotfiles,($options)
    if ( ! $background) {
        Receive-Job -Wait $job
    }
}

function Auto-Update-Dotfiles {
    $status_dir = "$HOME\.cache\dotfiles"
    $logfile = "$status_dir\auto-update.log"
    $statusfile = "$status_dir\auto-update-status.txt"
    $interval_days = 1

    function log_exists {
        Test-Path $logfile
    }

    function log_updated_since_interval {
        $age = $(Get-Date) - $(Get-Item $logfile).LastWriteTime
        $age -lt $(New-TimeSpan -Days $interval_days)
    }

    function should_update {
        -not $(log_exists) -or -not $(log_updated_since_interval)
    }

    function update {
        New-Item -Type Directory $status_dir > $null
        Set-Content $logfile "Starting update at $(Get-Date)"
        $dotfiles = Split-Path (Split-Path (Get-Item $PSCommandPath).Target)
        Start-Job -ArgumentList $statusfile,$logfile,$dotfiles -ScriptBlock {
            Param($statusfile, $logfile, $dotfiles)
            & $dotfiles\update.ps1 -statusFile "$statusfile" 2>&1 >> "$logfile"
        }
    }

    if ( should_update ) {
        Write-Output "Updating dotfiles in background. See $logfile"
        update
    }
    else {
        Get-Content $statusfile
    }
}

Auto-Update-Dotfiles
