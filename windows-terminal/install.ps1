Param([switch]$force=$false, [switch]$quiet=$false)

$settingsDir = '~\AppData\Local\Packages\Microsoft.WindowsTerminal_8wekyb3d8bbwe\LocalState'
$settingsFile = Join-Path "$settingsDir" "settings.json"

if ( Test-Path "$settingsFile" ) {
    if ( $force ) {
        Remove-Item -Force -Recurse "$settingsFile"
    }
    elseif ( ! $quiet ) {
        throw "$settingsFile already exists"
    }
}

if ( !(Test-Path "$settingsFile") ) {
    New-Item -ItemType Directory -Path "settingsDir" -Force
    New-Item -ItemType SymbolicLink -Path "$settingsFile" -Target $PSScriptRoot\settings.json
}
