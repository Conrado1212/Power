Function Invoke-Diamond() {
    <#
    .SYNOPSIS
    Given a letter, output a diamond shape.

    .DESCRIPTION
    Take a letter of the alphabet, return a string in a diamond shape starting with 'A', with the supplied letter at the widest point.
    The output should use only capitalized letters, however the input should be case-insensitive.

    .PARAMETER Letter
    The letter used to decide the shape of the diamond.

    .EXAMPLE
    Invoke-Diamond -Letter D
    Return:
    @"
       A   
      B B  
     C   C 
    D     D
     C   C 
      B B  
       A   
    "@ 
    #>
    [CmdletBinding()]
    Param(
        [char]$Letter
    )
    $Letter = [char]::ToUpper($Letter)
    $alpha = "ABCDEFGHIJKLMNOPQRSTUVWXYZ"
    $index  = $alpha.IndexOf($Letter)

    $result = @()
    for ($i = 0; $i -le $index; $i++) {
       $char = $alpha[$i]
       $out =' ' * ($index -$i)
       if($i -eq 0){
           $line = "$out$char$out"
       }else{
           $inner = ' ' * (2 * $i -1)
           $line = "$out$char$inner$char$out"
       }
       $result +=$line
    }

    for ($i = $index-1; $i -ge 0; $i--) {
        $char = $alpha[$i]
        $out =' ' * ($index -$i)
        if($i -eq 0){
            $line = "$out$char$out"
        }else{
            $inne = ' ' * (2 * $i -1)
            $line = "$out$char$inner$char$out"
        }
        $result +=$line
     }

   return $result -join "`r`n"
}
Invoke-Diamond -Letter 'A'