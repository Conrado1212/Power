Function Invoke-RotationalCipher() {
    <#
    .SYNOPSIS
    Rotate a string by a given number of places.

    .DESCRIPTION
    Create an implementation of the rotational cipher, also sometimes called the Caesar cipher.
    
    .PARAMETER Text
    The text to rotate    

    .PARAMETER Shift
    The number of places to shift the text

    .EXAMPLE
    Invoke-RotationalCipher -Text "A" -Shift 1 
    #>
    [CmdletBinding()]
    Param(
        [string]$Text, 
        [int]$Shift
    )
    
    $xd = "abcdefghijklmnopqrstuvwxyz"
    $xd2 = "ABCDEFGHIJKLMNOPQRSTUVWXYZ"
    $result = ""
    $chars = $Text.ToCharArray()
    
    foreach ($item in $chars) {
        if ($xd.Contains($item)) {
            $index = $xd.IndexOf($item)
            $newChar = $xd[($index + $Shift) % 26]
            $result += $newChar
        } elseif($xd2.Contains($item)){
            $index =  $xd2.IndexOf($item)
            $newChar = $xd2[($index + $Shift) % 26]
            $result += $newChar
        }else {
            $result += $item  
        }
    }
    
    return $result
}

Invoke-RotationalCipher -Text "a" -Shift 0