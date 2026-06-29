

<#pobranie zmiennych zrodlowe #>

$CLIENT_ID = "abc736e7-a4eb-4b3b-b565-7d0c92ee882a"

$CLIENT_SECRET = "XkTsZgPxYXnSOO83tSt5Map3PtFamjgZm855IM3QYdg="
#$baseUrl = "https://kt01.webcon.pl"
#$baseUrl = "https://bpsod.webcon.pl/5675"
$baseUrl = "https://bpsod.webcon.pl/5774"
#$response1 = Get-Group -baseUrl $baseUrl

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
          Write-Host   "[Line 34] Variable clientSecret value retrieved"
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
            Write-Error "[Line 52] Error authentication: $_"
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
        Write-Error "[Line 66] No token"
        return
    }

    $headers = @{
    Authorization = "Bearer $token"
    }

    $apiGroup = "$baseUrl/api/data/v6.0/admin/groups?size=30000"
    
    try{
         $response = Invoke-RestMethod -Method Get -Uri $apiGroup  -Headers $headers
         #$response | ConvertTo-Json -Depth 10
       # Write-Host $response.groups
       # Write-Host "Type getgroup " $response.groups.GetType()
         return $response.groups
    }catch{
         Write-Error "[Line 83] Error : $_"
         return $null
    }

}

$response = @(Get-Group -baseUrl $baseUrl -clientId $CLIENT_ID -clientSecret $CLIENT_SECRET)
Write-Host "[line 90] Liczba grup w srodowisku 1: $($response.Count)"
#$response   | Format-Table bpsId, name, email   # zakomentowanie wypisanie grup srodowisko z ktorego chce migrowac



$CLIENT_ID1 = "2fa8c988-5266-4d91-8d4c-5789456da8cc"
#$CLIENT_SECRET1 = ""

$CLIENT_SECRET1 = "t/5WwKsVS88W4OgaJgHwATiD5hDBUePqgeCuFg+AfYE="

#$baseUrl1 = "https://bpsod.webcon.pl/5673"
$baseUrl1 = "https://bpsod.webcon.pl/5775"
$response1 = @(Get-Group -baseUrl $baseUrl1 -clientId $CLIENT_ID1 -clientSecret $CLIENT_SECRET1)
Write-Host "[Line 103] Liczba grup w srodowisku 2: $($response1.Count)"
#$response1 | Format-Table bpsId, name, email   zakomentowanie wypisanie grup srodowisko do ktorego chce migrowac


Write-Host '[Line 107] Only in one'
#$bps2 = $response1 | Select-Object -ExpandProperty bpsId
#$bps2 | ForEach-Object { Write-Host $_ }
$onlyIn1env = @($response | Where-Object { $_.bpsId -notin ($response1.bpsId) }) #powinoo byc bpsId ($response1.bpsId)
$onlyIn1env | Format-Table bpsId, name, email

#Write-Host "Typ: $($onlyIn1env.GetType().Name)"

Write-Host "[Line 115] Liczba grup innych niz w srodowisku 2: $($onlyIn1env.Count)"

#$onlyIn1env | Format-Table bpsId, name, email


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

