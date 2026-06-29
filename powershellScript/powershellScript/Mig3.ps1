<#getting source variables from source env#>

#$CLIENT_ID = Get-Secret -Name 'CLIENT_ID'
$CLIENT_ID = "abc736e7-a4eb-4b3b-b565-7d0c92ee882a"

$CLIENT_SECRET = "XkTsZgPxYXnSOO83tSt5Map3PtFamjgZm855IM3QYdg="

#$CLIENT_SECRET = Get-Secret -Name 'CLIENT_SECRET'

$baseUrl = "https://bpsod.webcon.pl/5774"

<#getting source variables from target env#>
#$CLIENT_ID1 = Get-Secret -Name 'CLIENT_ID1'
$CLIENT_ID1 = "2fa8c988-5266-4d91-8d4c-5789456da8cc"
#$CLIENT_SECRET1 = Get-Secret -Name 'CLIENT_SECRET1'
$CLIENT_SECRET1 = "t/5WwKsVS88W4OgaJgHwATiD5hDBUePqgeCuFg+AfYE="
$baseUrl1 = "https://bpsod.webcon.pl/5775"


<#logging events in the function #>

$LogFile = "log.txt"
Clear-Content -Path $logFile -ErrorAction SilentlyContinue
function Write-MessageLog{
    param (
        [string]$Message,
        [ValidateSet("INFO", "WARNING", "ERROR")]
        [string]$Level = "INFO"
    )

    $timestamp = Get-Date -Format "dd-MM-yyyy HH:mm:ss"
    $entry = "$timestamp - $Level - $Message"

    switch ($Level) {
        "INFO"    { Write-Host $entry -ForegroundColor White }
        "WARNING" { Write-Warning $Message }
        "ERROR"   { Write-Error $Message }
    }

    Add-Content -Path $LogFile -Value $entry
}
Write-MessageLog "Starting BPS group migration" -Level "INFO"

    if(-not $baseUrl){
     $baseUrl = Read-Host "[Line 46] Write your baseUrl (example. https://example.com)"
    }
function Get-AccessToken{
        param(
            [string]$baseUrl,
            [string]$clientId,
            [string]$clientSecret
        )
        if ([string]::IsNullOrWhiteSpace($clientId)) {

        $clientId = Read-Host "[Line 56] Write  CLIENT_ID"
        }else{
            Write-MessageLog  "[Line 58] Variable clientId value retrieved" -Level "INFO"
        }

        if ([string]::IsNullOrWhiteSpace($clientSecret)) {
             $clientSecret = Read-Host "[Line 64] Write CLIENT_SECRET"
        }else{
            Write-MessageLog "[Line 64] Variable clientSecret value retrieved" -Level "INFO"
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
            Write-MessageLog "[Line 81] Error authentication: $_" -Level "ERROR"
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
        Write-MessageLog "[Line 95] No token" -Level "ERROR"
        exit 1
        #return
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
         # return $response.groups
        }catch{
         Write-MessageLog "[Line 119] Error on page $page : $_" -Level "ERROR"
         $isMore = $false
         return $null
     }
    }
    return $allGroups
}


$response = @(Get-Group -baseUrl $baseUrl -clientId $CLIENT_ID -clientSecret $CLIENT_SECRET)
Write-MessageLog "[line 128] Number of groups in the environment1: $($response.Count)" -Level "INFO"



$response1 = @(Get-Group -baseUrl $baseUrl1 -clientId $CLIENT_ID1 -clientSecret $CLIENT_SECRET1)
Write-MessageLog "[Line 133] Number of groups in environment2: $($response1.Count)" -Level "INFO"


Write-MessageLog '[Line 137] Groups that are only in environment1' -Level "INFO"
$onlyIn1env = @($response | Where-Object { $_.bpsId -notin ($response1.bpsId) }) 
$onlyIn1env | Format-Table bpsId, name, email

