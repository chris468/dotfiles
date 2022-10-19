param(
    [Parameter(Mandatory=$true, Position=0)]
    [string]$Name
)

$keyName="DEVPKEY_Device_BusReportedDeviceDesc"

(Get-PnpDevice -PresentOnly `
    | Where-Object { $_.InstanceId -match '^USB' } `
    | ForEach-Object { Get-PnpDeviceProperty -InstanceId $_.InstanceId -KeyName $keyName } `
    | Where-Object { $_.Data -eq $Name } `
    | ForEach-Object { $true } `
    | Select-Object -First 1) -eq $True
