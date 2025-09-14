Function Invoke-Encode() {
    <#
    .SYNOPSIS
    Encode a string using the Atbash cipher.

    .DESCRIPTION
    The Atbash cipher is a simple substitution cipher that relies on transposing all the letters in the 
    alphabet such that the resulting alphabet is backwards. 
    The first letter is replaced with the last letter, the second with the second-last, and so on.

    .PARAMETER Phrase
    The string to encode.

    .EXAMPLE
    Invoke-Encode -Phrase "yes"
    #>
    [CmdletBinding()]
    Param(
        [string]$Phrase
    )
    $plain ="abcdefghijklmnopqrstuvwxyz"
   $cipher ="zyxwvutsrqponmlkjihgfedcba"
   $result =""
   
   foreach($item in $Phrase.ToLower().ToCharArray()){
    
   if($plain.IndexOf($item) -ge 0 -and  $plain.IndexOf($item) -lt 26){
    $result +=  $cipher[$plain.IndexOf($item)]
   }elseif($item -match('\d')){
    $result += $item
   }
   }

   $forResult =""
  
   for ($i = 0; $i -lt $result.length; $i++) {
       if($i -gt 0 -and $i % 5 -eq 0){
        $forResult += " "
       }
       $forResult += $result[$i]
   }

   return $forResult
   
}

#Invoke-Encode -Phrase "yes"
#Invoke-Encode -Phrase "OMG"

#Invoke-Encode -Phrase "mindblowingly"

Invoke-Encode -Phrase "Testing,1 2 3, testing."

#Invoke-Encode -Phrase "O M G"
Function Invoke-Decode(){
    <#
    .SYNOPSIS
    Decode a string using the Atbash cipher.

    .DESCRIPTION
    The Atbash cipher is a simple substitution cipher that relies on transposing all the letters in the 
    alphabet such that the resulting alphabet is backwards. 
    The first letter is replaced with the last letter, the second with the second-last, and so on.

    .PARAMETER Phrase
    The string to decode.

    .EXAMPLE
    Invoke-Decode -Phrase "yes"
    #>
    [CmdletBinding()]
    Param(
        [string]$Phrase
    )
    $plain ="abcdefghijklmnopqrstuvwxyz"
    $cipher ="zyxwvutsrqponmlkjihgfedcba"

    $result =""
    foreach($item in $Phrase.ToLower().ToCharArray()){
    if($plain.IndexOf($item) -ge 0 -and  $plain.IndexOf($item) -lt 26){
        $result +=  $cipher[$plain.IndexOf($item)]
       }elseif($item -match('\d')){
        $result += $item
       }
       }
    
    #   $forResult =""
      
    #   for ($i = 0; $i -lt $result.length; $i++) {
    #       if($i -gt 0 -and $i % 5 -eq 0){
      #      $forResult += " "
     #      }
     #      $forResult += $result[$i]
    #   }
    
    #   return $forResult
      return $result
}

Invoke-Decode -Phrase "vcvix rhn"