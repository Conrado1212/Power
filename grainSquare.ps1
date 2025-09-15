Function Get-GrainSquare() {
    <#
    .SYNOPSIS
    Get the number of grains on a square.

    .DESCRIPTION
    Given a number, return the number of grains on that square.
    
    .PARAMETER Number
    Which square to get the number of grains.
    
    .EXAMPLE
    Get-GrainSquare -Number 2
    #>
    [CmdletBinding()]
    Param(
        [BigInt]$Number
    )
    if($Number -le 0 -or $Number -gt64){
        Throw "*square must be between 1 and 64*"
    }
    
    return [BigInt]::Pow(2,$Number-1)
}
#Get-GrainSquare -Number 1
Get-GrainSquare -Number 2
Function Get-GrainTotal() {
    <#
    .SYNOPSIS
    Get the total number of grains.

    .DESCRIPTION
    Return the total number of grains on the board.

    .EXAMPLE
    Get-GrainTotal
    #>
    
   for ($i = 0; $i -lt 64; $i++) {
      $result += [BigInt]::Pow(2,$i)
   }
   return $result
}

Get-GrainSquare -Number 0 