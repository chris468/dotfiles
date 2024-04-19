param(
    [Parameter(Mandatory=$true, Position=0)]
    [ValidateSet("set", "unset", "prepend")]
    [string]$command,

    [Parameter(Mandatory=$true, Position=1)]
    [string]$name,

    [Parameter(Mandatory=$false, ValueFromRemainingArguments=$true)]
    [string[]]$value,

    [switch]$persist
)

function Script:Get-Environment(
    [string]$name,
    [bool]$persisted)
{
    $scope = if ($persist) { "User" } else { "Process" }
    [Environment]::GetEnvironmentVariable($name, $scope)
}

function Script:Set-Environment(
    [string]$name,
    [string]$value,
    [switch]$persist)
{
    if ((Get-Environment $name $persist) -ne $value) {
      $scope = if ($persist) { "User" } else { "Process" }
      [Environment]::SetEnvironmentVariable($name, "$value", $scope)
    }
}

function Script:Unset-Environment(
    [string]$name,
    [bool]$persist)
{
    if ((Get-Environment $name $persist) -ne $null) {
      $scope = if ($persist) { "User" } else { "Process" }
      [Environment]::SetEnvironmentVariable($name, $null, $scope)
    }
}

function Script:Prepend-Environment(
      [string]$name,
      [string[]]$values,
      [bool]$persist)
{
    $original=Get-Environment $name $persist
    $originalNormalized=@()
    foreach ($p in $original -split ";") {
        $originalNormalized += $p.ToUpper() -replace "/","\"
    }

    $prepend=""
    foreach ($p in $values) {
        if ($originalNormalized -notcontains ($p.ToUpper() -replace "/","\")) {
            $prepend += "$p;"
        }
    }

    if ($prepend) {
        Set-Environment $name "$prepend$original" $persist
    }
}

switch ($command) {
    "set" { Set-Environment $name $value -persist:$persist }
    "unset" { Unset-Environment $name -persist:$persist }
    "prepend" { Prepend-Environment $name $value -persist:$persist }
}
