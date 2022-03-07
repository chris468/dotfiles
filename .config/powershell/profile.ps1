function On-VIModeChange {
    if ($args[0] -eq 'Command') {
        # Set the cursor to a blinking block.
        Write-Host -NoNewLine "`e[1 q"
    } else {
        # Set the cursor to a blinking line.
        Write-Host -NoNewLine "`e[5 q"
    }
}

$config_dir = "$HOME/.config"

function yadm {
    & 'C:\Program Files\Git\bin\bash.exe' -c "export MSYS=winsymlinks:nativestrict && yadm $args"
}

function Update-Dotfiles {
    "Checking for dotfile updates..."
    yadm fetch --no-prune

    if (yadm status -sb | select-string 'behind') {
        "Updating dotfiles..."
        yadm pull -q --no-prune
        yadm bootstrap
    }
    else {
        "Dotfiles up to date."
    }
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
        if (Get-Command $command -ErrorAction SilentlyContinue) {
            Invoke-Expression $completions[$command] | Out-String | Invoke-Expression
        }
    }

    Register-AWSCompletion
}

function Initialize-InteractiveSession {

    function Configure-PSReadline {
        Set-PSReadLineOption -Editmode vi
        Set-PSReadLineOption -ViModeIndicator Script -ViModeChangeHandler ${Function:On-VIModeChange}
        Set-PSReadLineOption -HistorySavePath "$HOME/.cache/pwsh/history.txt"
    }

    if (! $global:InteractiveSession ) {
        $global:InteractiveSession = $true

        Configure-PSReadLine
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
        "[AWS:$($awsProfileInfo -Join ', ')]"
    }
}

function Get-K8sContext {
    if (Get-Command kubectl -ErrorAction SilentlyContinue) {
        $k8sContext = $(kubectl config current-context)
        if ($k8sContext) {
            "[k8s:$k8sContext]"
        }
    }
}

function Configure-Prompt {
    # oh my posh replaces the prompt function. To be able to make sure Initialize-InteractiveSession,
    # configure the posh prompt inside the initial prompt function.
    $theme = "$config_dir/oh-my-posh/$(Get-Content $config_dir/oh-my-posh/current-theme)"
    oh-my-posh --init --shell pwsh --config $theme | Invoke-Expression

    Set-Item function:OhMyPoshPrompt (Get-Item function:Prompt).ScriptBlock -Force

    [ScriptBlock]$PromptWrapper = {
        $prompt = $(OhMyPoshPrompt)

        $promptPrefix = Initialize-InteractiveSession
        if ($promptPrefix) {
            $promptPrefix += "`n`n"
        }

        if ( $status ) {
            $promptPrefix += "$status`n`n"
        }

        $promptPrefix + $prompt
    }

    Set-Item function:Prompt $PromptWrapper -Force
}

$env:PATH = "$HOME/bin;$env:PATH"

. Configure-Prompt
. Configure-Completions
