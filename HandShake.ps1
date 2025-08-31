Function Invoke-SecretHandshake() {
    <#
    .SYNOPSIS
    Convert a number between 1 and 31 to a sequence of actions in the secret handshake.

    .DESCRIPTION
    The sequence of actions is chosen by looking at the rightmost five digits of the number once it's been converted to binary.
    Start at the right-most digit and move left.

    The actions for each number place are:
    00001 = wink
    00010 = double blink
    00100 = close your eyes
    01000 = jump
    10000 = Reverse the order of the operations in the secret handshake.
    
    .PARAMETER Number
    The value to be converted into a sequence of actions.

    .EXAMPLE
    Invoke-SecretHandshake -Number 2
    Returns: @("double blink")
     #>
    [CmdletBinding()]
    Param(
        [int]$Number
    )
    #result
    $result = @()
  

    $code = @{
        1 = "wink"
        2 = "double blink"
        4 = "close your eyes"
        8 = "jump"
        16 = "Reverse the order of the operations in the secret handshake."
    }

   foreach($key in ($code.Keys | Sort-Object)){
       if($key -ne 16){
            if($Number -band $key){
            $result += $code[$key]
        }
       }
   }
   #reverse
    if($Number -band 16){
        [array]::Reverse($result)
    }
    return $result
}

Invoke-SecretHandshake -Number 1