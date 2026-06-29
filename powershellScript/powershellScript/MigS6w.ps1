<#getting source variables from source env#>

$CLIENT_ID = Get-Secret -Name 'CLIENT_ID' -AsPLainText


$CLIENT_SECRET = Get-Secret -Name 'CLIENT_SECRET' -AsPLainText

$baseUrl = "https://bpsod.webcon.pl/5774"

<#getting source variables from target env#>
$CLIENT_ID1 = Get-Secret -Name 'CLIENT_ID1' -AsPLainText

$CLIENT_SECRET1 = Get-Secret -Name 'CLIENT_SECRET1' -AsPLainText

$baseUrl1 = "https://bpsod.webcon.pl/5775"


<#logging events in the function #>

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
Write-MessageLog "Starting BPS group migration"

    if(-not $baseUrl){
     $baseUrl = Read-Host "[Line 46] Write your baseUrl (example. https://example.com)"
    } 
    if(-not $baseUrl1){
        $baseUrl1 = Read-Host "[Line 46] Write your baseUrl (example. https://example.com)"
    }
function Get-AccessToken{
        param(
            [string]$baseUrl,
            [string]$clientId,
            [string]$clientSecret
        )
         if ([string]::IsNullOrWhiteSpace($baseUrl)) {
             $baseUrl = Read-Host "[Line 64] Write baseUrl"
        }
        if ([string]::IsNullOrWhiteSpace($clientId)) {

        $clientId = Read-Host "[Line 56] Write  CLIENT_ID"
        }#else{
         #   Write-MessageLog  "[Line 58] Variable clientId value retrieved" -Level "INFO"
      #  }

        if ([string]::IsNullOrWhiteSpace($clientSecret)) {
             $clientSecret = Read-Host "[Line 64] Write CLIENT_SECRET"
        }#else{
          #  Write-MessageLog "[Line 64] Variable clientSecret value retrieved" -Level "INFO"
       # }
       
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
            Write-MessageLog "[Line 81] Error authentication: $_" -Level "ERROR"
            return $null
            #exit 1 
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
        Write-MessageLog "[Line 95] No token" -Level "ERROR"
        exit 1
        
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
        if($response.groups.Length -gt 0){
            $allGroups += $response.groups
            $page++
          }else{
              $isMore = $false
         }
         
        }catch{
         Write-MessageLog "[Line 119] Error on page $page : $_" -Level "ERROR"
         $isMore = $false
         return $null
     }
    }
    return $allGroups
}


$response = @(Get-Group -baseUrl $baseUrl -clientId $CLIENT_ID -clientSecret $CLIENT_SECRET)
Write-MessageLog "[line 128] Number of groups in the environment1: $($response.Count)" 



$response1 = @(Get-Group -baseUrl $baseUrl1 -clientId $CLIENT_ID1 -clientSecret $CLIENT_SECRET1)
Write-MessageLog "[Line 133] Number of groups in environment2: $($response1.Count)" 



