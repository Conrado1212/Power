function add-dataToExcel{
    $excel = New-Object -ComObject Excel.Application
    $excel.visible = $false

    do{
        $name = Read-Host "Podaj sciezke pliku "
        if($name.EndsWith("xlsx")){
            $valid = $true
        }else{
            Write-Host "invalid path"
            $valid = $false
        }
    }while(-not $valid)
        
        if(Test-Path $name){
            Remove-Item $name
            
        }
         $workbook = $excel.Workbooks.Add()
         $test = $workbook.Worksheets.Item(1);
         $test.Name = "KKTest";

        $test.Cells.Item(1,1) ="Date"
        $test.Cells.Item(1,2) = "Hour"
        $test.Cells.Item(1,3) = "Name"

       
    
        for ($i = 2; $i -lt 4; $i++) {
            try{
                     $test.Cells.Item($i,1) = "test"
                     $test.Cells.Item($i,2) = "test2"
                 
            }catch{
                Write-Warning "[Line 71] E in row $i : $_"
            }
        }
        $workbook.SaveAs("$name")
        $excel.Quit()
  [System.Runtime.Interopservices.Marshal]::ReleaseComObject($excel) | Out-Null
    Write-Host "File save $name"
    }

    add-dataToExcel