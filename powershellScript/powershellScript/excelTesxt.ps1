
function Get-DataFromExcel{
    param(
        [string]$path
    )
    $excel = New-Object -ComObject Excel.Application
    if([System.IO.Path]::GetExtension($path) -ne ".xlsx"){
        Write-Host "The file must have the xlsx extension"
        exit 1
    }
        $workbook = $excel.Workbooks.Open("$path")
        $sheet = $workbook.Sheets.Item(1)
    
        $dane =@()
        $row = 2
        while ($sheet.Cells.Item($row, 1).Text -ne "") {
            try{
                 $bpsId = $sheet.Cells.Item($row,1).Text
                    $name = $sheet.Cells.Item($row,2).Text
                    $email = $sheet.Cells.Item($row,3).Text
                    if(-not ($dane | Where-Object {$_.bpsId -eq $bpsId})){
                    $dane += [PSCustomObject]@{
                             bpsId = $bpsId
                            name = $name
                            email = $email
                    }
                }
            }catch{
                Write-Warning "[Line 71] E in row $row : $_"
            }
            $row++;
        }
        $workbook.Close($false)
        $excel.Quit()
      return  $dane 
    }
function Get-MemberDataFromExcel{
    param(
        [string]$path
    )
    $excel = New-Object -ComObject Excel.Application
     if([System.IO.Path]::GetExtension($path) -ne ".xlsx"){
        Write-Host "The file must have the xlsx extension"
        exit 1
    }
        $workbook = $excel.Workbooks.Open("$path")
        $sheet = $workbook.Sheets.Item(1)
    
        $groups =@{}
        $row = 2
        while ($sheet.Cells.Item($row, 1).Text -ne "") {
            try{
                 $groupId = $sheet.Cells.Item($row,1).Text
                    $member = $null
                if($sheet.Cells.Item($row, 4).Text -ne ""){
                    $groupId = $sheet.Cells.Item($row,1).Text
                $member = [PSCustomObject]@{
                    bpsId = $sheet.Cells.Item($row,4).Text
                    name = $sheet.Cells.Item($row,5).Text
                    email = $sheet.Cells.Item($row,6).Text
                    type = $sheet.Cells.Item($row,7).Text
                }
        
            }
               if (-not $groups.ContainsKey($groupId)) {
                     $groups[$groupId] = @()
                }
                 if ($null -ne $member  -and -not ($groups[$groupId] | Where-Object { $_.bpsId -eq $member.bpsId })) {
                $groups[$groupId] += $member
             }
            }catch{
                Write-Warning "[Line 71] E in row $row : $_"
            }
            $row++;
        }
        $workbook.Close($false)
        $excel.Quit()
        $result = @()
        foreach($groupId in $groups.Keys){
            $result += [PSCustomObject]@{
                bpsId = $groupId
                members = $groups[$groupId]
            }
        } 
       return $result | ConvertTo-Json -Depth 3
    }
$path = Read-Host "Please provide the path to the Excel file"
if([string]::IsNullOrWhiteSpace($path)){
    Write-Host "the Path variable cannot be empty"
    exit 1
}else{
    Get-DataFromExcel -path $path
    Get-MemberDataFromExcel -path $path
}