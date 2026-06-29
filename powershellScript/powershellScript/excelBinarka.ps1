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
         $row = 1
         while($sheet.Cells.Item($row, 1).Text -ne ""){
            try{
                  $bpsId = $sheet.Cells.Item($row,1).Text
                  $filePath = $sheet.Cells.Item($row,2).Text
                if (Test-Path $filePath) {    
                 $bytes = [System.IO.File]::ReadAllBytes($filePath)
                }else{
                    Write-Warning "Plik nie istnieje: $filePath"
                }
                    if(-not ($dane | Where-Object {$_.bpsId -eq $bpsId})){
                    $dane += [PSCustomObject]@{
                             bpsId = $bpsId
                            byte = $bytes
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

    $path = Read-Host "Please provide the path to the Excel file"
if([string]::IsNullOrWhiteSpace($path)){
    Write-Host "the Path variable cannot be empty"
    exit 1
}else{
    Get-DataFromExcel -path $path
}