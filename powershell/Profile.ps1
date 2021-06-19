Import-Module posh-git

# For performance, disable untracked files in the prompt.
# Just disabling doesn't hide the +0 - need to set the
# option to hide 0 statuses as well.
$GitPromptSettings.UntrackedFilesMode="no"
$GitPromptSettings.ShowStatusWhenZero=$false

function Update-Dotfiles {
    $dotfiles = Split-Path (Split-Path (Get-Item $PSCommandPath).Target)
    & "$dotfiles\update.ps1" $args 
}

