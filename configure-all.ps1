Param([Parameter(ValueFromRemainingArguments=$true)] $arguments)
$configurators = $(Get-Childitem "$PSScriptRoot\*" -Depth 1 -Filter configure.ps1)

foreach ($configurator in $configurators) {
    Write-Output "Running $configurator..."
    Invoke-Expression "$configurator $arguments"
}