Write-MessageLog "[Line 141] Number of groups other than in environment2: $($onlyIn1env.Count)" -Level "INFO"
$onlyIn2env = $response1 | Where-Object { $_.bpsId -notin ($response.bpsId) }
$onlyIn2env | Format-Table bpsId, name, email
Write-MessageLog "Number of groups other than in environment1 : $($onlyIn2env.Count)" -Level "INFO"
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
        $body =@{
            bpsId = $group.bpsId
           name = $group.name
           email = $group.email
           } | ConvertTo-Json -Depth 3
         
          $testBody = [System.Text.Encoding]::UTF8.GetBytes($body)
          Write-MessageLog "[Line 175] Group Params $body" -Level "INFO"
            try{
            Invoke-RestMethod -Method Post -Uri $createGroupUrl -Body $testBody  -Headers $headers 
            Write-MessageLog "[Line 178] Group created $($group.bpsId)"  -Level "INFO"
        }catch{
            Write-MessageLog "[Line 180] Error : $_" -Level "ERROR"
        return $null
    }
    }  
     
}
if($onlyIn1env.count -gt 0){
    Write-MessageLog "[Line 187] Number of missing groups: $($onlyIn1env.Count)" -Level "INFO"
    $userInput = Read-Host "[Line 188] Do you want to create the missing groups in second envirounment? (Y/N)"
    if($userInput -eq "Y"){
        New-Group -baseUrl $baseUrl1 -clientId $CLIENT_ID1 -clientSecret $CLIENT_SECRET1  -groupToCreate $onlyIn1env
        $maxRetries = 5
        $retryCount = 0
    do{
    $response1 = Get-Group -baseUrl $baseUrl1 -clientId $CLIENT_ID1 -clientSecret $CLIENT_SECRET1
    $missingGroups = $onlyIn1env | Where-Object { $_.bpsId -notin $response1.bpsId}
    if($missingGroups.Count -eq 0){     
        Write-MessageLog "[Line 197] Groups synchronized" -Level "INFO"
        break
    }else{
        Write-MessageLog "[Line 200] Waiting for sync ($retryCount/$maxRetries)  miss group $($missingGroups.Count)" -Level "INFO"
        Start-Sleep -Seconds 5
        $retryCount++
    }
}while($retryCount -lt $maxRetries)


if ($missingGroups.Count -gt 0) {
    Write-MessageLog "[Line 208] Some groups not ready after $($maxRetries * 5) sec." -Level "WARNING"
}
    }else{
        Write-MessageLog "[Line 211] Group creation was skipped" -Level "INFO"
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
                members =$response.members
            }
        }catch{
            Write-MessageLog "[Line 257] Error fetching members for group $groupId : $_" -Level "ERROR"
        return $null
    }
    }  
    return $result
}

$userInputM = Read-Host "[Line 264] Do you want to check members? (Y/N)"
if($userInputM -eq "Y"){
     $groupMemberenv1  = Get-Member-From-Group -baseUrl $baseUrl -clientId $CLIENT_ID -clientSecret $CLIENT_SECRET  -checkGroupMember $response
     
     
     Write-MessageLog "[Line 269] Groups from the source: $($groupMemberenv1 | ConvertTo-Json -Depth 5)" -Level "INFO"

     $groupMemberenv2 = Get-Member-From-Group -baseUrl $baseUrl1 -clientId $CLIENT_ID1 -clientSecret $CLIENT_SECRET1 -checkGroupMember $response1
     
     Write-MessageLog "[Line 273] Target groups: $($groupMemberenv2 | ConvertTo-Json -Depth 5)" -Level "INFO"

    }else{
        Write-MessageLog "[Line 276] Check member creation was skipped" -Level "INFO"
    }

function Get-MissingMembers {
    param (
        [string]$envName,
        [array]$missingIds,
        [array]$sourceMembers,
        [string]$groupID
    )

    $results = @()

    foreach ($bpsId in $missingIds) {
        $member = $sourceMembers | Where-Object { $_.bpsId.ToString().Trim().ToLower() -eq $bpsId }
        if ($member) {
            Write-Host "   - [$($member.bpsId)] ($envName only)" -ForegroundColor Yellow
          
$results += [PSCustomObject]@{
    bpsGroupId   = $groupID
    bpsMemberId  = $member.bpsId
    MemberName   = if ($member.name) { $member.name } else { "?" }
    MemberEmail  = if ($member.email) { $member.email } else { "?" }
    MemberType   = if ($member.type) { $member.type } else { "?" }
    environment  = $envName
}

        } else {
            Write-MessageLog "[WARN] Not found $bpsId in $envName" -Level "INFO"
        }
    }

    return $results
}

