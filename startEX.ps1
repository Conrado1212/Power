# pobranie danych 

$CLIENT_ID = "abc736e7-a4eb-4b3b-b565-7d0c92ee882a"

$CLIENT_SECRET = "XkTsZgPxYXnSOO83tSt5Map3PtFamjgZm855IM3QYdg="


$baseUrl = "https://bpsod.webcon.pl/5774"


if(-not $baseUrl){
    $baseUrl = Read-Host "[Line 14] Write your baseUrl (example. https://example.com)"
   }

   function Get-AccessToken{
    #parametr base url ktory podaje user
    #pobranei clientId oraz cleitnsecret jako zmiennej srodwoiskowej 
        param(
            [string]$baseUrl,
            [string]$clientId,
            [string]$clientSecret
        )
        if ([string]::IsNullOrWhiteSpace($clientId)) {

        $clientId = Read-Host "[Line 26] Write  CLIENT_ID"
        }else{
         Write-Host  "[Line 28] Variable clientId value retrieved"
        }

        if ([string]::IsNullOrWhiteSpace($clientSecret)) {
             $clientSecret = Read-Host "Write CLIENT_SECRET"
        }else{
          Write-Host   "[Line 33] Variable clientSecret value retrieved"
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
            Write-Error "[Line 51] Error authentication: $_"
            return $null
        }
} 

function Get-DataFromExcel{
    $excel = New-Object -ComObject Excel.Application
        $workbook = $excel.Workbooks.Open("")
        $sheet = $workbook.Sheets.Item(1)
    
        $dane =@()
    
        for ($i = 1; $i -lt 3; $i++) {
            try{
                $dane += [PSCustomObject]@{
                    id = $i
                    col1 = $sheet.Cells.Item($i,1).Text
                    col2 = $sheet.Cells.Item($i,2).Text
                }
            }catch{
                Write-Warning "[Line 71] E in row $i : $_"
            }
        }
        $workbook.Close($false)
        $excel.Quit()
        # foreach ($wiersz in $dane) {
        #     Write-Host "Imię: $($wiersz.Imie), Nazwisko: $($wiersz.Nazwisko)"
        # }
        # Write-Host "Line 26" 
        return $dane #| Format-Table -AutoSize
    }
function Start-New{
    param(
        [string]$baseUrl,
        [string]$clientId,
        [string]$clientSecret
    )
    $token = Get-AccessToken -baseUrl $baseUrl -clientId $clientId -clientSecret $clientSecret

    if (-not $token) {
        Write-Error "[Line 91] No token"
        return
    }

    $headers = @{
    Authorization = "Bearer $token"
    }
    $new = "$baseUrl/api/data/v6.0/db/1/elements?path=ef583612-fbc2-4705-a239-8049956e929e"
    
   $dane =  Get-DataFromExcel

    foreach($item in $dane){
        
        $body =@{
            workflow = @{
                guid = "7c22806f-2196-43ec-b130-95e19600a537"
            }
            formType = @{
                guid = "b4b4525f-3c3b-4aef-a5d3-2ef60bf39235"
            }
            formFields = @(
                @{
                    guid = "6ff1a837-7db8-4ddd-b7f0-0b92e640aa19"
                    svalue = "$item.col1"
                },
                @{
                    guid = "d7527952-7ca7-4a21-a1c4-f7b6b4cb0969"
                    svalue = "$item.col2"
                }
            )
           } | ConvertTo-Json -Depth 3
          # $allGroupsParam +=$body
        #  $testBody = [System.Text.Encoding]::UTF8.GetBytes($body)
           Write-Host "[Line 124] New Instance Params $Body"
            try{
           $response = Invoke-RestMethod -Method Post -Uri $new -Body $body  -Headers $headers 
            Write-Host "[Line 127] Instance created for $($item.id)" 
            Write-Host "[Line 128] Instance created for $($response | ConvertTo-Json -Depth 5)" 
        }catch{
        Write-Error "[Line 129] Error : $_"
        return $null
    }
    }  

}

$response = @(Start-New -baseUrl $baseUrl -clientId $CLIENT_ID -clientSecret $CLIENT_SECRET)
#Write-Host "[line 138] data: $($response)"