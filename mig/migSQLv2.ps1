$LogFile = "log.txt"
Clear-Content -Path $logFile -ErrorAction SilentlyContinue
function Write-MessageLog{
    param (
        [string]$Message,
        [ValidateSet("INFO", "WARNING", "ERROR")]
        [string]$Level = "INFO",
        [ConsoleColor]$Color = "White"
    )

    $timestamp = Get-Date -Format "dd-MM-yyyy HH:mm:ss"
    $entry = "$timestamp - $Level - $Message"

    switch ($Level) {
        "INFO"    { Write-Host $entry -ForegroundColor $Color }
        "WARNING" { Write-Warning $Message }
        "ERROR"   { Write-Error $Message }
    }

    Add-Content -Path $LogFile -Value $entry
}

Write-MessageLog "This PowerShell script will migrate your data from xlsx or table to WEBCON" 


#db Server name
$server = "dev-sql01"
#base Portal Url
$baseUrl = "https://kt05.webcon.pl"
#db name
$db = "TestKK"

#mozna dodac sprawdzenie czy isntieje po id przykladowo
#query to get data 
$query ="SELECT TOP (10) [nda_id]
      ,[nda_DataZawarciaUmowy]
      ,[nda_DataObowiaywaniaUmowy]
      ,datediff(year,[nda_DataZawarciaUmowy],[nda_DataObowiaywaniaUmowy]) as [nda_CzasUmowyLata]
      ,[nda_status]
      ,[nda_kontrahent]
      ,[nda_projekt]
      ,[nda_skanUmowy]
      ,[nda_skanZalacznika]
  FROM [TestKK].[dbo].[ndaTest]
"
# $query2 ="SELECT COLUMN_NAME
# FROM INFORMATION_SCHEMA.COLUMNS
# WHERE TABLE_NAME = 'ndaTest'
# "

#check
 if(-not $baseUrl){
     $baseUrl = Read-Host "[Line 11] Write your baseUrl (example. https://example.com)"
    }

function Get-Config{
    param(
        [string]$baseUrl,
        [string]$server,
        [string]$db,
        [string]$query
    )
  
     foreach ($p in $MyInvocation.MyCommand.Parameters.Keys) { 
         if (-not $PSBoundParameters.ContainsKey($p)) {
              Set-Variable -Name $p -Value (Read-Host "Add value for $p")
             }
             } 
            
}
Get-Config -baseUrl $baseUrl -server $server -db $db -query $query



#function get data 
function Get-Data{
    param(
    [string]$server,
    [string]$db,
    [string]$query,
    [string]$LogPath = "C:\Users\k.krawczyk\Documents\sql_log.txt",
    [int]$QueryTimeout = 30,
    [int]$ConnectionTimeout = 60
    )

    $logDir = Split-Path $LogPath 
    #Write-MessageLog "[Line 63] $logDir"
    if (-not (Test-Path $logDir)) {
         New-Item -ItemType Directory -Path $logDir | Out-Null 
        }
   
    try {
        $result =    Invoke-Sqlcmd -ServerInstance $server -Database $db -Query $query -QueryTimeout $QueryTimeout -ConnectionTimeout $ConnectionTimeout
        Add-Content -Path $LogPath -Value "$(Get-Date) | SUCCESS | Query executed on $server/$db"
         return $result
    } catch {
        Add-Content -Path $LogPath -Value "$(Get-Date) | ERROR | $_"

        Write-MessageLog "Error  $_" -Level "ERROR"
       
    }

}



function Get-normalizeData{
   $dane =  Get-Data -server $server -db $db -Query $query 

$resultNorm = @()
#decision
$dec = @{}
#mapowanie
 $test = @()
 $att = @()
foreach($item in $dane){
   # $test = @{}
foreach ($prop in $item.PSObject.Properties) {
     if($prop.Name -like "nda_*"){
        
                if($dec.ContainsKey($prop.Name)) {
                continue  
            }

        $userInput = Read-Host "[Line 114] Do you want to add this $($prop.Name) to map (Y/Z/N)"
            if($userInput -eq "Y"){
         $test += $prop.Name
          $dec[$prop.Name] = 'Y'

          ############
            }elseif($userInput -eq "Z"){
                 $att += $prop.Name
                 $dec[$prop.Name] = 'Z'
            }
            
            
            
            else{
                  $dec[$prop.Name] = 'N'
            }
     }
    
 }
}

foreach($item in $dane){
    $test2 = @{}
foreach ($prop in $test) {

 if ($item.PSObject.Properties[$prop]) {
            $test2[$prop] = $item.$prop
        }
        else {
            $test2[$prop] = $null
        }

}
 $test2['attachments'] = @()
 $current = [PSCustomObject]$test2


    foreach ($data in $att) {   
                    if (![string]::IsNullOrWhiteSpace($item.$data) -and (Test-Path  $item.$data)) {   
    try{

 $bytes2 = [System.IO.File]::ReadAllBytes($item.$data)
                    $base642 = [Convert]::ToBase64String($bytes2)
                #nazwa pliku ze sciezki     
                  $name2 = Split-Path -Path  $item.$data -Leaf
                # Write-MessageLog "Nazwa pliku: $name ,base64:  $base64"
              
                $current.attachments += @{
                                 name    = $name2
                                 content = $base642
                             }
    }catch{
 
         Write-MessageLog ("File {0}. Error: {1}" -f $item.$data, $_.Exception.Message) -Level "WARNING"
    }
               
                  }
                
                }
                   $resultNorm +=$current
}
return $resultNorm
}


