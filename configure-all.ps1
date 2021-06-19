Param([Parameter(ValueFromRemainingArguments=$true)] $arguments)
$configurators = $(Get-Childitem * -Depth 1 -Filter configure.ps1)

foreach ($configurator in $configurators) {
    Write-Host "Running $configurator..."
    Invoke-Expression "$configurator $arguments"
}
