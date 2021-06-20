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

