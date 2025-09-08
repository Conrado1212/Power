Function Get-Slices() {
    <#
    .SYNOPSIS
    Given a string of digits, output all the contiguous substrings of length `n` in that string.
    
    .DESCRIPTION
    The function takes a string of digits and returns all the contiguous substrings of length `n` in that string.

    .PARAMETER Series
    The string of digits

    .PARAMETER SliceLength
    The length of the slices to return
    
    .EXAMPLE
    Get-Slices -Series "01234" -SliceLength 2
    
    Returns: @("01", "12", "23", "34")
    #>
    [CmdletBinding()]
    Param(
        [string]$Series,
        [int]$SliceLength
    )

   $result  = @()
   if([string]::IsNullOrWhiteSpace($Series)){
   throw "*Series cannot be empty.*"
   }
  if($SliceLength -gt $Series.Length){
      throw "*Slice length cannot be greater than series length.*"
  }elseif($SliceLength -eq 0){
  throw "*Slice length cannot be zero.*"
}elseif($SliceLength -lt 0){
    throw "*Slice length cannot be negative.*"
}else{
    for($i=0;$i -le $Series.Length - $SliceLength;$i++){
        $slice = $Series.Substring($i,$SliceLength)
        $result += $slice
    }
  }
    



   return $result
}

#Get-Slices -Series "1" -SliceLength 1

#Get-Slices -Series "35" -SliceLength 2

#Get-Slices -Series "12345" -SliceLength 6 

#Get-Slices -Series "12345" -SliceLength 0 

Get-Slices -Series "" -SliceLength 1