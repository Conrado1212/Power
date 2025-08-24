Function Invoke-Keep() {
    <#
    .SYNOPSIS
    Implement the keep operation on collections.
    
    .DESCRIPTION
    Given an array, apply the predicate on each element and return an array of elements where the predicate is true.

    .PARAMETER Data
    Collection of data to filter through.

    .PARAMETER Predicate
    The predicate to operate on the data.
    
    .EXAMPLE
    $IsNegative = { param($num) $num -lt 0 }
    Invoke-Keep -Data @(0, -2, 4, 8, -16) -Predicate $IsNegative
    Return: @(-2, -16)
    #>
    [CmdletBinding()]
    Param(
        [Object[]]$Data,
        [ScriptBlock]$Predicate
    )

    #$isEven = {param($num) $num % 2 -eq 0}

    $result = @()
    foreach($data in $Data){
    #  Write-Host "Test   $data type: $($data.GetType().Name))"
      if($data -is [array]){
          $filtred =@()
          foreach($subData in $data){
            if(& $Predicate  $subData){ 
                $filtred += $subData
            }
          }
          if($filtred.count -gt 0){
            $result += ,$filtred
          }
      }else{
          if(& $Predicate  $data){
              $result += $data
          }
      }
        
    }
    if($result.count -eq 0){
        return $null
    }
    return $result
   # Throw "Please implement this function"
}


#$IsEven = { param($num) $num % 2 -eq 0 }
#Invoke-Keep -Data 4 -Predicate $IsEven

#Invoke-Keep -Data @(
 #   @(1, 2, 3),
 #   @(5, 4, 2),
 #   @(5, 1, 3),
 #   @(2, 8, 7),
 #   @(1, 5, 4),
 #   @(2, 2, 9),
 #   @(1, 1, 4)
#) -Predicate $IsEven
$global:SumOverTen = { param($arr) ($arr | Measure-Object -Sum).Sum -gt 10 }

$data = @(
    @(1, 2, 3),
    @(5, 4, 2),
    @(5, 1, 3),
    @(2, 8, 7),
    @(1, 5, 4),
    @(2, 2, 9),
    @(1, 1, 4)
)

 Invoke-Keep -Data $data -Predicate $global:SumOverTen

Function Invoke-Discard() {
    <#
    .SYNOPSIS
    Implement the discard operation on collections.
    
    .DESCRIPTION
    Given an array, apply the predicate on each element and return an array of elements where the predicate is false.

    .PARAMETER Data
    Collection of data to filter through.

    .PARAMETER Predicate
    The predicate to operate on the data.

    .EXAMPLE
    $IsNegative = { param($num) $num -lt 0 }
    Invoke-Discard -Data @(0, -2, 4, 8, -16) -Predicate $IsNegative
    Return: @(0, 4, 8)
    #>
    [CmdletBinding()]
    Param(
        [Object[]]$Data,
        [ScriptBlock]$Predicate
    )
    $result = @()
    
   <#
   foreach($data in $Data){
        Write-Host "Test   $data type: $($data.GetType().Name))"
        if($data -is [array]){
            foreach($subData in $data){
              if(& $Predicate  $subData){
                  $result += $subData
              }
            }
        }
    }
   #> 
    return $result
   # Throw "Please implement this function"
}

Invoke-Discard -Data @(0, -2, 4, 8, -16) -Predicate $IsNegative