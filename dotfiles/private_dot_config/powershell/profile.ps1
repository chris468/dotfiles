$config_dir = "$HOME/.config"

foreach ($script in Get-ChildItem $config_dir/powershell/profile.d -Filter '*.ps1') {
    . $script
}
