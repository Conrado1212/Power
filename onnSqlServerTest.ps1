###modul sql server  Install-Module SqlServer


$server = "DESKTOP-JU0SB6N"

$db = "BIkeStores"

$query ="SELECT TOP (1000) [brand_id]
,[brand_name]
FROM [BikeStores].[production].[brands]"


#Invoke-Sqlcmd -ServerInstance $server -Database $db -Query $query

function Get-Data{
    param(
    [string]$server,
    [string]$db,
    [string]$query,
    [string]$LogPath = "",
    [int]$QueryTimeout = 30,
    [int]$ConnectionTimeout = 60
    )

    $logDir = Split-Path $LogPath 
   # Write-host $logDir
    if (-not (Test-Path $logDir)) {
         New-Item -ItemType Directory -Path $logDir | Out-Null 
        }
   
    try {
        $result =    Invoke-Sqlcmd -ServerInstance $server -Database $db -Query $query -QueryTimeout $QueryTimeout -ConnectionTimeout $ConnectionTimeout
        Add-Content -Path $LogPath -Value "$(Get-Date) | SUCCESS | Query executed on $server/$db"
         return $result
    } catch {
        Add-Content -Path $LogPath -Value "$(Get-Date) | ERROR | $_"

        Write-Error "Error  $_"
       
    }

}

Get-Data -server $server -db $db -Query $query 