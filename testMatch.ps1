Function Test-MatchingBrackets() {
    <#
    .SYNOPSIS
    Determine if all brackets inside a string paired and nested correctly.
    
    .DESCRIPTION
    Given a string containing brackets `[]`, braces `{}`, parentheses `()`, or any combination thereof, verify that any and all pairs are matched and nested correctly.
    The string may also contain other characters, which for the purposes of this exercise should be ignored.
    
    .PARAMETER Text
    The string to be verified.
    
    .EXAMPLE
    Test-MatchingBrackets("[]") => True
    Test-MatchingBrackets("[)]") => False
    #>
    [CmdletBinding()]
    Param(
        [string]$Text
    )
    $test = @{
        "[" =0;
        "]" =0;
        "{" =0;
        "}" =0;
        "(" =0;
        ")" =0
    }
  
   foreach($item in $text.ToCharArray()){
      
       if($test.ContainsKey($item)){
       
           $test[$item] +=1
       }
   }
   $test
   if($test[0] -eq $test[1] -and $test[2] -eq $test[3] -and $test[4] -eq $test[5]){
       return $true
   }else{
       return $false
   }
 
}    
#Test-MatchingBrackets("[]")

Test-MatchingBrackets("([{])")