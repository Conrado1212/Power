Function Invoke-ProteinTranslation() {
    <#
    .SYNOPSIS
    Translate RNA sequences into proteins.

    .DESCRIPTION
    Take an RNA sequence and convert it into condons and then into the name of the proteins in the form of a list.

    .PARAMETER Strand
    The RNA sequence to translate.

    .EXAMPLE
    Invoke-ProteinTranslation -Strand "AUG"
    #>
    [CmdletBinding()]
    Param(
        [string]$Strand
    )
    $codon = @{
    "AUG"  = "Methionine"
    "UUU"  = "Phenylalanine"
    "UUC"  = "Phenylalanine"
    "UUA"  = "Leucine"
    "UUG"  = "Leucine"
    "UCU"  = "Serine"
    "UCC"  = "Serine"
    "UCA"  = "Serine"
    "UCG"  = "Serine"
    "UAU"  = "Tyrosine"
    "UAC"  = "Tyrosine"
    "UGU"  = "Cysteine"
    "UGC"  = "Cysteine"
    "UGG"  = "Tryptophan"
    "UAA"  = $null
    "UAG"  = $null
    "UGA"  = $null
    }
    $result  = @()
    if ([string]::IsNullOrWhiteSpace($Strand) -or $Strand.Length -lt 3) {
        return $null
    }
    $test = @()
   $test += ($strand -split '(.{3})' | Where-Object {$_ -ne ""})

   if(-not $codon.ContainsKey($test[0])){
    throw "*error: Invalid codon*"
   }
   if($codon[$test[0]] -eq $null){
       return $null
   }
   $test
    foreach($item in $test){
       if(-not $codon.ContainsKey($item)){
        throw "*error: Invalid codon*"
       }
       
        if($item -notin("UAA","UAG","UGA")){
            $result +=$codon[$item]  
        }else{
            break
        }
      
    }
    return $result
}

#Invoke-ProteinTranslation -Strand ""

#Invoke-ProteinTranslation -Strand "AUG"

#Invoke-ProteinTranslation -Strand "UAA"

#Invoke-ProteinTranslation -Strand "UUAUUG"

#Invoke-ProteinTranslation -Strand "UAGUGG"

#Invoke-ProteinTranslation -Strand "UGGUAG"


#Invoke-ProteinTranslation -Strand "UGGUAGUGG"

Invoke-ProteinTranslation -Strand "AAA"