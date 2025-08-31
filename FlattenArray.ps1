Function Invoke-FlattenArray() {
    <#
    .SYNOPSIS
    Take a nested array and return a single flattened array with all values except null.

    .DESCRIPTION
    Given an array, flatten it and keep all values except null.

    .PARAMETER Array
    The nested array to be flattened.

    .EXAMPLE
    Invoke-FlattenArray -Array @(1, @(2, 3, $null, 4), @($null), 5)
    Return: @(1, 2, 3, 4, 5)
    #>
    [CmdletBinding()]
    Param(
        [System.Object[]]$Array
    )
    
    $result = @()
    foreach($item in $Array){
        if($item -is [System.Collections.IEnumerable] -and -not($item -is [string])){
            $result +=$item
        }elseif($item -ne $null){
            $result +=$item
        }
    }
    return $result
    Throw "Please implement this function"
}

#Invoke-FlattenArray -Array @()

#Invoke-FlattenArray -Array @(1, @(2, 3, 4, 5, 6, 7), 8)

Invoke-FlattenArray -Array @(0, 2, @(@(2, 3), 8, 100, 4, @(@(@(50)))), -2)