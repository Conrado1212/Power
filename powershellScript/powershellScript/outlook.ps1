$outlook = New-Object -ComObject Outlook.Application


$mail = $outlook.CreateItem(0)  


$mail.To = "Test"
$mail.Subject = "Test"
$mail.Body = "Test"


#$mail.Attachments.Add("C:\Users\k.krawczyk\Desktop\xd\fizyk\prymat\mail\Contract.docx")


$mail.Display()