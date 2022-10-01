$config_dir = "$HOME/.config"

function yadm {
    & 'C:\Program Files\Git\bin\bash.exe' -c "export MSYS=winsymlinks:nativestrict && yadm $args"
}

foreach ($script in Get-ChildItem $config_dir/powershell/profile.d -Filter '*.ps1') {
    . $script
}

#. Configure-Prompt
#. Configure-Completions
