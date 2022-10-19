param(
    [Parameter(Mandatory=$true, Position=0)]
    [string]$Name,
    [Parameter(Mandatory=$false)]
    [string]$OutputPath=$null
)

$keyName="DEVPKEY_Device_BusReportedDeviceDesc"

$present=(Get-PnpDevice -PresentOnly `
    | Where-Object { $_.InstanceId -match '^USB' } `
    | ForEach-Object { Get-PnpDeviceProperty -InstanceId $_.InstanceId -KeyName $keyName } `
    | Where-Object { $_.Data -eq $Name } `
    | ForEach-Object { $true } `
    | Select-Object -First 1).Count

if ( $OutputPath ) {
    $parent = New-Item -ItemType Directory -Path (split-path $OutputPath) -Force
    Set-Content -Path $OutputPath $present
} else {
    $present
}
