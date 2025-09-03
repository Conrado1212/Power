Function Invoke-Panagram() {
    <#
    .SYNOPSIS
    Determine if a sentence is a pangram.
    
    .DESCRIPTION
    A pangram is a sentence using every letter of the alphabet at least once.
    
    .PARAMETER Sentence
    The sentence to check
    
    .EXAMPLE
    Invoke-Panagram -Sentence "The quick brown fox jumps over the lazy dog"
    
    Returns: $true
    #>
    [CmdletBinding()]
    Param(
        [string]$Sentence
    )
   $letter =@{ A = 0; B = 0; C = 0; D = 0; G = 0; H = 0; I = 0; J = 0; K = 0; L = 0; M = 0; N = 0; P = 0; Q = 0; R = 0; S = 0; T = 0; U = 0; V = 0; W = 0; X = 0; Y = 0; Z = 0}
   $a = $Sentence.ToCharArray()
   foreach($item in $a){
       $key = [string]$item
       if($letter.ContainsKey($key)){
            $letter[$key]++
       }
   }
   $zero = ($letter.Values | Where-Object {$_ -gt 0}).Count -eq $letter.Count
   if($zero){
        return $true
   }else{
       return $false
   }
}
 
Invoke-Panagram -Sentence ""