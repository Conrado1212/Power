
function Get-DataFromExcel{
$excel = New-Object -ComObject Excel.Application
    $workbook = $excel.Workbooks.Open("C:\Users\Konrad\Desktop\MS-SQL\data fundamentals\jsCOmple\qr-code-component-main\power\Zeszyt1.xlsx")
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
            Write-Warning "E in row $i : $_"
        }
    }
    $workbook.Close($false)
    $excel.Quit()
    # foreach ($wiersz in $dane) {
    #     Write-Host "Imię: $($wiersz.Imie), Nazwisko: $($wiersz.Nazwisko)"
    # }
    Write-Host "Line 26" 
  return $dane 
}
    
$dane2 = Get-DataFromExcel


foreach($item in $dane2){
    Write-Host $item.id
}