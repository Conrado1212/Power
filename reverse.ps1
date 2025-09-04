Function Get-ReverseString {
    <#
    .SYNOPSIS
    Reverse a string

    .DESCRIPTION
    Reverses the string in its entirety. That is it does not reverse each word in a string individually.

    .PARAMETER Forward
    The string to be reversed

    .EXAMPLE
    Get-ReverseString "PowerShell"
    
    This will return llehSrewoP

    .EXAMPLE
    Get-ReverseString "racecar"

    This will return racecar as it is a palindrome
    #>
    [CmdletBinding()]
    Param(
        [Parameter(Position=1, ValueFromPipeline=$true)]
        [string]$Forward
	)
	#$xd = $Forward.ToCharArray()
    $result = ""
    for($i=$Forward.length; $i-ge 0; $i--){
        $result +=$Forward[$i]
    }
    return $result
	#Throw "Please implement this function"
}

Get-ReverseString -Forward "PowerShell"