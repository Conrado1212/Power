Function Get-ColorCodeValue() {
    <#
    .SYNOPSIS
    Translate a list of colors to their corresponding color code values.

    .DESCRIPTION
    Given 2 colors, take the first one and times it by 10 and add the second color to it.

    .PARAMETER Colors
    The colors to translate to their corresponding color codes.

    .EXAMPLE
    Get-ColorCodeValue -Colors @("black", "brown")
    #>
    [CmdletBinding()]
    Param(
        [string[]]$Colors
    )
    $number =""
    $colo = @("black","brown","red","orange","yellow","green","blue","violet","grey","white")
    foreach($color in $Colors[0..1]){
        # Write-Output $colo.IndexOf($color.ToLower())
         $number += $colo.IndexOf($color.ToLower())
    }
    return $number
    #throw "Please implement this function"
}



Get-ColorCodeValue -Colors @("brown", "black", "green")




