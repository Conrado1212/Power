
# $baseUrl = ""
<#pobranie zmiennych zrodlowe #>
#$CLIENT_ID = "9484677e-3824-4d7a-8ef1-95e54725d68d"
$CLIENT_ID = "8f837b0e-1ce3-4fa1-8f3b-583a4934387a"
#$CLIENT_SECRET = "oRRObkoJjjKqMmqlfNQZhyDyRQh8aLtdBIl3EsFRXTI="
$CLIENT_SECRET = "EPgjpzw0jOHPl8nibBwEfQkfw9fx1uCD8BZNuduYW2o="
#$baseUrl = "https://kt01.webcon.pl"
$baseUrl = "https://bpsod.webcon.pl/5675"
#$response1 = Get-Group -baseUrl $baseUrl

    if(-not $baseUrl){
     $baseUrl = Read-Host "Write your baseUrl (example. https://example.com)"
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

        $clientId = Read-Host "Write  CLIENT_ID"
        }else{
         Write-Host  "Variable clientId value retrieved"
        }

        if ([string]::IsNullOrWhiteSpace($clientSecret)) {
             $clientSecret = Read-Host "Write CLIENT_SECRET"
        }else{
          Write-Host   "Variable clientSecret value retrieved"
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
            Write-Error "Error authentication: $_"
            return $null
        }
} 

function Get-Group{
    param(
        [string]$baseUrl,
        [string]$clientId,
        [string]$clientSecret
    )
    $token = Get-AccessToken -baseUrl $baseUrl -clientId $clientId -clientSecret $clientSecret

    if (-not $token) {
        Write-Error "No token"
        return
    }

    $headers = @{
    Authorization = "Bearer $token"
    }

    $apiGroup = "$baseUrl/api/data/v6.0/admin/groups?size=30000"
    
    try{
         $respone = Invoke-RestMethod -Method Get -Uri $apiGroup  -Headers $headers
         return $respone.groups
    }catch{
         Write-Error "Error : $_"
         return $null
    }

}

$response = Get-Group -baseUrl $baseUrl -clientId $CLIENT_ID -clientSecret $CLIENT_SECRET
Write-Host "Liczba grup w srodowisku 1: $($response.Count)"
#$response | Format-Table bpsId, name, email        zakomentowanie wypisanie grup srodowisko z ktorego chce migrowac


#$CLIENT_ID1 = "58888553-99c5-415d-8ab2-2e68f45d799e"
$CLIENT_ID1 = "153d6df7-e2ac-4c66-90c2-8b9885ce38a8"
#$CLIENT_SECRET1 = "BeF/pn95w2LIv7dupqEedA8H4e8gD/+bfHp7ROV8jwI="
$CLIENT_SECRET1 = "YiZqsxMbDeCDWSRIC/wVuDI7Flvqg81d5wRrV8/CMXE="
#$baseUrl1 = "https://kt05.webcon.pl"
$baseUrl1 = "https://bpsod.webcon.pl/5673"
$response1 = Get-Group -baseUrl $baseUrl1 -clientId $CLIENT_ID1 -clientSecret $CLIENT_SECRET1
Write-Host "Liczba grup w srodowisku 2: $($response1.Count)"
#$response1 | Format-Table bpsId, name, email   zakomentowanie wypisanie grup srodowisko do ktorego chce migrowac


Write-Host 'Only in one'
$onlyIn1env = $response | Where-Object { $_.bpsId -notin ($response1.bpsId) } #powinno byc  bpsID
Write-Host "Liczba grup innych niz w srodowisku 2: $($onlyIn1env.Count)"
$onlyIn1env | Format-Table bpsId, name, email


<#Write-Host 'Only in two'
$onlyIn2env = $response1 | Where-Object { $_.bpsId -notin ($response.bpsId) }
Write-Host "Liczba grup innych niz w srodowisku 1 : $($onlyIn2env.Count)"
$onlyIn1env 
Write-Host 'common'
$commonGroups = $response | Where-Object { $_.bpsId -in ($response1.bpsId) }
Write-Host "Liczba grup wspolnych : $($commonGroups.Count)"
$commonGroups
#>
#$response = Get-Group -baseUrl $baseUrl -clientId "client_id_1" -clientSecret "secret_1"
#$response1 = Get-Group -baseUrl $baseUrl1 -clientId "client_id_2" -clientSecret "secret_2"