function Compare-Group-Members {
    param(
        [array]$groupMemberenv1,
        [array]$groupMemberenv2
    )

    $result = @()
    $result2 = @()

    foreach ($group1 in $groupMemberenv1) {
        $groupID = $group1.bpsId
        $group2 = $groupMemberenv2 | Where-Object { $_.bpsId -eq $groupID }

        if (-not $group2) {
            Write-MessageLog "[Line 294] Group $groupID not found in second environment" -Level "INFO"
            continue
        }

        $members1 = $group1.members
        $members2 = $group2.members

        Write-MessageLog "[Line 300] Members in Env1 for group $groupID" -Level "INFO"
        if ($members1.Count -eq 0) {
            Write-MessageLog "[Line 303] No members" -Level "INFO"
        } else {
            $members1 | ForEach-Object { Write-Host " - '$($_.bpsId)'" -ForegroundColor Cyan }
        }

        Write-MessageLog "[Line 312] Members in Env2 for group $groupID" -Level "INFO"
        if ($members2.Count -eq 0) {
            Write-MessageLog "[Line 314] No members" -Level "INFO"
        } else {
            $members2 | ForEach-Object { Write-Host " - '$($_.bpsId)'" -ForegroundColor Green }
        }

        $normalizedMembers1 = $members1 | ForEach-Object { $_.bpsId.ToString().Trim().ToLower() }
        $normalizedMembers2 = $members2 | ForEach-Object { $_.bpsId.ToString().Trim().ToLower() }

        $onlyIn1env = $normalizedMembers1 | Where-Object { $_ -notin $normalizedMembers2 }
        $onlyIn2env = $normalizedMembers2 | Where-Object { $_ -notin $normalizedMembers1 }

        if ($onlyIn1env.Count -eq 0 -and $onlyIn2env.Count -eq 0) {
            Write-MessageLog "[Line 331] Group $groupID has identical members" -Level "INFO"
        } else {
            Write-Host "`n[DIFF] Differences in group $groupID" -ForegroundColor Magenta

            if ($onlyIn1env.Count -gt 0) {
                Write-Host "[Env1 only members:]" -ForegroundColor Yellow
                $result += Get-MissingMembers -envName "Env1" -missingIds $onlyIn1env -sourceMembers $members1 -groupID $groupID
            }

            if ($onlyIn2env.Count -gt 0) {
                Write-Host "[Env2 only members:]" -ForegroundColor Yellow
                $result2 += Get-MissingMembers -envName "Env2" -missingIds $onlyIn2env -sourceMembers $members2 -groupID $groupID
            }
        }
    }

    Write-Host "`n=== Summary ===" -ForegroundColor Cyan
    Write-Host "Env1 unique members: $($result.Count)" -ForegroundColor Cyan
    Write-Host "Env2 unique members: $($result2.Count)" -ForegroundColor Cyan

    return @{
        env1 = $result
        env2 = $result2
    }
}



$comp = Compare-Group-Members -groupMemberenv1 $groupMemberenv1 -groupMemberenv2 $groupMemberenv2

$env1 = $comp.env1
$env2 = $comp.env2

if($env1){Write-MessageLog "[Line 407]" $env1 -Level "INFO"} 
If($env2) {Write-MessageLog "[Line 408]" $env2 -Level "INFO"}

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
            Write-MessageLog "[Line 436] $user not found in env2" -Level "INFO"
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
    Write-MessageLog "[Line 467] $body" -Level "INFO"
            try{
            Invoke-RestMethod -Method Post -Uri $userCreateUrl -Headers $headers -body $testBody 
            
        }catch{
            Write-MessageLog "[Line 472] Error : $_" -Level "ERROR"
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
        Write-MessageLog  "[Line 501] Member info $memberId " -NoNewline -Level "INFO"
     #   Write-Host $memberType  -ForegroundColor Yellow
     Write-MessageLog $memberType  -Level "INFO"
     
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
            Write-MessageLog "[Line 519] Synchronizing user: $memberId" -Level "INFO"
            Start-Sleep -Seconds 7
            $exitsMember  = Get-User -baseUrl $baseUrl -clientId $clientId -clientSecret $clientSecret -user $memberId
            $retryCount++
            }while(-not $exitsMember -and $retryCount -lt $maxRetries)
             $memberList[$groupID] +=[PSCustomObject]@{
             bpsId =$memberId
            }
            Write-MessageLog "[Line 527] User: $memberId synchronized" -Level "INFO"
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
                Write-MessageLog "[Line 553] Added members $member to group $groupID" -Level "INFO" 
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
if($userInputM -eq 'Y'){
$userInput = Read-Host "[Line 565] Do you want to add missing member to group? (Y/N)"
if($userInput -eq "Y"){
     $groupMemberenv2  = Add-Member-To-BpsGroup -baseUrl $baseUrl1 -clientId $CLIENT_ID1 -clientSecret $CLIENT_SECRET1  -groupMember $env1
    }else{
        Write-MessageLog "[Line 569] Group member creation was skipped" -Level "INFO" 
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
            Write-MessageLog "Group  with id:  $($groupID) -> has been deleted" -LEVEL "INFO"
        }catch{
        Write-MessageLog "[Line 600] Error deleting for group $groupId : $_" -LEVEL "ERROR"
        return $null

        }
    }
  
}
if($onlyIn2env.count -gt 0){
$userInputD = Read-Host "[Line 609] Do you want to remove excess groups from environment2 ? (Y/N)"
if($userInputD -eq "Y"){
Write-MessageLog "Starting group deletion for $($onlyIn2env.Count) unique groups" -Level "INFO"

Remove-GroupBPS -baseUrl $baseUrl1 -clientId $CLIENT_ID1 -clientSecret $CLIENT_SECRET1 -groupToDelete $onlyIn2env
}else{
    Write-MessageLog "[Line 613] Group deletion skipped" -Level "INFO"
}
}


  Write-MessageLog "Migration of bps groups has been completed" -Level "INFO"
