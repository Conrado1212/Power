Function Invoke-Anagram() {
    <#
    .SYNOPSIS
    Determine if a word is an anagram of other words in a list.

    .DESCRIPTION
    An anagram is a word formed by rearranging the letters of another word, e.g., spar, formed from rasp.
    Given a word and a list of possible anagrams, find the anagrams in the list.

    .PARAMETER Subject
    The word to check

    .PARAMETER Candidates
    The list of possible anagrams

    .EXAMPLE
    Invoke-Anagram -Subject "listen" -Candidates @("enlists" "google" "inlets" "banana")
    #>
    [CmdletBinding()]
    Param(
        [string]$Subject,
        [string[]]$Candidates
    )
    $Subjectsort = ($Subject.ToLower().ToCharArray() | Sort-Object) -join ""
    $isAnagram =@()
    foreach($item in $Candidates){
        if($item.length -eq $Subject.length -and
         $item.ToLower() -ne $Subject.ToLower() -and
            (($item.ToLower().ToCharArray() | Sort-Object) -join "") -eq $Subjectsort){
               
                $isAnagram +=$item
       
        }

    }
    return $isAnagram
}

#Invoke-Anagram -Subject "diaper" -Candidates @("hello", "world", "zombies", "pants")


Invoke-Anagram -Subject "solemn" -Candidates @("lemons", "cherry", "melons")