function Create-Group{
     param(
     [string]$baseUrl,
     [string]$clientId,
     [string]$clientSecret,
     [array]$groupToCreate
     )
    $token = Get-AccessToken -baseUrl $baseUrl -clientId $clientId -clientSecret $clientSecret

      if (-not $token) {
        Write-Error "No token"
        return
    }

    $headers = @{
    Authorization = "Bearer $token"
    "Content-Type" = "application/json"
    }

     $createGroupUrl = "$baseUrl/api/data/v6.0/admin/groups"
    foreach($group in $groupToCreate){
        if(-not $group.email){
            $group.email = $group.bpsId
        }
        $body =@{
            bpsId = $group.bpsId
            name = $group.name
            email = $group.email
            } | ConvertTo-Json -Depth 3
            
            $body | Write-Host

            try{
            $respone = Invoke-RestMethod -Method Post -Uri $createGroupUrl -Body $body  -Headers $headers
            Write-Host "Group created $($group.bpsId)" 
        }catch{
        Write-Error "Error : $_"
        return $null
    }
    }  
}


if($onlyIn1env.count -gt 0){
    Write-Host "Number of missing groups: $($onlyIn1env.Count)"
    $userInput = Read-Host "Do you want to create the missing groups in second envirounment? (T/N)"
    if($userInput -eq "T"){
        Create-Group -baseUrl $baseUrl1 -clientId $CLIENT_ID1 -clientSecret $CLIENT_SECRET1  -groupToCreate $onlyIn1env
    }else{
        Write-Host "Group creation was skipped"
    }
}

function Get-Member-From-Group{
     param(
     [string]$baseUrl,
     [string]$clientId,
     [string]$clientSecret,
     [array]$checkGroupMember
     )
     $token = Get-AccessToken -baseUrl $baseUrl -clientId $clientId -clientSecret $clientSecret

      if (-not $token) {
        Write-Error "No token"
        return
    }

    $headers = @{
    Authorization = "Bearer $token"
    "Content-Type" = "application/json"
    }
     # miec wszystkie grupy i sprawdzic ich czlonkow z jednego srodwiska i drugiego $response 

    
    $result = @()
     foreach($group in $checkGroupMember){
        $groupID = $group.bpsId
      # $groupID |  Write-Host 
         $memberUrl = "$baseUrl/api/data/v6.0/admin/groups/$groupID"
            try{
            $response = Invoke-RestMethod -Method Get -Uri $memberUrl -Headers $headers
           # Write-Host "Group member from $($groupID) -> $($response.members)"  narazie komentarz wypisuje grupe oraz jej czlonkow
            $result +=[PSCustomObject]@{
                bpsId = $groupID
                members =$response.members
            }
        }catch{
        Write-Error "fetching members for group $groupId : $_"
        return $null
    }
    }  
    return $result
}

$userInput = Read-Host "Do you want to check members? (T/N)"
if($userInput -eq "T"){
     $groupMemberenv1  = Get-Member-From-Group -baseUrl $baseUrl -clientId $CLIENT_ID -clientSecret $CLIENT_SECRET  -checkGroupMember $response
     
     
     Write-Host "Grupy z zrodlowego: $($groupMemberenv1 | ConvertTo-Json -Depth 5)"

     $groupMemberenv2 = Get-Member-From-Group -baseUrl $baseUrl1 -clientId $CLIENT_ID1 -clientSecret $CLIENT_SECRET1 -checkGroupMember $response1
     
    Write-Host "Grupy z docelowego: $($groupMemberenv2 | ConvertTo-Json -Depth 5)"

    }else{
        Write-Host "Check member creation was skipped"
    }

