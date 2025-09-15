Function Get-SquareOfSum() {
    <#
    .SYNOPSIS
    Get the square of sum of a number.

    .DESCRIPTION
    Given a number, return the square of sum of all numbers up to and including that number.

    .PARAMETER Number
    The number to calculate the square of sum.
    
    .EXAMPLE
    Get-SquareOfSum -Number 12
    #>
    [CmdletBinding()]
    Param(
        [Int64]$Number
    )
    
    for ($i = $Number; $i -gt 0; $i--) {
        $result +=$i
    }
   return [Math]::Pow($result,2)
}

Get-SquareOfSum -Number 1

Function Get-SumOfSquares() {
    <#
    .SYNOPSIS
    Get the sum of squares of a number.

    .DESCRIPTION
    Given a number, return the sum of squares of all numbers up to and including that number.

    .PARAMETER Number
    The number to calculate the sum of squares.

    .EXAMPLE
    Get-SumOfSquares -Number 12
    #>
    [CmdletBinding()]
    Param(
        [Int64]$Number
    )

    for ($i = $Number; $i -gt 0; $i--) {
        $result +=[Math]::Pow($i,2)
    }
    return $result
}
Get-SumOfSquares -Number 1
Function Get-DifferenceOfSquares() {
    <#
    .SYNOPSIS
    Get the difference of squares of a number.

    .DESCRIPTION
    Given a number, return the difference of squares of all numbers up to and including that number.

    .PARAMETER Number
    The number to calculate the difference of squares.

    .EXAMPLE
    Get-DifferenceOfSquares -Number 12
    #>
    [CmdletBinding()]
    Param(
        [Int64]$Number
    )
   
    $squareOfSum = Get-SquareOfSum -Number $Number
    $sumOfSquares = Get-SumOfSquares -Number $Number

    return $squareOfSum - $sumOfSquares
}
