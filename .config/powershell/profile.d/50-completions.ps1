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


