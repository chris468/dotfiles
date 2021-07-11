Import-Module posh-git

# For performance, disable untracked files in the prompt.
# Just disabling doesn't hide the +0 - need to set the
# option to hide 0 statuses as well.
$GitPromptSettings.UntrackedFilesMode="no"
$GitPromptSettings.ShowStatusWhenZero=$false

$dotfiles = Split-Path (Split-Path (Split-Path (Get-Item $PSCommandPath).Target))

function Update-Dotfiles {
    & $dotfiles\update.ps1
}

function Get-DotfilesStatusUpdate {
    if ( $global:_dotfiles_auto_updating `
        -And (Test-Path "$HOME/.cache/dotfiles/auto-update-complete") `
        -And (Test-Path "$HOME/.cache/dotfiles/auto-update-status.txt") ) {
        $global:_dotfiles_auto_updating = $false
        Get-Content "$HOME/.cache/dotfiles/auto-update-status.txt"
    }
}

function Auto-Update-Dotfiles {
    Push-Location $dotfiles
    py -3.9 -m manager auto-update
    if ($LASTEXITCODE -eq 0) {
        $global:_dotfiles_auto_updating = $true
    }
    Pop-Location
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

    $status = Get-DotfilesStatusUpdate
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
