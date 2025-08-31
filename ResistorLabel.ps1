Function Get-ResistorLabel() {
    <#
    .SYNOPSIS
    Implement a function to get the label of a resistor with three color-coded bands.

    .DESCRIPTION
    Given an array of colors from a resistor, decode their resistance values and return a string represent the resistor's label.

    .PARAMETER Colors
    The array repesent the 3 colors from left to right.

    .EXAMPLE
    Get-ResistorLabel -Colors @("red", "white", "blue")
    Return: "29 megaohms"
     #>
    [CmdletBinding()]
    Param(
        [string[]]$Colors
    )
    $number =""
    $colo = @("black","brown","red","orange","yellow","green","blue","violet","grey","white")
    #$value =  $Colors.length -2

    foreach($color in $Colors[0..1]){
        # Write-Output $colo.IndexOf($color.ToLower())
            $number += $colo.IndexOf($color.ToLower())
    }
    $number
    $multi = $colo.indexOf($Colors[2])
    $array =""
    if($multi -gt 0){
        for($i =1; $i -le $multi; $i++){
            $array +="0"
        }
    }
    
    #Write-Host "Line 35 $array"

    $total = "$number$array"
    $totalInt = [long]$total
    if($totalInt -ge 1000000000){
        $total=$totalInt/1000000000
        $text = "gigaohms"
    }elseif($totalInt -ge 1000000){
        $total=$totalInt/1000000
        $text = "megaohms"
    }elseif($totalInt -ge 1000){
        $total=$totalInt/1000
        $text = "kiloohms"
    }else{
        $total=$totalInt
        $text = "ohms"
    }
    return  "$total $text"
}
#Get-ResistorLabel -Colors @("orange", "orange", "black")

#Get-ResistorLabel -Colors @("blue", "grey", "brown")

#Get-ResistorLabel -Colors @("red", "black", "red")

#Get-ResistorLabel -Colors @("green", "brown", "orange")

#Get-ResistorLabel -Colors @("black", "black", "black")

#Get-ResistorLabel -Colors @("white", "white", "white")

Get-ResistorLabel -Colors @("blue", "green", "yellow", "orange")