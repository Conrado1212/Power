function Get-HammingDifference([string]$strand1, [string]$strand2) {
    <#
    .SYNOPSIS
    Calculate the Hamming difference between two DNA strands.
    
    .DESCRIPTION
    By counting the number of differences between two homologous DNA strands
    taken from different genomes with a common ancestor, we get a measure of
    the minimum number of point mutations that could have occurred on the
    evolutionary path between the two strands.

    This is called the 'Hamming distance'.

    It is found by comparing two DNA strands and counting how many of the
    nucleotides are different from their equivalent in the other string.
    
    .PARAMETER strand1
    The first DNA strand
    
    .PARAMETER strand2
    The second DNA strand
    
    .EXAMPLE
    Get-HammingDifference -strand1 "GAGCCTACTAACGGGAT" -strand2 "CATCGTAATGACGGCCT"
    
    This will return a difference of 7.
    #>
    
    #Throw "Please implement this function"

    $result = 0
    
    if($strand1.Length -eq $strand2.Length){
       for($i =0;$i -lt $strand1.Length; $i++){
           if($strand1[$i] -ne $strand2[$i]){
                $result ++
           }
       }
    }else{
        throw "*strands must be of equal length.*"
    }

    return $result
}
#Get-HammingDifference '' ''
#Get-HammingDifference 'A' 'A'
Get-HammingDifference 'G' 'T'
#Get-HammingDifference -strand1 "GAGCCTACTAACGGGAT" -strand2 "CATCGTAATGACGGCCT"