$onlyIn1env = @($response | Where-Object { $_.bpsId -notin ($response1.bpsId) }) 
if($($onlyIn1env.Count) -gt 0){
Write-MessageLog '[Line 137] Groups that are only in environment1' 
$onlyIn1env | Format-Table bpsId, name, email

Write-MessageLog "[Line 141] Number of groups other than in environment2: $($onlyIn1env.Count)" 
}else{
    Write-MessageLog "[Line 148] No groups to add to environment2 "  -Color Green
}
$onlyIn2env = $response1 | Where-Object { $_.bpsId -notin ($response.bpsId) }
if($($onlyIn2env.Count) -gt 0){
Write-MessageLog '[Line 153] Groups that are only in environment2' -Color Red
$onlyIn2env | Format-Table bpsId, name, email
Write-MessageLog "Number of groups other than in environment1 : $($onlyIn2env.Count)" 
}else{
    Write-MessageLog "No groups other than on  environment1 : "  -Color Green
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
        Write-MessageLog "[Line 225] No token" -Level "ERROR"
        return
    }

    $headers = @{
    Authorization = "Bearer $token"
    "Content-Type" = "application/json"
    }
  
    $allGroup = Get-Group -baseUrl $baseUrl -clientId $clientId -clientSecret $clientSecret
    if(-not $allGroup){
        Write-MessageLog "[Line 236] No group from $baseUrl" -Level "ERROR"
        return
    }
    $result = @()
     foreach($group in $checkGroupMember){
        $groupID = $group.bpsId
        $isGroup = $allGroup | Where-Object {$_.bpsId -eq $groupID}
        if(-not $isGroup){
            Write-MessageLog "[Line 244] Group $groupID not exist in $baseUrl skip" -Level "WARNING"
            continue
        }
    
         $memberUrl = "$baseUrl/api/data/v6.0/admin/groups/$groupID"
            try{
            $response = Invoke-RestMethod -Method Get -Uri $memberUrl -Headers $headers
            $result +=[PSCustomObject]@{
                bpsId = $groupID
                name = $response.name
                email= $response.email
                members =$response.members
            }
        }catch{
            Write-MessageLog "[Line 257] Error fetching members for group $groupId : $_" -Level "ERROR"
        return $null
    }
    }  
    return $result
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
           # Write-MessageLog "[Line 294] Group $groupId not found in second environment" -Level "INFO"
           continue
        }
       $members1 = $group1.members
    
        $members2 = $group2.members
  
        $normalizedMembers1 = $members1 | ForEach-Object { $_.bpsId.ToString().Trim().ToLower() }
        $normalizedMembers2 = $members2 | ForEach-Object { $_.bpsId.ToString().Trim().ToLower() }

        $onlyIn1env = $normalizedMembers1 | Where-Object {$_ -notin $normalizedMembers2}
        
        $onlyIn2env = $normalizedMembers2 | Where-Object {$_ -notin $normalizedMembers1}
   
        if($onlyIn1env.count -eq 0 -and $onlyIn2env.count -eq 0){
            #Write-MessageLog "[Line 331] Group $groupID has identical members" -Level "INFO"
            continue
        }
       
        
             if($onlyIn1env.count -gt 0 ){  
          
                forEach($bpsId in $onlyIn1env){
             

                    $member =  $members1 | Where-Object {$_.bpsId.ToString().Trim().ToLower() -eq $bpsId }  
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
                  #  }else{
                  #      Write-MessageLog "[Line 358] NO MATCH FOUND for $bpsId in Env1" 
                    }
               
                }
        
            
             }

             if($onlyIn2env.count -gt 0 ){  
            #    Write-MessageLog "[Line 367] - Only in Env2:" 
            forEach($bpsId in $onlyIn2env){
                    $member =  $members2 | Where-Object {$_.bpsId.ToString().Trim().ToLower() -eq $bpsId } 
                    if($member){
                      #   Write-MessageLog "   - [$($member.bpsId)] (env2 only)"  -Color Red
                     $name = if ($member.name) { $member.name } else { "?" }
                        $email = if ($member.email) { $member.email } else { "?" }
                        $type = if ($member.type) { $member.type } else { "?" }
          
                 $result2 += [PSCustomObject]@{
                        bpsGroupId   = $groupID
                        bpsMemberId  = $member.bpsId
                        MemberName =    $name
                        MemberEmail =   $email
                        MemberType =   $type
                        environment  = "Env2"
                 }
                    #}else{
                    #    Write-MessageLog "[Line 385] Not found $bpsId inEv2" 
                    }
              
               
                }
              
             }
        
    }
  
    return @{
        env1 = $result
        env2 = $result2
     }
}



#$comp = Compare-Group-Members -groupMemberenv1 $groupMemberenv1 -groupMemberenv2 $groupMemberenv2

#$env1 = $comp.env1
#$env2 = $comp.env2




