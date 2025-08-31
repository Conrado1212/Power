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
    $value =  $Colors.length -3
    $multiValue = $Colors.length -2
    $last =$Colors.length-1
    foreach($color in $Colors[0..$value]){
        # Write-Output $colo.IndexOf($color.ToLower())
         $number += $colo.IndexOf($color.ToLower())
    }
    Write-Host $number
    $Colors.Length
    If($Colors.Length -ge 3){
    $multi = $colo.indexOf($Colors[$multiValue])
    $multi
    }
    If($Colors.Length -ge 4){
    $tolCol = $Colors[$last].ToLower()
    $tol = $toleranceMap[$tolCol]
    $val = "%"
    $plusik =" ±"
    }
    #Write-Host "test multi" $multi
    Write-Host "[Line 50] $tol"
    $multi
    $result = [math]::Pow(10, $multi)
    Write-Host "[Line 52] $result"
    #Write-output $tol 
    $calc = [int]$number * $result
    Write-Host "[Line 61] $calc" 
    if($calc -lt 1000){
        $text = "ohms"
    }elseif($calc -ge 1000000){
        $text = "megaohms"
        $calc = $calc/1000000
    }elseif($calc -ge 1000){
        $text = "kiloohms"
        $calc = $calc/1000
    }
    
    return $calc.ToString() + " $text"+$plusik+ $tol +$val

    Throw "Please implement this function"
}

#Get-ResistorLabel -Colors @("orange", "orange", "black", "red")

#Get-ResistorLabel -Colors @("blue", "grey", "brown", "violet")

#Get-ResistorLabel -Colors @("red", "black", "red", "green")

#Get-ResistorLabel -Colors @("black")

#Get-ResistorLabel -Colors @("orange", "orange", "yellow", "black", "brown")

#zmienic uzwgldniajac tablice 

Get-ResistorLabel -Colors @("red", "green", "yellow", "yellow", "brown")