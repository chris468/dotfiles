Import-Module posh-git

# For performance, disable untracked files in the prompt.
# Just disabling doesn't hide the +0 - need to set the
# option to hide 0 statuses as well.
$GitPromptSettings.UntrackedFilesMode="no"
$GitPromptSettings.ShowStatusWhenZero=$false

$status_dir = "$HOME\.cache\dotfiles"
$statusfile = "$status_dir\auto-update-status.txt"
$logfile = "$status_dir\auto-update.log"

function Get-LastStatusUpdate {
    if ( Test-Path $statusFile ) {
        $(Get-Item $statusfile).LastWriteTime
    }
}

$global:_dotfiles_lastStatusUpdate = Get-LastStatusUpdate
$global:_status_updated = $false

function Get-StatusUpdate {
    if ( ! $global:_status_updated ) {
        if ( (Get-LastStatusUpdate) -ne $_dotfiles_lastStatusUpdate) {
            $global:_status_updated = $true
            Get-Content $statusfile
        }
    }
}


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

function Shorten-Component {
    Param([string]$component)

    if ( $component.StartsWith('.') ) {
        $component.Substring(0, 2)
    } else {
        $component.Substring(0, 1)
    }
}

function Get-ShortPromptPath {
    $normalizedLocation=(Get-Location | Resolve-Path).Path.Replace("$HOME", "~")
    $components = $normalizedLocation.Split([System.IO.Path]::DirectorySeparatorChar, [System.StringSplitOptions]::RemoveEmptyEntries)

    $sb = [System.Text.StringBuilder]::new()
    for ($i = 0; $i -lt $components.Length - 1; $i++) {
        if ($i -eq 0 -and $components[$i].Contains(':')) {
            $null = $sb.Append($components[$i])
        } else {
            $null = $sb.Append((Shorten-Component($components[$i])))
        }

        $null = $sb.Append('\')
    }

    $null = $sb.Append($components[-1])

    $sb.ToString()
}

$global:GitPromptSettings.DefaultPromptPath.Text='$(Get-ShortPromptPath)'
$previousPromptPrefix = $global:GitPromptSettings.DefaultPromptPrefix

function gitPrompt {
    & $GitPromptScriptBlock
}

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

    $status = Get-StatusUpdate
    if ( $status ) {
        $promptPrefix = "`n$status`n`n"
    }

    #$promptPrefix = $promptPrefix + $previousPromptPrefix
    #$global:GitPromptSettings.DefaultPromptPrefix = $promptPrefix

    $global:GitPromptSettings.DefaultPromptBeforeSuffix.Text=$lastCommandResult

    $git = gitPrompt
    $promptPrefix + $git
}

Auto-Update-Dotfiles
Configure-PSReadline
