Function Invoke-Isogram() {
    <#
    .SYNOPSIS
    Determine if a word or phrase is an isogram.
    
    .DESCRIPTION
    An isogram (also known as a "nonpattern word") is a word or phrase without a repeating letter,
    however spaces and hyphens are allowed to appear multiple times.
    
    .PARAMETER Phrase
    The phrase to check if it is an isogram.
    
    .EXAMPLE
    Invoke-Isogram -Phrase "isogram"
    
    Returns: $true
    #>
    [CmdletBinding()]
    Param(
        [string]$Phrase
    )
    $letter =@{ A = 0; B = 0; C = 0; D = 0;E=0; G = 0; H = 0; I = 0; J = 0; K = 0; L = 0; M = 0; N = 0; P = 0; Q = 0; R = 0; S = 0; T = 0; U = 0; V = 0; W = 0; X = 0; Y = 0; Z = 0 }
    $a = $Phrase.ToLower().ToCharArray()

    foreach($item in $a){
        $key = [string]$item
        if($letter.ContainsKey($key)){
             $letter[$key]++
        }
    }
  $one = ($letter.Values | Where-Object {$_ -gt 1}).Count
    
   
    if($one){
        return $false
   }else{
       return $true
   }

}
#Invoke-Isogram -Phrase ""

#Invoke-Isogram -Phrase "eleven"