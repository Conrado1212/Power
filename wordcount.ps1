Function Get-WordCount() {
    <#
    .SYNOPSIS
    Given a phrase, count how many time each word appear.

    .DESCRIPTION
    Count how many time each word appear in a phrase. Number in string also counted as word, and words are case insensitive.

    .PARAMETER Phrase
    The phrase to count words.

    .EXAMPLE
    Get-WordCount -Phrase "Hello, welcome to exercism!"
    Return: @{ hello = 1; welcome = 1; to = 1; exercism = 1}
    #>
    [CmdletBinding()]
    Param(
        [string]$Phrase
    )
    $result = @{}
    $Phrase.ToLower() -split '\n|[ ,.:!&@$%^_]' | 
    ForEach-Object { $_.Trim("'") } |
    Where-Object { $_ -ne '' } |
    Group-Object -NoElement | 
    ForEach-Object { $result[$_.Name] = $_.Count }
    $result 
}
#(Get-WordCount -Phrase "one,two,three").GetEnumerator() | Sort-Object Name


#(Get-WordCount -Phrase "car: carpet as java: javascript!!&@$%^&").GetEnumerator() | Sort-Object Name


(Get-WordCount -Phrase "Joe can't tell between 'large' and large.").GetEnumerator() | Sort-Object Name