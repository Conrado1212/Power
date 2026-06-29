$siteUrl = "https://webconbps.sharepoint.com/sites/kksite"
$libraryName = "testkk"     # Nazwa biblioteki dokumentów
$ticketId = "test"             # Sygnatura i nazwa zgłoszenia z formularza
$folderName = $ticketId                # Folder będzie nazwany jak zgłoszenie
$folderPath = "/$libraryName"          # Folder główny biblioteki


Connect-PnPOnline -Url $siteUrl -Interactive

#
$fullPath = "$libraryName/$folderName"
$folderExists = Test-PnPFolder -SiteRelativeUrl $fullPath

if ($folderExists) {
    Write-Output "Folder '$folderName' exists in library '$libraryName'."
} else {
 
    New-PnPFolder -Name $folderName -Folder $folderPath
    Write-Output "Folder '$folderName' został utworzony w '$libraryName'."
}


Disconnect-PnPOnline





$siteUrl = "https://webconbps.sharepoint.com/sites/kksite"
$username = ""
$password = ""  

$securePassword = ConvertTo-SecureString $password -AsPlainText -Force
$creds = New-Object System.Management.Automation.PSCredential ($username, $securePassword)

Connect-PnPOnline -Url $siteUrl -Credentials $creds