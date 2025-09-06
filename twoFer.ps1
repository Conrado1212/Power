Function Get-TwoFer(){
    <#
    .SYNOPSIS
    "Two-fer" is short for two for one. One for you and one for me.
    
    .DESCRIPTION
    If the given name is "Alice", the result should be "One for Alice, one for me."
    If no name is given, the result should be "One for you, one for me."
    
    .PARAMETER Name
    The name to use.
    
    .EXAMPLE
    Get-TwoFer

    Will return: One for you, one for me

    .EXAMPLE
    Get-TwoFer -Name Alice
    
    Will return: One for Alice, one for me
    #>
    [CmdletBinding()]
    Param(
        [string]$Name
    )
    
    if($Name){
        $sentance = "One for $Name, one for me"
    }else{
        $sentance = "One for you, one for me"
    }

    return $sentance

    #Throw "Please implement this function"
}  