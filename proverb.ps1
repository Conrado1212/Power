Function Get-Proverb() {
    <#
    .SYNOPSIS
    Given a list of inputs, generate the relevant proverb.

    .DESCRIPTION
    Take a list of inputs and output the full text of a proverbial rhyme base on those inputs.

    .PARAMETER Data
    The list of inputs to generate the proverb.

    .EXAMPLE
    Get-Proverb -Data @("nail", "shoe", "horse", "rider", "message", "battle", "kingdom")

    @"
    For want of a nail the shoe was lost.
    For want of a shoe the horse was lost.
    For want of a horse the rider was lost.
    For want of a rider the message was lost.
    For want of a message the battle was lost.
    For want of a battle the kingdom was lost.
    And all for the want of a nail.
    "@
    #>
    [CmdletBinding()]
    Param(
        [string[]]$Data
    )
  

    $result = @()

    if($Data.Count -eq 0){
        return ""
    }
   for ($i = 0; $i -lt $Data.Count-1; $i++) {
      $result +="For want of a $($Data[$i]) the $($Data[$i+1]) was lost." 
   }
   if($Data.Count -gt 0){
    $result +=" And all for the want of a $($Data[0])."
   }
   return $result -join "`r`n"
}
#Get-Proverb -Data @()

#Get-Proverb -Data @("nail")

Get-Proverb -Data @("nail", "shoe")