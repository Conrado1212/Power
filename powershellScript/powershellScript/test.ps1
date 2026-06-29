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