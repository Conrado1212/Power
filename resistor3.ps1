Function Get-ResistorLabel() {
    <#
    .SYNOPSIS
    Implement a function to get the label of a resistor from its color-coded bands.

    .DESCRIPTION
    Given an array of 1, 4 or 5 colors from a resistor, decode their resistance values and return a string represent the resistor's label.

    .PARAMETER Colors
    The array represent the colors from left to right.

    .EXAMPLE
    Get-ResistorLabel -Colors @("red", "black", "green", "red")
    Return: "2 megaohms ±2%"

    Get-ResistorLabel -Colors @("blue", "blue", "blue", "blue", "blue")
    Return: "666 megaohms ±0.25%"
     #>
    [CmdletBinding()]
    Param(
        [string[]]$Colors
    )
    $number =""
    $colo = @("black","brown","red","orange","yellow","green","blue","violet","grey","white")
    $toleranceMap = @{
        "grey"   = 0.05
        "violet" = 0.1
        "blue"   = 0.25
        "green"  = 0.5
        "brown"  = 1
        "red"    = 2
        "gold"   = 5
        "silver" = 10
    }
    foreach($color in $Colors[0..1]){
        # Write-Output $colo.IndexOf($color.ToLower())
         $number += $colo.IndexOf($color.ToLower())
    }
    $multi = $colo.indexOf($Colors[2])
   # Write-Host "test multi" $multi
    $tolCol = $Colors[3].ToLower()
    $tol = $toleranceMap[$tolCol]
    $result = [math]::Pow(10, $multi)
   # Write-output $tol 
    return $number +" ohms ±"+ $result * $tol+"%"

    Throw "Please implement this function"
}

#Get-ResistorLabel -Colors @("orange", "orange", "black", "red")

Get-ResistorLabel -Colors @("blue", "grey", "brown", "violet")