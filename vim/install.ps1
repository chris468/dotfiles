Param([switch]$force=$false)

if ( Test-Path ~/vimfiles ) {
    if ( $force ) {
        Remove-Item -Force -Recurse ~/vimfiles
    }
    else  {
        throw "~/vimfiles already exists"
    }
}

if ( Test-Path ~/.vsvimrc ) {
    if ( $force ) {
        Remove-Item -Force -Recurse ~/.vsvimrc
    }
    else  {
        throw "~/.vsvimrc already exists"
    }
}

$script_dir = $PSScriptRoot

New-Item -ItemType SymbolicLink -Path ~\vimfiles -Target $PSScriptRoot\vim
New-Item -ItemType SymbolicLink -Path ~\.vsvimrc -Target $PSScriptRoot\vsvimrc

$orig = $pwd
cd $script_dir ; git submodule init ; git submodule update ; cd $orig