function Compare-Group-Members{
   # Pobranioe grup oraz ich czlonkow ze pomoca parametrow
    param(
        [array]$groupMemberenv1,
        [array]$groupMemberenv2
    )
    #iniclaizuje dwie tablice 
    $result = @()
    $result2 = @()
#iteruje po 1 grupie i sprawdzam czy nie ma innych grup w drugim srodoiwsku 
    foreach($group1 in $groupMemberenv1){
        $groupID = $group1.bpsId
        $group2 = $groupMemberenv2 | Where-Object {$_.bpsId -eq $groupID}

        if(-not $group2){
            Write-Host "Group $groupId not found in second environment"
            continue
        }
        # pobranie czlonkow grup z 1  
        $members1 = $group1.members
        Write-Host  "Members in ev1 for group $groupID" 
        #sprawdzenie ilosci czlonkow grup
        if($members1.count -eq 0){
            Write-Host  "No members"
        }else{
            #iteruje po members wypoisujac kazdego czlonka grupy 
            $members1 | foreach-Object {Write-Host " - [$($_.GetType().Name)] '$($_.bpsId)'"}
          #maybe tak   $members1 | foreach-Object {Write-Host " - $($_.name) <$($_.email)> [$($_.bpsId)]"}
          #maybe tak   $members1 | foreach-Object {$_ | ConvertTo-Json -Depth 3 }
        }
        # pobranie czlonkow grup z 1  
        $members2 = $group2.members

          Write-Host  "Members in ev2 for group $groupID" 
          #sprawdzenie ilosci czlonkow grup
        if($members2.count -eq 0){
            Write-Host  "No members"
        }else{
            $members2 | foreach-Object {Write-Host " - [$($_.GetType().Name)] '$($_.bpsId)'"}
               #maybe tak   $members1 | foreach-Object {Write-Host " - $($_.name) <$($_.email)> [$($_.bpsId)]"}
          #  $members2 | foreach-Object {$_ | ConvertTo-Json -Depth 3 }
        }

        #normalizacja danych chyba do wywalenia 
        $normalizedMembers1 = $members1 | ForEach-Object { $_.bpsId.ToString().Trim().ToLower() }
        $normalizedMembers2 = $members2 | ForEach-Object { $_.bpsId.ToString().Trim().ToLower() }


        #Przechodzi przez każdy element w $normalizedMembers1.

        #Sprawdza, czy nie występuje w $normalizedMembers2.

        #Wynik: lista członków, którzy są tylko w środowisku 1 (env1), a nie ma ich w env2.
        $onlyIn1env = $normalizedMembers1 | Where-Object {$_ -notin $normalizedMembers2}
        
        $onlyIn2env = $normalizedMembers2 | Where-Object {$_ -notin $normalizedMembers1}

        
        if($onlyIn1env.count -eq 0 -and $onlyIn2env.count -eq 0){
            Write-Host "Group $groupID has identical members"
        }else{
             Write-Host "`n Differences in $groupID"
        
             if($onlyIn1env.count -gt 0 ){  
                Write-Host " - Only in Env1:"
                forEach($bpsId in $onlyIn1env){
                    $member =  $members1 | Where-Object {$_.bpsId.trim().ToLower -eq $bpsId } 
                    if($member){
                 #    $name = if ($member.name) { $member.name } else { "?" }
               #     $email = if ($member.email) { $member.email } else { "?" }
               #  Write-Host "   -$($member.name) <$($member.email)> [$($member.bpsId)]" 
                        Write-Host "   - $name <$email> [$($member.bpsId)]"
 
                 $result += [PSCustomObject]@{
                        bpsGroupId   = $groupID
                        bpsMemberId  = $member.bpsId
                        environment  = "Env1"

                 }
                    }else{
                        Write-Host "Not found $bpsId inEv1"
                    }
               
                }
             #  $members1 | Where-Object {$_.bpsId.trim().ToLower -in $onlyIn1env } | ForEach-Object {
             #    Write-Host "   -$($_.name) <$($_.email)> [$($_.bpsId)]" }
            
             }

             if($onlyIn2env.count -gt 0 ){  
                Write-Host " - Only in Env2:"
            forEach($bpsId in $onlyIn2env){
                    $member =  $members2 | Where-Object {$_.bpsId.trim().ToLower -eq $bpsId } 
                    if($member){
                   #  $name = if ($member.name) { $member.name } else { "?" }
                  #      $email = if ($member.email) { $member.email } else { "?" }
                Write-Host "   - $name <$email> [$($member.bpsId)]"
                 $result2 += [PSCustomObject]@{
                        bpsGroupId   = $groupID
                        bpsMemberId  = $member.bpsId
                        environment  = "Env2"
                 }
                    }else{
                        Write-Host "Not found $bpsId inEv2"
                    }
                # Write-Host "   -$($member.name) <$($member.email)> [$($member.bpsId)]" 
               
                }

             #   $members2 | Where-Object {$_.bpsId.trim().ToLower -in $onlyIn2env } | ForEach-Object {
              #   Write-Host "   -$($_.name) <$($_.email)> [$($_.bpsId)]" }
              
             }
        }
    }
    return @{
        env1 = $result
        env2 = $result2
     }
}



$comp = Compare-Group-Members -groupMemberenv1 $groupMemberenv1 -groupMemberenv2 $groupMemberenv2

$env1 = $comp.env1
$env2 = $comp.env2


$env1 | Format-Table
$env2 | Format-Table



function Add-Member-To-BpsGroup{
     param(
     [string]$baseUrl,
     [string]$clientId,
     [string]$clientSecret,
     [array]$groupMember
     )
      $token = Get-AccessToken -baseUrl $baseUrl -clientId $clientId -clientSecret $clientSecret

      if (-not $token) {
        Write-Error "No token"
        return
    }

    $headers = @{
    Authorization = "Bearer $token"
    "Content-Type" = "application/json"
    }
    
    foreach($group in $groupMember){
        $groupID = $group.bpsId
        $memberList =@()

        foreach($member in $group.member){
            $memberList +=[PSCustomObject]@{
            bpsId = $member.bpsId
        }
        }

        $body =@{
            members = $memberList
            } | ConvertTo-Json -Depth 3

            $memberUrl = "$baseUrl/api/data/v6.0/admin/groups/$groupID/members/add"

            try{
            $response = Invoke-RestMethod -Method Post -Uri $memberUrl -Headers $headers -Body $body
            Write-Host "Added members to group $groupID"
            
        }catch{
        Write-Error "fetching members for group $groupId : $_"
        return $null
    }
    }  
 
}












   