function Get-User{
     param(
     [string]$baseUrl,
     [string]$clientId,
     [string]$clientSecret,
     [string]$user
     )
      $token = Get-AccessToken -baseUrl $baseUrl -clientId $clientId -clientSecret $clientSecret

      if (-not $token) {
        Write-MessageLog "[Line 420] No token" -Level "ERROR"
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
            Write-MessageLog "[Line 436] $user not found in env2" 
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
        Write-MessageLog "[Line 453] No token" -Level "ERROR"
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
    Write-MessageLog "[Line 467] $body" 
            try{
            Invoke-RestMethod -Method Post -Uri $userCreateUrl -Headers $headers -body $testBody 
            
        }catch{
            Write-MessageLog "[Line 472] Error : $_" -Level "ERROR"
        return $null
}
}

function New-Group{
     param(
     [string]$baseUrl,
     [string]$clientId,
     [string]$clientSecret,
     [array]$groupToCreate
     )
    $token = Get-AccessToken -baseUrl $baseUrl -clientId $clientId -clientSecret $clientSecret
      if (-not $token) {
        Write-MessageLog "[Line 153] No token" -Level "ERROR"
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
    $members = @()
    if($group.members){
        foreach($member in $group.members){
             $exitsMember = Get-User -baseUrl $baseUrl1 -clientId $CLIENT_ID1 -clientSecret $CLIENT_SECRET1 -user $member.bpsId
             if(-not $exitsMember -and $member.type -eq 'User'){
                  $userInput = Read-Host "[Line 512] Do you want to create this user $($member.bpsId) as bpsUser? (Y/N)"
                 if($userInput -eq "Y"){
                Add-User -baseUrl $baseUrl1 -clientId $CLIENT_ID1 -clientSecret $CLIENT_SECRET1 -userID $member.bpsId -userName $member.name -userEmail $member.email
                 $maxRetries = 5
                 $retryCount = 0
            do{
            Write-MessageLog "[Line 519] Synchronizing user: $($member.bpsId)" 
            Start-Sleep -Seconds 10
            $exitsMember  = Get-User -baseUrl $baseUrl1 -clientId $CLIENT_ID1 -clientSecret $CLIENT_SECRET1 -user $member.bpsId
            $retryCount++
            }while(-not $exitsMember -and $retryCount -lt $maxRetries)
            
                if ($exitsMember) {
                 $members += @{bpsId = $member.bpsId}
                }

                 }
             }elseif($exitsMember -and $exitsMember.name.EndsWith("- Registered App")){
                Write-MessageLog "[line 530] Only account of type User or AdGroup can be a member of BPS group skipping add for member $($member.bpsId)" -Level "WARNING"
             }elseif(-not $exitsMember -and $member.type -eq 'AdGroup'){
                    Write-MessageLog "[line 532] Adgroup not exist in 2 env skipping $($member.bpsId)" -Level "WARNING"   
             }else{
                 $members += @{bpsId = $member.bpsId}
             }
           
        }
    }
        $body =@{
            bpsId = $group.bpsId
           name = $group.name
           email = $group.email
          members = $members
           } | ConvertTo-Json -Depth 3
         
          $testBody = [System.Text.Encoding]::UTF8.GetBytes($body)
          Write-MessageLog "[Line 175] Group Params $body" 
            try{
            Invoke-RestMethod -Method Post -Uri $createGroupUrl -Body $testBody  -Headers $headers 
            Write-MessageLog "[Line 178] Group created $($group.bpsId)"  
        }catch{
            Write-MessageLog "[Line 180] Error : $_" -Level "ERROR"
        return $null
    }
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
        Write-MessageLog "[Line 486] No token" -Level "ERROR"
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
        Write-MessageLog  "[Line 501] Member info $memberId " -NoNewline 
    
   
     
        $exitsMember = Get-User -baseUrl $baseUrl -clientId $clientId -clientSecret $clientSecret -user $memberId
    
        if(-not $memberList.ContainsKey($groupID)){
            $memberList[$groupID] = @()
        }
        if(-not $exitsMember -and $memberType -eq 'User'){
        
            $userInput = Read-Host "[Line 512] Do you want to create this user $memberId as bpsUser? (Y/N)"
            if($userInput -eq "Y"){
            
             Add-User -baseUrl $baseUrl -clientId $clientId -clientSecret $clientSecret -userID $memberId -userName $memberName -userEmail $memberEmail
             $maxRetries = 5
            $retryCount = 0
            do{
            Write-MessageLog "[Line 519] Synchronizing user: $memberId" 
            Start-Sleep -Seconds 7
            $exitsMember  = Get-User -baseUrl $baseUrl -clientId $clientId -clientSecret $clientSecret -user $memberId
            $retryCount++
            }while(-not $exitsMember -and $retryCount -lt $maxRetries)
             $memberList[$groupID] +=[PSCustomObject]@{
             bpsId =$memberId
            }
            Write-MessageLog "[Line 527] User: $memberId synchronized" 
            }
        }elseif($exitsMember -and $exitsMember.name.EndsWith("- Registered App")){
            Write-MessageLog "[line 530] Only account of type User or AdGroup can be a member of BPS group skipping add for member $memberId" -Level "WARNING"
        }elseif(-not $exitsMember -and $memberType -eq 'AdGroup'){
            Write-MessageLog "[line 532] Adgroup not exist in 2 env skipping $memberId" -Level "WARNING"   
                    
        }else{
            $memberList[$groupID] +=[PSCustomObject]@{
             bpsId =$memberId
            }
        }
        
    }
    #Write-MessageLog "[Line 541] MemberList $memberList" -Level "INFO" 
        foreach($groupID in $memberList.Keys){
        $body =@{
            members = $memberList[$groupID]
            } | ConvertTo-Json -Depth 3

            $memberUrl = "$baseUrl/api/data/v6.0/admin/groups/$groupID/members/add"

            try{
           
            Invoke-RestMethod -Method Post -Uri $memberUrl -Headers $headers -Body $body
            foreach($member in $memberList[$groupID]){
                Write-MessageLog "[Line 553] Added members $member to group $groupID" 
            }
            
        }catch{
             foreach($member in $memberList[$groupID]){
                Write-MessageLog "[Line 558] Problem with $member for group $groupId : $_" -Level "ERROR" 
            }

            Write-MessageLog "[Line 560] I continue despite error adding member to group." -Level "WARNING"
       # return $null
    }
    }  
}


if($onlyIn1env.count -gt 0){
    Write-MessageLog "[Line 187] Number of missing groups: $($onlyIn1env.Count)" 
    $userInput = Read-Host "[Line 188] Do you want to create the missing groups in second environment? (Y/N)"
   $AddGroup  = Get-Member-From-Group -baseUrl $baseUrl -clientId $CLIENT_ID -clientSecret $CLIENT_SECRET  -checkGroupMember $onlyIn1env
    if($userInput -eq "Y"){
        New-Group -baseUrl $baseUrl1 -clientId $CLIENT_ID1 -clientSecret $CLIENT_SECRET1  -groupToCreate $AddGroup
        $maxRetries = 5
        $retryCount = 0
    do{
    $response1 = Get-Group -baseUrl $baseUrl1 -clientId $CLIENT_ID1 -clientSecret $CLIENT_SECRET1
    $missingGroups = $onlyIn1env | Where-Object { $_.bpsId -notin $response1.bpsId}
    if($missingGroups.Count -eq 0){     
        Write-MessageLog "[Line 197] Groups synchronized" 
        break
    }else{
        Write-MessageLog "[Line 200] Waiting for sync ($retryCount/$maxRetries)  miss group $($missingGroups.Count)" 
        Start-Sleep -Seconds 5
        $retryCount++
    }
}while($retryCount -lt $maxRetries)


if ($missingGroups.Count -gt 0) {
    Write-MessageLog "[Line 208] Some groups not ready after $($maxRetries * 5) sec." -Level "WARNING"
}
    }else{
        Write-MessageLog "[Line 211] Group creation was skipped" 
    } 
}



#testyyyy
#  $addMember  = Get-Member-From-Group -baseUrl $baseUrl -clientId $CLIENT_ID -clientSecret $CLIENT_SECRET  -checkGroupMember $onlyIn1env

#  $addMember | Format-Table

# foreach($xd in  $addMember){
#    $members = @()
#    if($xd.members){
#        foreach($member in $xd.members){
#          $exitsMember = Get-User -baseUrl $baseUrl1 -clientId $CLIENT_ID1 -clientSecret $CLIENT_SECRET1 -user $member.bpsId
#          if(-not $exitsMember -and $member.type -eq 'User'){
#             Write-Host "[line580]   czy chcesz dodac debila"
#          }
#            $members += @{bpsId = $member.bpsId}
#        }
#    }
    
# $body = @{
#        bpsId = $xd.bpsId
#        members = $members
#    } | ConvertTo-Json -Depth 3

#    Write-Host "JSON dla grupy $($group.bpsId):"
#    Write-Host $body
# }










$userInputM = Read-Host "[Line 264] Do you want to check members? (Y/N)"

if($userInputM -eq "Y"){
     Write-MessageLog "[Line 271] Checking members in groups "  -Color Cyan
     $groupMemberenv1  = Get-Member-From-Group -baseUrl $baseUrl -clientId $CLIENT_ID -clientSecret $CLIENT_SECRET  -checkGroupMember $response

     $groupMemberenv2 = Get-Member-From-Group -baseUrl $baseUrl1 -clientId $CLIENT_ID1 -clientSecret $CLIENT_SECRET1 -checkGroupMember $response1
    $comp = Compare-Group-Members -groupMemberenv1 $groupMemberenv1 -groupMemberenv2 $groupMemberenv2

$env1 = $comp.env1
$env2 = $comp.env2
Write-MessageLog " Summary of Differences"  -Color Cyan
 Write-MessageLog "Env1 unique members to Add: $($env1.Count)"  -Color Green
$env1 | Format-Table


 Write-MessageLog "Env2 unique members to delete: $($env2.Count)"  -Color Red
$env2 | Format-Table
    }else{
        Write-MessageLog "[Line 276] Check member creation was skipped" 
    }


if($userInputM -eq 'Y'){
$userInput = Read-Host "[Line 565] Do you want to add missing member to group? (Y/N)"
if($userInput -eq "Y"){
     $groupMemberenv2  = Add-Member-To-BpsGroup -baseUrl $baseUrl1 -clientId $CLIENT_ID1 -clientSecret $CLIENT_SECRET1  -groupMember $env1
    }else{
        Write-MessageLog "[Line 569] Group member creation was skipped" 
    }
}
$onlyIn2env = $onlyIn2env | Sort-Object bpsId -Unique
Function Remove-GroupBPS{
param(
     [string]$baseUrl,
     [string]$clientId,
     [string]$clientSecret,
     [array]$groupToDelete
     )
     $token = Get-AccessToken -baseUrl $baseUrl -clientId $clientId -clientSecret $clientSecret

      if (-not $token) {
        Write-Error "[Line 585] No token"
        return
    }

    $headers = @{
    Authorization = "Bearer $token"
    "Content-Type" = "application/json; charset=utf-8"
    }
    foreach($group in $groupToDelete){
            $groupID = $group.bpsId
             $deleteUrl = "$baseUrl/api/data/v6.0/admin/group?bpsId=$groupID"

      try{
            Invoke-RestMethod -Method Delete -Uri $deleteUrl -Headers $headers
            Write-MessageLog "Group  with id:  $($groupID) -> has been deleted" 
        }catch{
        Write-MessageLog "[Line 600] Error deleting for group $groupId : $_" -LEVEL "ERROR"
        return $null

        }
    }
  
}
if($onlyIn2env.count -gt 0){
Write-MessageLog "[Line 635] Excess groups from environment2"  -Color Cyan
$onlyIn2env | Format-Table bpsId, name, email
$userInputD = Read-Host "[Line 609] Do you want to remove excess groups from environment2 ? (Y/N)"
if($userInputD -eq "Y"){
    
Write-MessageLog "Starting group deletion for $($onlyIn2env.Count) unique groups" 

Remove-GroupBPS -baseUrl $baseUrl1 -clientId $CLIENT_ID1 -clientSecret $CLIENT_SECRET1 -groupToDelete $onlyIn2env
}else{
    Write-MessageLog "[Line 613] Group deletion skipped" 
}
}

  function Remove-Member{
     param(
     [string]$baseUrl,
     [string]$clientId,
     [string]$clientSecret,
     [array]$groupMember
     )
      $token = Get-AccessToken -baseUrl $baseUrl -clientId $clientId -clientSecret $clientSecret

      if (-not $token) {
        Write-MessageLog "[Line 634] No token" -Level "ERROR"
        return
    }

    $headers = @{
    Authorization = "Bearer $token"
    "Content-Type" = "application/json"
    }
    foreach($group in $groupMember){
        $groupID = $group.bpsGroupId
        $memberId = $group.bpsMemberId

        $removeURL = "$baseUrl/api/data/v6.0/admin/group/members/remove?bpsId=$groupID"

        $body = @{
            members = @(@{
                bpsId = $memberId
            })
        } | ConvertTo-Json -Depth 3
        try{
            Invoke-RestMethod -Method Post -Uri $removeURL -Headers $headers -Body $body
            Write-MessageLog "Removed member $memberId from group $groupID" 
        }catch{
                Write-MessageLog "Failed to remove $memberId from $groupID : $_" -Level "ERROR"
        }
    }

  }
if($userInputM -eq "Y"){
  if($env2.count -gt 0){
    $userInputR = Read-Host "[Line 665] Do you want to remove excess users from bpsGroup in environment2 ? (Y/N)"
    if($userInputR -eq "Y"){
        Write-MessageLog "Starting users deletion for $($env2.Count) unique users" 
        Remove-Member -baseUrl $baseUrl1 -clientId $CLIENT_ID1 -clientSecret $CLIENT_SECRET1 -groupMember $env2
    }else{
         Write-MessageLog "[Line 670] Users deletion skipped" 
    }
  }
}
   Write-MessageLog "Migration of bps groups has been completed" 