function New-Group{
     param(
     [string]$baseUrl,
     [string]$clientId,
     [string]$clientSecret,
     [array]$groupToCreate
     )
    $token = Get-AccessToken -baseUrl $baseUrl -clientId $clientId -clientSecret $clientSecret

      if (-not $token) {
        Write-Error "[Line 142] No token"
        return
    }

    $headers = @{
    Authorization = "Bearer $token"
    "Content-Type" = "application/json; charset=utf-8"
    }

     $createGroupUrl = "$baseUrl/api/data/v6.0/admin/groups"
    # $allGroupsParam =@()
    foreach($group in $groupToCreate){
        if(-not $group.email){
            $group.email = $group.bpsId
        }
        $body =@{
            bpsId = $group.bpsId
           name = $group.name
           email = $group.email
           } | ConvertTo-Json -Depth 3
          # $allGroupsParam +=$body
          $testBody = [System.Text.Encoding]::UTF8.GetBytes($body)
           Write-Host "[Line 164] Group Params $body"
            try{
            Invoke-RestMethod -Method Post -Uri $createGroupUrl -Body $testBody  -Headers $headers 
            Write-Host "[Line 167] Group created $($group.bpsId)" 
        }catch{
        Write-Error "[Line 169] Error : $_"
        return $null
    }
    }  
      #$allGroupsParam  | Out-File -FilePath "C:\Users\k.krawczyk\Desktop\xd\fizyk\prymat\mail\test.json" 
}
if($onlyIn1env.count -gt 0){
    Write-Host "[Line 176] Number of missing groups: $($onlyIn1env.Count)"
    $userInput = Read-Host "[Line 177] Do you want to create the missing groups in second envirounment? (Y/N)"
    if($userInput -eq "Y"){
        New-Group -baseUrl $baseUrl1 -clientId $CLIENT_ID1 -clientSecret $CLIENT_SECRET1  -groupToCreate $onlyIn1env
        $maxRetries = 5
        $retryCount = 0
    do{
    $response1 = Get-Group -baseUrl $baseUrl1 -clientId $CLIENT_ID1 -clientSecret $CLIENT_SECRET1
    $missingGroups = $onlyIn1env | Where-Object { $_.bpsId -notin $response1.bpsId}
    if($missingGroups.Count -eq 0){     
        Write-Host "[Line 186] Groups synchronized"
        break
    }else{
        Write-Host "[Line 189] Waiting for sync ($retryCount/$maxRetries)  miss group $($missingGroups.Count)"
        Start-Sleep -Seconds 5
        $retryCount++
    }
}while($retryCount -lt $maxRetries)


if ($missingGroups.Count -gt 0) {
    Write-Warning "[Line 197] Some groups not ready after $($maxRetries * 5) sec."
}
    }else{
        Write-Host "[Line 200] Group creation was skipped"
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
        Write-Error "[Line 223] No token"
        return
    }

    $headers = @{
    Authorization = "Bearer $token"
    "Content-Type" = "application/json"
    }
     # miec wszystkie grupy i sprawdzic ich czlonkow z jednego srodwiska i drugiego $response 
    $allGroup = Get-Group -baseUrl $baseUrl -clientId $clientId -clientSecret $clientSecret
    if(-not $allGroup){
        Write-Error "[Line 234] No group from $baseUrl"
        return
    }
    $result = @()
     foreach($group in $checkGroupMember){
        $groupID = $group.bpsId
        $isGroup = $allGroup | Where-Object {$_.bpsId -eq $groupID}
        if(-not $isGroup){
            Write-Warning "[Line 242] Group $groupID not exist in $baseUrl skip"
            continue
        }
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
        Write-Error "[Line 255] Error fetching members for group $groupId : $_"
        return $null
    }
    }  
    return $result
}

$userInputM = Read-Host "[Line 262] Do you want to check members? (Y/N)"
if($userInputM -eq "Y"){
     $groupMemberenv1  = Get-Member-From-Group -baseUrl $baseUrl -clientId $CLIENT_ID -clientSecret $CLIENT_SECRET  -checkGroupMember $response
     
     
     Write-Host "[Line 267] Grupy z zrodlowego: $($groupMemberenv1 | ConvertTo-Json -Depth 5)"

     $groupMemberenv2 = Get-Member-From-Group -baseUrl $baseUrl1 -clientId $CLIENT_ID1 -clientSecret $CLIENT_SECRET1 -checkGroupMember $response1
     
    Write-Host "[Line 271] Grupy z docelowego: $($groupMemberenv2 | ConvertTo-Json -Depth 5)"

    }else{
        Write-Host "[Line 274] Check member creation was skipped"
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
            Write-Host "[Line 292] Group $groupId not found in second environment"
            continue
        }
        # pobranie czlonkow grup z 1  
       $members1 = $group1.members
       
        Write-Host  "[Line 298] Members in ev1 for group $groupID" 
        #sprawdzenie ilosci czlonkow grup
        if($members1.count -eq 0){
            Write-Host  "[Line 301] No members"
        }else{
              #iteruje po members wypoisujac kazdego czlonka grupy 
           $members1 | foreach-Object {Write-Host " - '$($_.bpsId)'"}
             #maybe tak   $members1 | foreach-Object {Write-Host " - $($_.name) <$($_.email)> [$($_.bpsId)]"}
          #maybe tak 
         #   $members1 | foreach-Object {$_ | ConvertTo-Json -Depth 3 }
        }
 # pobranie czlonkow grup z 1  
        $members2 = $group2.members
