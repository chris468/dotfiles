Param([switch]$force=$false, [switch]$quiet=$false)

$config_file=(join-path $PSScriptRoot dotfiles-gitconfig).Replace("\", "/")

function remove-duplicates {
    foreach ($include in $(git config --global --get-all include.path | Select-String -Pattern dotfiles-gitconfig)) {
        if ( $include -ne $config_file ) {
            git config --global --unset include.path $include
        }
    }
}

function has-config {
    if ($(git config --global --get-all include.path | Select-String -Pattern "$config_file") -eq $null) {
        $false
    }
    else
    {
        $true
    }
}

function add-config {
    git config --global --add include.path "$config_file"
}

$excludes_destination="$HOME/.config/git/ignore"
if ( ! ($force -or $quiet) ) {
    if ( Test-Path "$excludes_destination" ) {
        throw "$excludes_destination already exists"
    }
}

if ($force) {
    Remove-Item -Force $excludes_destination
}

New-Item -ItemType Directory -Path $(Split-Path "$excludes_destination") -Force

if ( !( Test-Path "$excludes_destination" ) ) {
    New-Item -ItemType SymbolicLink -Path "$excludes_destination" -Target $PSScriptRoot\ignore
}

try
{
    remove-duplicates
    if ( ! (has-config)) {
        add-config
    }
}
catch [System.Management.Automation.CommandNotFoundException]
{
    Write-Warning "git not found skipping"
}
