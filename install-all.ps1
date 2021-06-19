Param([Parameter(ValueFromRemainingArguments=$true)] $arguments)
$installers = $(Get-Childitem * -Depth 1 -Filter install.ps1)

foreach ($installer in $installers) {
    Write-Host "Running $installer..."
    Invoke-Expression "$installer $arguments"
}
