
Add-Type -AssemblyName System.Windows.Forms
$dialog = New-Object System.Windows.Forms.OpenFileDialog
$dialog.Filter = "Excel Files (*.xlsx)|*.xlsx"
$dialog.InitialDirectory = "C:\Users\k.krawczyk\Desktop\xd\fizyk\powershellScript"
$null = $dialog.ShowDialog()
$workbook = $excel.Workbooks.Open($dialog.FileName)