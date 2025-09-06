Function Invoke-ArmstrongNumbers() {
    <#
    .SYNOPSIS
    Determine if a number is an Armstrong number.

    .DESCRIPTION
    An Armstrong number is a number that is the sum of its own digits each raised to the power of the number of digits.

    .PARAMETER Number
    The number to check.

    .EXAMPLE
    Invoke-ArmstrongNumbers -Number 12
    #>
    [CmdletBinding()]
    Param(    
        [Int64]$Number
    )
    $result = 0
    $test = [string]$Number
    foreach($item in $test.ToCharArray()){
      $result += [Math]::Pow([Int64]([string]$item), $test.Length)
    }
    if($Number -eq $result){
        return $true
    }else{
        return $false
    }
   # [Math]::Pow(1, $Number.Length) + [Math]::Pow(0, $Number.Length)
 # return  $Number -eq [Math]::Pow($Number, $Number.Length)
   
}
Invoke-ArmstrongNumbers -Number 0

#Invoke-ArmstrongNumbers -Number 10