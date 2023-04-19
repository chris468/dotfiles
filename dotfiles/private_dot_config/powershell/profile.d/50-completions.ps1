foreach ($script in Get-ChildItem $config_dir/powershell/completions.d -Filter '*.ps1') {
    . $script
}
