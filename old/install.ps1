Param([Parameter(ValueFromRemainingArguments=$true)] $arguments)

Push-Location $PSScriptRoot

& py -3.9 -m manager install $arguments
$result = $LASTEXITCODE

Pop-Location

exit $result


