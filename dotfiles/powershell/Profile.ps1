function Get-DotfilesStatusUpdate {
    if ( $global:_dotfiles_auto_updating `
        -And (Test-Path "$HOME/.cache/dotfiles/auto-update-complete") `
        -And (Test-Path "$HOME/.cache/dotfiles/auto-update-status.txt") ) {
        $global:_dotfiles_auto_updating = $false
        Get-Content "$HOME/.cache/dotfiles/auto-update-status.txt"
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

function Get-ShortPromptPath {
    function Shorten-Component {
        Param([string]$component)

        if ( $component.StartsWith('.') ) {
            $component.Substring(0, 2)
        } else {
            $component.Substring(0, 1)
        }
    }

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

$dotfiles = Split-Path (Split-Path (Split-Path (Get-Item $PSCommandPath).Target))

function Update-Dotfiles {
    & $dotfiles\update.ps1
}

function Register-AWSCompletion {
    Register-ArgumentCompleter -Native -CommandName aws -ScriptBlock {
    param($commandName, $wordToComplete, $cursorPosition)
        $env:COMP_LINE=$wordToComplete
        $env:COMP_POINT=$cursorPosition
        aws_completer.exe | ForEach-Object {
            [System.Management.Automation.CompletionResult]::new($_, $_, 'ParameterValue', $_)
        }
        Remove-Item Env:\COMP_LINE
        Remove-Item Env:\COMP_POINT
    }
}

function Configure-Completions {
    $completions = @{
        helm = "helm completion powershell"
        kubectl = "kubectl completion powershell"
    }

    foreach ($command in $completions.Keys) {
        if (Get-Command $command) {
            Invoke-Expression $completions[$command] | Out-String | Invoke-Expression
        }
    }

    Register-AWSCompletion
}

function Initialize-InteractiveSession {

    function Auto-Update-Dotfiles {
        Push-Location $dotfiles
        py -3.9 -m manager auto-update
        if ($LASTEXITCODE -eq 0) {
            $global:_dotfiles_auto_updating = $true
        }
        Pop-Location
    }

    function Configure-PoshGit {
        Import-Module posh-git

        $global:GitPromptSettings.DefaultPromptPath.Text='$(Get-ShortPromptPath)'
        $global:GitPromptSettings.DefaultPromptBeforeSuffix.ForegroundColor=$global:GitPromptSettings.ErrorColor.ForegroundColor
        $global:GitPromptSettings.DefaultPromptBeforeSuffix.BackgroundColor=$global:GitPromptSettings.ErrorColor.BackgroundColor

        # For performance, disable untracked files in the prompt.
        # Just disabling doesn't hide the +0 - need to set the
        # option to hide 0 statuses as well.
        $global:GitPromptSettings.UntrackedFilesMode="no"
        $global:GitPromptSettings.ShowStatusWhenZero=$false

    }

    function Configure-PSReadline {
        Set-PSReadLineOption -Editmode vi
        Set-PSReadLineOption -ViModeIndicator Script -ViModeChangeHandler ${Function:On-VIModeChange}
        Set-PSReadLineOption -HistorySavePath "$HOME/.cache/pwsh/history.txt"
    }

    if (! $global:InteractiveSession ) {
        Import-Module posh-git

        $global:InteractiveSession = $true

        Auto-Update-Dotfiles
        Configure-PoshGit
        Configure-PSReadline

    }
}

function Get-AWSProfile {
    $awsProfileInfo = @()
    if ($env:AWS_PROFILE) {
        $awsProfileInfo += $env:AWS_PROFILE
    }
    if ($env:AWS_ACCESS_KEY_ID) {
        $awsProfileInfo += "Key"
    }

    if ($awsProfileInfo) {
        "[AWS: $($awsProfileInfo -Join ', ')]`n"
    }
}

function prompt {
    function gitPrompt {
        & $GitPromptScriptBlock
    }

    $failure = $?
    $err = $LASTEXITCODE

    $promptPrefix = Initialize-InteractiveSession

    if ( $promptPrefix ) {
        $promptPrefix += "`n`n"
    }

    $promptPrefix += Get-AWSProfile

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
        $promptPrefix += "`n$status`n`n"
    }

    $global:GitPromptSettings.DefaultPromptBeforeSuffix.Text=$lastCommandResult

    $git = gitPrompt
    "`n" + $promptPrefix + $git
}

$env:PATH = "$HOME/bin;$env:PATH"

. Configure-Completions
