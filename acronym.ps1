Function Get-Acronym() {
    <#
    .SYNOPSIS
    Get the acronym of a phrase.

    .DESCRIPTION
    Given a phrase, return the string acronym of that phrase.
    "As Soon As Possible" => "ASAP"
    
    .PARAMETER Phrase
    The phrase to get the acronym from.
    
    .EXAMPLE
    Get-Acronym -Phrase "As Soon As Possible"
    #>
    [CmdletBinding()]
    Param (
        [string]$Phrase
    )
   

    $test = @()
    $test += ($Phrase.ToUpper()  -split "[\s\-_]" | Where-Object {$_ -ne ""})
    foreach($item in $test){
        $result += $item[0]
    }
    return $result
}
#Get-Acronym -Phrase "Portable Networks Graphic"

#Get-Acronym -Phrase "Ruby on Rails"

#Get-Acronym -Phrase "Complementary Metal-Oxide semiconductor"

Get-Acronym -Phrase "The Road _Not_ Taken"