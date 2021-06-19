Param([switch]$force=$false, [switch]$quiet=$false)

$settingsFiles = '~\AppData\Local\Packages\Microsoft.WindowsTerminal_8wekyb3d8bbwe\LocalState\settings.json','C:\Users\Chris\AppData\Local\Packages\Microsoft.WindowsTerminalPreview_8wekyb3d8bbwe\LocalState\settings.json'

if ( ! ($force -or $quiet) ) {
    foreach ($settingsFile in $settingsFiles) {
        if ( Test-Path "$settingsFile" ) {
            throw "$settingsFile already exists"
        }
    }
}

if ($force) {
    Remove-Item -Force -Recurse $settingsFiles
}

foreach ($settingsFile in $settingsFiles) {
    if ( !(Test-Path "$settingsFile") ) {
        New-Item -ItemType Directory -Path "settingsDir" -Force
        New-Item -ItemType SymbolicLink -Path "$settingsFile" -Target $PSScriptRoot\settings.json
    }
}
