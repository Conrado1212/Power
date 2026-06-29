$hex = "";
$bytes = for($i=0; $i -lt $hex.Length ;  $i+=2){
    [Convert]::ToByte($hex.Substring($i, 2), 16)
}
[System.Text.Encoding]::UTF8.GetString($bytes) | Out-File "test.xsl"