function Configure-Prompt {
    function On-VIModeChange {
        if ($args[0] -eq 'Command') {
            # Set the cursor to a blinking block.
            Write-Host -NoNewLine "`e[1 q"
        } else {
            # Set the cursor to a blinking line.
            Write-Host -NoNewLine "`e[5 q"
        }
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

    # oh my posh replaces the prompt function. To be able to make sure Initialize-InteractiveSession,
    # configure the posh prompt inside the initial prompt function.
    $theme = "$config_dir/oh-my-posh/current-theme.omp.json"
    oh-my-posh --init --shell pwsh --config $theme | Invoke-Expression

    Set-Item function:OhMyPoshPrompt (Get-Item function:Prompt).ScriptBlock -Force

    [ScriptBlock]$PromptWrapper = {

        Initialize-InteractiveSession
        $(OhMyPoshPrompt)
    }

    Set-Item function:Prompt $PromptWrapper -Force
}

. Configure-Prompt
