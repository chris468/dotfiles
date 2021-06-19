$config_file=(join-path $PSScriptRoot gitconfig).Replace("\", "/")

function has-config {
    if ($(git config --global -l | Select-String -Pattern "^include.path=$config_file`$") -eq $null) {
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

try
{
    if ( ! (has-config)) {
        add-config
    }
}
catch [System.Management.Automation.CommandNotFoundException]
{
    Write-Warning "git not found skipping"
}
