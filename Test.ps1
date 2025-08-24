Function Get-BobResponse {
    [CmdletBinding()]
    Param(
        [string]$HeyBob
    )

    <#
"Sure." This is his response if you ask him a question, such as "How are you?" The convention used for questions is that it ends with a question mark.
-> $isQuestion = $HeyBob.EndsWith("?")


"Whoa, chill out!" This is his answer if you YELL AT HIM. The convention used for yelling is ALL CAPITAL LETTERS.

$isYelling = $letters -eq $letters.ToUpper()


"Calm down, I know what I'm doing!" This is what he says if you yell a question at him.

 $isQuestion = $HeyBob.EndsWith("?")


"Fine. Be that way!" This is how he responds to silence. The convention used for silence is nothing, or various combinations of whitespace characters.
"Whatever." This is what he answers to anything else.
#>


    # Czy wypowiedź jest pytaniem?
    


    # Przytnij białe znaki
    $HeyBob = $HeyBob.Trim()
    $isQuestion = $HeyBob.EndsWith("?")
    $isQuestion
    # tylko litery
   # $letters = ($HeyBob -replace '[^a-zA-Z]', '')
   # $letters
   #czy pustka badz biale znaki 
    $isSilence = [string]::IsNullOrWhiteSpace($HeyBob)
    Write-host  "Czy cisza :$isSilence "
    $letters
    $isYelling = $HeyBob.ToUpper() -ceq $HeyBob
    $isYelling
    #$HeyBob
    $isNonNUmber = $HeyBob -match '[a-zA-Z]'
    # $HeyBob.ToUpper()
    Write-host  "Czy krzyk :   $isYelling"


    # Czy wypowiedź jest ciszą?
    if ($isSilence) {
        return 'Fine. Be that way!'
    }
    elseif ($isQuestion -and $isYelling -and $isNonNUmber) {
        return "Calm down, I know what I'm doing!"
    }
    elseif ($isNonNUmber -and $isYelling) {
        return "Whoa, chill out!"
    }
    elseif ($isQuestion) {
        return "Sure."
    }
    else {
        return "Whatever."
    }
}


#Get-BobResponse -HeyBob "Tom-ay-to, tom-aaaah-to."


#Get-BobResponse -HeyBob "1, 2, 3"

#Get-BobResponse -HeyBob "4?"

Get-BobResponse -HeyBob "Okay if like my  spacebar  quite a bit?   "