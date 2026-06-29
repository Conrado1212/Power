#$filePath = "C:\Users\k.krawczyk\Desktop\xd\fizyk\prymat\mail"
$filePath = "C:\Users\k.krawczyk\Desktop"
$fileSize = 5MB
$file = New-Object byte[] $fileSize
[System.IO.File]::WriteAllBytes($filePath, $file)