#Get-normalizeData

function Get-AccessToken{
        param(
            [string]$baseUrl,
            [string]$clientId,
            [string]$clientSecret
        )
        if ([string]::IsNullOrWhiteSpace($clientId)) {

        $clientId = Read-Host "[Line 62] Write  CLIENT_ID"
        }else{
         Write-Host  "[Line 64] Variable clientId value retrieved"
        }

        if ([string]::IsNullOrWhiteSpace($clientSecret)) {
             $clientSecret = Read-Host "Write CLIENT_SECRET"
        }else{
          Write-Host   "[Line 70] Variable clientSecret value retrieved"
        }
       
        
        #url metody uwierzytelnienia 
        $tokenUrl = "$baseUrl/api/oauth2/token"
        #przekazanei body
        $body =@{
            grant_type = "client_credentials"
            client_id = $clientId
            client_secret = $clientSecret
        }
        try{
            #proba otrzymanai accesstoekntu za pomoca wylownaia invoke-RestMethod 
            $respone = Invoke-RestMethod -Method Post -Uri $tokenUrl -Body $body -ContentType "application/x-www-form-urlencoded" 
            return $respone.access_token
        }catch{
            #obsluga bledu 
            Write-Error "[Line 88] Error authentication: $_"
            return $null
        }
} 
$CLIENT_ID = '58888553-99c5-415d-8ab2-2e68f45d799e'

$CLIENT_SECRET = 'BeF/pn95w2LIv7dupqEedA8H4e8gD/+bfHp7ROV8jwI='

function Start-New{
    param(
        [string]$baseUrl,
        [string]$clientId,
        [string]$clientSecret
    )
    $token = Get-AccessToken -baseUrl $baseUrl -clientId $clientId -clientSecret $clientSecret

    if (-not $token) {
        Write-Error "[Line 103] No token"
        return
    }

    $headers = @{
    Authorization = "Bearer $token"
    "Content-Type" = "application/json"
    }
    $new = "$baseUrl/api/data/v6.0/db/1/elements?path=ece972a2-71a2-4e86-9325-669402e27a8d"
    
   #$dane =  Get-Data -server $server -db $db -Query $query
 
$dane  = Get-normalizeData
    foreach($item in $dane){
     #do zmiany jeszcze to 
        $body =@{
            workflow = @{
                guid = "5e0ebcc9-8cfa-4384-a87e-7fdceb3a249e"
            }
            formType = @{
                guid = "95f176f7-9c7d-4877-8263-61a571d016c0"
            }
            formFields = @(
                @{
                guid = "6aa827df-5e33-4e38-8da5-acd36e64f589"
                svalue = "$($item.nda_id)"
                 },
                @{
                     guid = "b7a98539-80c8-497b-a873-b6b169aa8bb6"   #1Data wejścia umowy w życie  do poprawy
                    svalue = "$($item.nda_DataZawarciaUmowy)"
                },
                @{
                     guid = "c426d8f1-3b6d-4695-8f8d-f77aafccef98" #  2 [tech] umowa + lata
                    svalue = "$($item.nda_DataObowiaywaniaUmowy)"
                },
                @{
                     guid = "4afa9d35-ce1c-445f-9bcc-a85f8b490070" #  3 Czas obowiązywania umowy (lata)
                     svalue = "$($item.nda_CzasUmowyLata)"
                },
                @{
                    guid = "3da30053-1f5c-402a-9833-a781baac1ecc" #  5Nazwa firmy
                     svalue = "$($item.nda_kontrahent)"
                },
                @{
                     guid = "d37bc66d-5d6f-4a53-976a-2994df2424fa" #  6Cel i zakres
                      svalue = "$($item.nda_projekt)"
                },
                @{
                     guid = "5c49bbbe-d062-4202-975c-b3ac360e3a8d" #  7Okres ochrony (lata)
                    svalue = "$($item.nda_CzasUmowyLata)"
                }
            )
         
           attachments = $item.attachments
           } | ConvertTo-Json -Depth 5
         
          $testBody = [System.Text.Encoding]::UTF8.GetBytes($body)
          
            try{
         
           $response =  Invoke-RestMethod -Method Post -Uri $new -Body $testBody  -Headers $headers 
            Write-MessageLog "[Line 294] Instance created for  $($item.nda_id) -> $($response.id)" 
        
        }catch{
        Write-Error "[Line 297] Error : $_" #-Level "ERROR"
        return $null
    }
    }  
        # $response | ConvertTo-Json -Depth 5
}
$response = @(Start-New -baseUrl $baseUrl -clientId $CLIENT_ID -clientSecret $CLIENT_SECRET)

