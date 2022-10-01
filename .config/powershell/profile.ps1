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

function AutoUpdate-Dotfiles {
    Start-Job -Name AutoUpdate-Dotfiles -ScriptBlock { & 'C:\Program Files\Git\bin\bash.exe' -c "export MSYS=winsymlinks:nativestrict && ~/.config/yadm/scripts/auto-update.sh -reset" } > $null | Wait-Job
    Start-Job -Name AutoUpdate-Dotfiles -ScriptBlock { & 'C:\Program Files\Git\bin\bash.exe' -c "export MSYS=winsymlinks:nativestrict && ~/.config/yadm/scripts/auto-update.sh" } > $null
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
        AutoUpdate-Dotfiles
    }
}

function Configure-Prompt {
    # oh my posh replaces the prompt function. To be able to make sure Initialize-InteractiveSession,
    # configure the posh prompt inside the initial prompt function.
    $theme = "$config_dir/oh-my-posh/$(Get-Content $config_dir/oh-my-posh/current-theme)"
    oh-my-posh --init --shell pwsh --config $theme | Invoke-Expression

    Set-Item function:OhMyPoshPrompt (Get-Item function:Prompt).ScriptBlock -Force

    [ScriptBlock]$PromptWrapper = {

        Initialize-InteractiveSession
        $auto_update_status="~/.cache/yadm/auto-update/status.log"
        if (Test-Path "$auto_update_status") {
            $env:YADM_AUTO_UPDATE_STATUS=$(Get-Content "$auto_update_status")
        }
        else {
            Remove-Item env:YADM_AUTO_UPDATE_STATUS
        }

        $(OhMyPoshPrompt)
    }

    Set-Item function:Prompt $PromptWrapper -Force
}

$env:PATH = "$HOME/bin;$env:PATH"

. Configure-Prompt
. Configure-Completions
