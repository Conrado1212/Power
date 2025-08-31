Function Get-SumOfMultiples {
    <#
    .SYNOPSIS
    Given a number, find the sum of all the unique multiples of particular numbers up to
    but not including that number.

    .DESCRIPTION
    If we list all the natural numbers below 20 that are multiples of 3 or 5,
    we get 3, 5, 6, 9, 10, 12, 15, and 18.

    .PARAMETER Multiples
    An array of the factors 

    .PARAMETER Limit
    The value BELOW which we test for

    .EXAMPLE
    Get-SumOfMultiples -Multiples @(3, 5) -Limit 10
    
    Returns 23
    #>
    [CmdletBinding()]
    Param(
        [int[]]$Multiples,
        [int]$Limit
    )
    
    $result = @()
   
    foreach($item in $Multiples){
        if($item -ne 0){
           Write-Host "[Line 32] $item"
            for($i = $item; $i -lt $Limit; $i +=$item){
               Write-Host "LIne 34 $i"
                $result +=$i
            }
        } 
    }
    Write-Host "Line 38 $result"
    $unique = $result | Select-Object -Unique
    return ($unique | Measure-Object -Sum).Sum
    #Throw "Please implement this function"
}
#Get-SumOfMultiples -Multiples @(3, 5) -Limit 1

Get-SumOfMultiples -Multiples @(3) -Limit 7