#sprawdzenie ilosci czlonkow grup
          Write-Host  "[Line 312] Members in ev2 for group $groupID" 
        if($members2.count -eq 0){
            Write-Host  "[Line 314] No members"
        }else{
            $members2 | foreach-Object {Write-Host "[Line 316] - '$($_.bpsId)'"}
                  #maybe tak   $members1 | foreach-Object {Write-Host " - $($_.name) <$($_.email)> [$($_.bpsId)]"}
         #   $members2 | foreach-Object {$_ | ConvertTo-Json -Depth 3 }
        
        }

         #normalizacja danych 
        $normalizedMembers1 = $members1 | ForEach-Object { $_.bpsId.ToString().Trim().ToLower() }
        $normalizedMembers2 = $members2 | ForEach-Object { $_.bpsId.ToString().Trim().ToLower() }

        $onlyIn1env = $normalizedMembers1 | Where-Object {$_ -notin $normalizedMembers2}
        
        $onlyIn2env = $normalizedMembers2 | Where-Object {$_ -notin $normalizedMembers1}

        #lece przez każdy element w $normalizedMembers1.

        #Sprawdzam czy nie występuje w $normalizedMembers2.

        #Wynik: lista członków, którzy są tylko w środowisku 1 (env1), a nie ma ich w env2.
        if($onlyIn1env.count -eq 0 -and $onlyIn2env.count -eq 0){
            Write-Host "[Line 336] Group $groupID has identical members"
        }else{
             Write-Host "`n [Line 338] Differences in $groupID"
        
             if($onlyIn1env.count -gt 0 ){  
                Write-Host "[Line 341] - Only in Env1:"
                forEach($bpsId in $onlyIn1env){
                  #  Write-Host "[Line 346] Test czlonek grupy" $bpsId
               # Write-Host "Test members in Env1 (full object):"
             #   $members1 | ForEach-Object { $_ | ConvertTo-Json -Depth 3 }

                    $member =  $members1 | Where-Object {$_.bpsId.ToString().Trim().ToLower() -eq $bpsId }   # tu cos jest  i do poprawy 
                    if($member){
                   # Write-Host "Wypisanie memeber $member"
                     $name = if ($member.name) { $member.name } else { "?" }
                    $email = if ($member.email) { $member.email } else { "?" }
                    $type = if ($member.type) { $member.type } else { "?" }
               #  Write-Host "   -$($member.name) <$($member.email)> [$($member.bpsId)]" 
                     #   Write-Host "   - $name <$email> [$($member.bpsId)]"
                   #     Write-Host "   - [$($member.bpsId)]"
 
                 $result += [PSCustomObject]@{
                        bpsGroupId   = $groupID
                        bpsMemberId  = $member.bpsId
                        MemberName =    $name
                        MemberEmail =   $email
                        MemberType =   $type
                        environment  = "Env1"

                 }
                    }else{
                        Write-Host "[Line 367] NO MATCH FOUND for $bpsId in Env1"
                    }
               
                }
             #  $members1 | Where-Object {$_.bpsId.trim().ToLower -in $onlyIn1env } | ForEach-Object {
             #    Write-Host "   -$($_.name) <$($_.email)> [$($_.bpsId)]" }
            
             }

             if($onlyIn2env.count -gt 0 ){  
                Write-Host "[Line 377] - Only in Env2:"
            forEach($bpsId in $onlyIn2env){
                    $member =  $members2 | Where-Object {$_.bpsId.ToString().Trim().ToLower() -eq $bpsId } 
                    if($member){
                     $name = if ($member.name) { $member.name } else { "?" }
                        $email = if ($member.email) { $member.email } else { "?" }
                        $type = if ($member.type) { $member.type } else { "?" }
              #  Write-Host "   - $name <$email> [$($member.bpsId)]"
                Write-Host "   - [$($member.bpsId)]"
                 $result2 += [PSCustomObject]@{
                        bpsGroupId   = $groupID
                        bpsMemberId  = $member.bpsId
                        MemberName =    $name
                        MemberEmail =   $email
                        MemberType =   $type
                        environment  = "Env2"
                 }
                    }else{
                        Write-Host "[Line 395] Not found $bpsId inEv2"
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

if($env1){Write-Host "[Line 420]" $env1 } #| Format-Table}
If($env2) {Write-Host "[Line 421]" $env2 | Format-Table}

function Get-User{
     param(
     [string]$baseUrl,
     [string]$clientId,
     [string]$clientSecret,
     [string]$user
     )
      $token = Get-AccessToken -baseUrl $baseUrl -clientId $clientId -clientSecret $clientSecret

      if (-not $token) {
        Write-Error "[Line 433] No token"
        return
    }

    $headers = @{
    Authorization = "Bearer $token"
    "Content-Type" = "application/json"
    }

    
            $userUrl = "$baseUrl/api/data/v6.0/admin/user?bpsId=$user"

            try{
          return ( Invoke-RestMethod -Method Get -Uri $userUrl -Headers $headers )
            
        }catch{
                Write-Host "[Line 449] $user not found in env2"
                # Write-Error "[Line 445] Error : $_"
        return $null
}
}
function Add-User{
    param(
     [string]$baseUrl,
     [string]$clientId,
     [string]$clientSecret,
     [string]$userID,
     [string]$userName,
     [string]$userEmail
     )
      $token = Get-AccessToken -baseUrl $baseUrl -clientId $clientId -clientSecret $clientSecret

      if (-not $token) {
        Write-Error "[Line 466] No token"
        return
    }
    $headers = @{
    Authorization = "Bearer $token"
    "Content-Type" = "application/json"
    }
        $userCreateUrl = "$baseUrl/api/data/v6.0/admin/users"
    $body = @{
            bpsId = $userID
            name = $userName
            email = $userEmail
    }| ConvertTo-Json -Depth 3
    $testBody = [System.Text.Encoding]::UTF8.GetBytes($body)
       Write-Host "[Line 480] $body" 
            try{
            Invoke-RestMethod -Method Post -Uri $userCreateUrl -Headers $headers -body $testBody 
            
        }catch{
                 Write-Error "[Line 485] Error : $_"
        return $null
}
}
function Add-Member-To-BpsGroup{
     param(
     [string]$baseUrl,
     [string]$clientId,
     [string]$clientSecret,
     [array]$groupMember
     )
      $token = Get-AccessToken -baseUrl $baseUrl -clientId $clientId -clientSecret $clientSecret

      if (-not $token) {
        Write-Error "[Line 499] No token"
        return
    }

    $headers = @{
    Authorization = "Bearer $token"
    "Content-Type" = "application/json"
    }
    $memberList = @{}
    foreach($group in $groupMember){
        $groupID = $group.bpsGroupId
        $memberId = $group.bpsMemberId
        $memberName = $group.MemberName
        $memberEmail = $group.MemberEmail
        $memberType = $group.MemberType
        Write-Host  "[Line 513] Member info $memberId " -NoNewline
        Write-Host $memberType  -ForegroundColor Yellow
        #sprawdzenie czy memeber istniejes na drugim srodowisku
        $exitsMember = Get-User -baseUrl $baseUrl -clientId $clientId -clientSecret $clientSecret -user $memberId
        #dorbic check na name bo inaczejs ie nie da a tak to sie wywali dla register app"
       # $name = $exitsMember.name
      # Write-Host "[Line 518] $name"
        if(-not $memberList.ContainsKey($groupID)){
            $memberList[$groupID] = @()
        }
        if(-not $exitsMember -and $memberType -eq 'User'){
           # Write-Host "$memberId not exist in  env2"
            $userInput = Read-Host "[Line 526] Do you want to create this user $memberId as bpsUser? (Y/N)"
            if($userInput -eq "Y"){
            
             Add-User -baseUrl $baseUrl -clientId $clientId -clientSecret $clientSecret -userID $memberId -userName $memberName -userEmail $memberEmail
             $maxRetries = 5
            $retryCount = 0
            do{
            Write-Host "[Line 533] Synchronizing user: $memberId"
            Start-Sleep -Seconds 7
            $exitsMember  = Get-User -baseUrl $baseUrl -clientId $clientId -clientSecret $clientSecret -user $memberId
            $retryCount++
            }while(-not $exitsMember -and $retryCount -lt $maxRetries)
             $memberList[$groupID] +=[PSCustomObject]@{
             bpsId =$memberId
            }
            Write-Host "[Line 541] User: $memberId synchronized"
            }
        }elseif($exitsMember -and $exitsMember.name.EndsWith("- Registered App")){
         Write-Host "[line 544] Only account of type User or AdGroup can be a member of BPS group skipping add for member $memberId" -ForegroundColor Yellow   
        }elseif(-not $exitsMember -and $memberType -eq 'AdGroup'){
            Write-Host "[line 546] Adgroup not exist in 2 env skipping $memberId" -ForegroundColor Yellow   
                    #dobra pytanie czy tworzyc adgroupy jak bps grupy w sumie nie bo i tak bedzie pusta 
        }else{
            $memberList[$groupID] +=[PSCustomObject]@{
             bpsId =$memberId
            }
        }
        
    }
    Write-Host "[Line 552] MemberList $memberList"
        foreach($groupID in $memberList.Keys){
        $body =@{
            members = $memberList[$groupID]
            } | ConvertTo-Json -Depth 3

            $memberUrl = "$baseUrl/api/data/v6.0/admin/groups/$groupID/members/add"

            try{
            #Write-Host "Body: $body"  
            Invoke-RestMethod -Method Post -Uri $memberUrl -Headers $headers -Body $body
            foreach($member in $memberList[$groupID]){
                Write-Host "[Line 564] Added members $member to group $groupID"
            }
            
        }catch{
             foreach($member in $memberList[$groupID]){
                 Write-Error "[Line 569] Problem with $member for group $groupId : $_"
            }
        return $null
    }
    }  

}
if($userInputM -eq 'Y'){
$userInput = Read-Host "[Line 577] Do you want to add missing member to group? (Y/N)"
if($userInput -eq "Y"){
     $groupMemberenv2  = Add-Member-To-BpsGroup -baseUrl $baseUrl1 -clientId $CLIENT_ID1 -clientSecret $CLIENT_SECRET1  -groupMember $env1
    }else{
        Write-Host "[Line 581] Group member creation was skipped"
    }
}

  
