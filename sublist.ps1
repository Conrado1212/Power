
enum Sublist {
    EQUAL
    UNEQUAL
    SUBLIST
    SUPERLIST
}
Function Invoke-Sublist() {
    <#
    .SYNOPSIS
    Determine the relationship of two arrays.

    .DESCRIPTION
    Given two arrays, determine the relationship of the first array relating to the second array.
    There are four possible categories: EQUAL, UNEQUAL, SUBLIST and SUPERLIST.
    Note: This exercise use Enum values for return.
    
    .PARAMETER Data1
    The first array

    .PARAMETER Data2
    The second array

    .EXAMPLE
    Invoke-Sublist -Data1 @(1,2,3) -Data2 @(1,2,3)
    Return: [Sublist]::EQUAL

    Invoke-Sublist -Data1 @(1,2) -Data2 @(1,2,3)
    Return: [Sublist]::SUBLIST
    #>
    [CmdletBinding()]
    Param (
        [object[]]$Data1,
        [object[]]$Data2
    )
    

    function IsSublist($small, $large) {
        if ($small.Count -eq 0) { return $true }
        for ($i = 0; $i -le $large.Count - $small.Count; $i++) {
            if ($large[$i..($i + $small.Count - 1)] -eq $small) {
                return $true
            }
        }
        return $false
    }

    if ($Data1 -eq $Data2) {
        return [Sublist]::EQUAL
    } elseif (IsSublist $Data1 $Data2) {
        return [Sublist]::SUBLIST
    } elseif (IsSublist $Data2 $Data1) {
        return [Sublist]::SUPERLIST
    } else {
        return [Sublist]::UNEQUAL
    }
}
Invoke-Sublist -Data1 @() -Data2 @()

