Function Invoke-BinarySearch() {
    <#
    .SYNOPSIS
    Perform a binary search on a sorted array.

    .DESCRIPTION
    Take an array of integers and a search value and return the index of the value in the array.

    .PARAMETER Array
    The array to search.

    .PARAMETER Value
    The value to search for.

    .EXAMPLE
    Invoke-BinarySearch -Array @(1, 2, 3, 4, 5) -Value 3
    #>
    [CmdletBinding()]
    Param(
        [Int64[]]$Array,
        [Int64]$Value
    )
    if($Array.IndexOf($Value) -ge 0){
        return $Array.IndexOf($Value)
    }else{
        throw "*error: value not in array*"
    }
    
}

#Invoke-BinarySearch -Array @(6) -Value 6

Invoke-BinarySearch -Array @(1, 3, 4, 6, 8, 9, 11) -Value 7