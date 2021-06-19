Param([switch]$force=$false, [switch]$quiet=$false)

if ( Test-Path ~/vimfiles ) {
    if ( $force ) {
        Remove-Item -Force -Recurse ~/vimfiles
    }
    elseif ( ! $quiet ) {
        throw "~/vimfiles already exists"
    }
}

if ( Test-Path ~/.vim ) {
    if ( $force ) {
        Remove-Item -Force -Recurse ~/.vim
    }
    elseif ( ! $quiet ) {
        throw "~/.vim already exists"
    }
}

if ( Test-Path ~/.vsvimrc ) {
    if ( $force ) {
        Remove-Item -Force -Recurse ~/.vsvimrc
    }
    elseif ( ! $quiet ) {
        throw "~/.vsvimrc already exists"
    }
}

if ( !(Test-Path ~/vimfiles) ) {
    New-Item -ItemType SymbolicLink -Path ~\vimfiles -Target $PSScriptRoot\vim
}

if ( !(Test-Path ~/.vim) ) {
    New-Item -ItemType SymbolicLink -Path ~\.vim -Target $PSScriptRoot\vim
}

if ( !(Test-Path ~/.vsvimrc) ) {
    New-Item -ItemType SymbolicLink -Path ~\.vsvimrc -Target $PSScriptRoot\vsvimrc
}
