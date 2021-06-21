Param([switch]$force=$false, [switch]$quiet=$false)

$files = @{
    "~/vimfiles" = "$PSScriptRoot/vim";
    "~/.vim" = "$PSScriptRoot/vim";
    "~/.vimrc" = "$PSScriptRoot/vimrc";
    "~/_vimrc" = "$PSScriptRoot/vimrc";
    "~/.vsvimrc" = "$PSScriptRoot/vsvimrc";
}

$fileExists = $false
if ( ! $force -and ! $quiet ) {
    foreach ( $destination in $files.keys ) {
        if ( Test-Path $destination ) {
            Write-Error "$destination already exists"
            $fileExists = $true
        }
    }

    if ( $fileExists ) {
        throw "use -Force or -Quiet"
    }
}

if ( $force ) {
    Remove-Item -Force -Recurse -Path @($files.keys)
}

foreach ( $file in $files.keys ) {
    if ( !(Test-Path $file) ) {
        New-Item -ItemType SymbolicLink -Path $file -Target $files[$file]
    }
}

if ( $force ) {
    vim -c PlugClean -c qa
}

vim -c PlugInstall -c qa

