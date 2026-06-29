

<#getting source variables #>

$CLIENT_ID = Get-Secret -Name 'CLIENT_ID'

$CLIENT_SECRET = Get-Secret -Name 'CLIENT_SECRET'


$baseUrl = "https://bpsod.webcon.pl/5774"


    if(-not $baseUrl){
     $baseUrl = Read-Host "[Line 14] Write your baseUrl (example. https://example.com)"
    }
function Get-AccessToken{
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
       
        
        #authentication method url
        $tokenUrl = "$baseUrl/api/oauth2/token"
       
        $body =@{
            grant_type = "client_credentials"
            client_id = $clientId
            client_secret = $clientSecret
        }
        try{
           
            $respone = Invoke-RestMethod -Method Post -Uri $tokenUrl -Body $body -ContentType "application/x-www-form-urlencoded" 
            return $respone.access_token
        }catch{
          
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
    $allGroups = @()
    $page = 0;
    $size = 1000;
    $isMore = $true;
    while($isMore){
    $apiGroup = "$baseUrl/api/data/v6.0/admin/groups?size=$size&page=$page"
    
    try{
         $response = Invoke-RestMethod -Method Get -Uri $apiGroup  -Headers $headers
        if($response.groups -gt 0){
            $allGroups += $response.groups
            $page++
          }else{
              $isMore = $false
         }
         # return $response.groups
        }catch{
         Write-Error "[Line 78] Error on page $page : $_"
         $isMore = $false
         return $null
     }
    }
    return $allGroups
}

$response = @(Get-Group -baseUrl $baseUrl -clientId $CLIENT_ID -clientSecret $CLIENT_SECRET)
Write-Host "[line 90] Number of groups in the environment 1: $($response.Count)"


$CLIENT_ID1 = Get-Secret -Name 'CLIENT_ID1'

$CLIENT_SECRET1 = Get-Secret -Name 'CLIENT_SECRET1'

$baseUrl1 = "https://bpsod.webcon.pl/5775"
$response1 = @(Get-Group -baseUrl $baseUrl1 -clientId $CLIENT_ID1 -clientSecret $CLIENT_SECRET1)
Write-Host "[Line 103] Number of groups other than in environment 2: $($response1.Count)"



Write-Host '[Line 100] Number of groups that are only on environment 1'
$onlyIn1env = @($response | Where-Object { $_.bpsId -notin ($response1.bpsId) }) 
$onlyIn1env | Format-Table bpsId, name, email

Write-Host "[Line 104] Number of groups other than in environment 2: $($onlyIn1env.Count)"

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
    
    foreach($group in $groupToCreate){
        if(-not $group.email){
            $group.email = $group.bpsId
        }
        $body =@{
            bpsId = $group.bpsId
           name = $group.name
           email = $group.email
           } | ConvertTo-Json -Depth 3
         
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
    
         $memberUrl = "$baseUrl/api/data/v6.0/admin/groups/$groupID"
            try{
            $response = Invoke-RestMethod -Method Get -Uri $memberUrl -Headers $headers
       
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
     
     
     Write-Host "[Line 267] Groups from the source: $($groupMemberenv1 | ConvertTo-Json -Depth 5)"

     $groupMemberenv2 = Get-Member-From-Group -baseUrl $baseUrl1 -clientId $CLIENT_ID1 -clientSecret $CLIENT_SECRET1 -checkGroupMember $response1
     
    Write-Host "[Line 271] Target groups: $($groupMemberenv2 | ConvertTo-Json -Depth 5)"

    }else{
        Write-Host "[Line 274] Check member creation was skipped"
    }

function Compare-Group-Members{
   
    param(
        [array]$groupMemberenv1,
        [array]$groupMemberenv2
    )
   
    $result = @()
    $result2 = @()

    foreach($group1 in $groupMemberenv1){
        $groupID = $group1.bpsId
        $group2 = $groupMemberenv2 | Where-Object {$_.bpsId -eq $groupID}

        if(-not $group2){
            Write-Host "[Line 292] Group $groupId not found in second environment"
            continue
        }
      
       $members1 = $group1.members
       
        Write-Host  "[Line 298] Members in ev1 for group $groupID" 
       
        if($members1.count -eq 0){
            Write-Host  "[Line 301] No members"
        }else{
           
           $members1 | foreach-Object {Write-Host " - '$($_.bpsId)'"}
         
        }

        $members2 = $group2.members

          Write-Host  "[Line 312] Members in ev2 for group $groupID" 
        if($members2.count -eq 0){
            Write-Host  "[Line 314] No members"
        }else{
            $members2 | foreach-Object {Write-Host "[Line 316] - '$($_.bpsId)'"}
                
        
        }

      
        $normalizedMembers1 = $members1 | ForEach-Object { $_.bpsId.ToString().Trim().ToLower() }
        $normalizedMembers2 = $members2 | ForEach-Object { $_.bpsId.ToString().Trim().ToLower() }

        $onlyIn1env = $normalizedMembers1 | Where-Object {$_ -notin $normalizedMembers2}
        
        $onlyIn2env = $normalizedMembers2 | Where-Object {$_ -notin $normalizedMembers1}

    
        if($onlyIn1env.count -eq 0 -and $onlyIn2env.count -eq 0){
            Write-Host "[Line 336] Group $groupID has identical members"
        }else{
             Write-Host "`n [Line 338] Differences in $groupID"
        
             if($onlyIn1env.count -gt 0 ){  
                Write-Host "[Line 341] - Only in Env1:"
                forEach($bpsId in $onlyIn1env){
             

                    $member =  $members1 | Where-Object {$_.bpsId.ToString().Trim().ToLower() -eq $bpsId }   # tu cos jest  i do poprawy 
                    if($member){
               
                     $name = if ($member.name) { $member.name } else { "?" }
                    $email = if ($member.email) { $member.email } else { "?" }
                    $type = if ($member.type) { $member.type } else { "?" }
             
 
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
        
            
             }

             if($onlyIn2env.count -gt 0 ){  
                Write-Host "[Line 377] - Only in Env2:"
            forEach($bpsId in $onlyIn2env){
                    $member =  $members2 | Where-Object {$_.bpsId.ToString().Trim().ToLower() -eq $bpsId } 
                    if($member){
                     $name = if ($member.name) { $member.name } else { "?" }
                        $email = if ($member.email) { $member.email } else { "?" }
                        $type = if ($member.type) { $member.type } else { "?" }
          
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
              
               
                }
              
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
     
        $exitsMember = Get-User -baseUrl $baseUrl -clientId $clientId -clientSecret $clientSecret -user $memberId
    
        if(-not $memberList.ContainsKey($groupID)){
            $memberList[$groupID] = @()
        }
        if(-not $exitsMember -and $memberType -eq 'User'){
        
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

  
