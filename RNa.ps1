Function Invoke-RnaTranscription() {
    <#
    .SYNOPSIS
    Transcribe a DNA strand into RNA.

    .DESCRIPTION
    Given a DNA strand, return its RNA complement (per RNA transcription).

    .PARAMETER Strand
    The DNA strand to transcribe.

    .EXAMPLE
    Invoke-RnaTranscription -Strand "A"
    #>
    [CmdletBinding()]
    Param(
        [string]$Strand
    )
    $result =""
    $test =@{ A = "U"; C = "G"; G = "C"; T = "A" }
    $dd = $Strand.ToCharArray()
    foreach($item in $dd){
        $key = [string]$item
       if($test.ContainsKey($key)){
            $result += $test[$key]  #bezposrednio wartosc ok 
       }
    }
    return $result
}
#Invoke-RnaTranscription -Strand ""

#Invoke-RnaTranscription -Strand "C"

Invoke-RnaTranscription -Strand "ACGTGGTCTTAA"