Function Invoke-PrimeFactors() {
    <#
    .SYNOPSIS
    Calculate the prime factors of a given natural number.

    .DESCRIPTION
    Check if the number is divisible by 2. If it is, divide it by 2 and add 2 to the list of factors.
    If it is not, increment the number by 1 and check if it is divisible by 3. If it is, divide it by 3 and add 3 to the list of factors.

    .PARAMETER Number
    The number to factorize.

    .EXAMPLE
    Invoke-PrimeFactors -Number 12
    #>
    [CmdletBinding()]
    Param(
        [Int64]$Number
    )
    $divide = 2
    $result = @()
    while ($Number -ne 1) {
        if($Number % $divide -eq 0){
            $result +=$divide
            $Number = $Number / $divide
        }else{
            $divide +=1
        }
    }
   
    return $result
}
#Invoke-PrimeFactors -Number 2

Invoke-PrimeFactors -Number 3