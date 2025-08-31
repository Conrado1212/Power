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
    $value =  $Colors.length -2
    foreach($color in $Colors[0..$value]){
        # Write-Output $colo.IndexOf($color.ToLower())
        if(-not [int]$number.Contains(0)){
            $number += $colo.IndexOf($color.ToLower())
        }   
    }
    $length = $Colors.Length-1
    $multi = $colo.indexOf($Colors[$length])
    $array =""
    if($multi -gt 0){
        for($i =1; $i -le $multi; $i++){
            $array +=0
        }
    }
    $number
    Write-Host "Line 35 $array"
    $total = $number.ToString()+$array
    if([int]$total -ge 1000000){
        $total=$total/1000000
        $text = "megaohms"
    }elseif([int]$total -ge 1000){
        $total=$total/1000
        $text = "kiloohms"
    }else{
        $text = "ohms"
    }
    return  $total.ToString()+" $text"
}
#Get-ResistorLabel -Colors @("orange", "orange", "black")

#Get-ResistorLabel -Colors @("blue", "grey", "brown")

#Get-ResistorLabel -Colors @("red", "black", "red")

#Get-ResistorLabel -Colors @("green", "brown", "orange")

Get-ResistorLabel -Colors @("black", "black", "black")