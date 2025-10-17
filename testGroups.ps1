function Get-AllGroups {
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

    $allGroups = @()
    $page = 0
    $size = 1000  
    $isMore = $true

    while ($isMore) {
        $url = "$baseUrl/api/data/v6.0/admin/groups?size=$size&page=$page"

        try {
            $response = Invoke-RestMethod -Method Get -Uri $url -Headers $headers
            if ($response.groups.Count -gt 0) {
                $allGroups += $response.groups
                $page++
            } else {
                $isMore = $false
            }
        } catch {
            Write-Error "Error on page $page : $_"
            $isMore = $false
        }
    }

    return $allGroups
}