$config_dir = "$HOME/.config/powershell"

$paths="profile.d","completion.d"

foreach ($path in $paths) {
    if (Test-Path -Type Container "$config_dir/$path") {
        foreach ($script in Get-ChildItem "$config_dir/$path" -Filter '*.ps1') {
            . $script
        }
    }
}

