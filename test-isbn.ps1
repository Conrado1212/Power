Function Test-Isbn() {
    <#
    .SYNOPSIS
    Determine if an ISBN is valid or not.
    
    .DESCRIPTION
    Given a string the function should check if the provided string is a valid ISBN-10.
    
    .PARAMETER Isbn
    The ISBN to check
    
    .EXAMPLE
    Test-Isbn -Isbn "3-598-21508-8"
    
    Returns: $true
    #>
    [CmdletBinding()]
    Param(
        [string]$Isbn
    )
   
    
    $clean = $Isbn -replace '[-\s]', ''

    if ($clean.Length -ne 10) {
        return $false
    }

    $sum = 0
    for ($i = 0; $i -lt 10; $i++) {
        $char = $clean[$i]

        if ($i -eq 9 -and $char -eq 'X') {
            $value = 10
        } elseif ($char -match '^\d$') {
            $value = [int]$char
        } else {
            return $false
        }

        $sum += $value * (10 - $i)
    }
  return ($sum % 11 -eq 0)
}
#Test-Isbn -Isbn "3-598-21508-8"

#Test-Isbn -Isbn "3-598-21508-9"

Test-Isbn -Isbn "3-598-21507-X"