Function Get-Triangle() {
    <#
    .SYNOPSIS
    Determine if a triangle is equilateral, isosceles, or scalene.

    .DESCRIPTION
    Given 3 sides of a triangle, return the type of that triangle if it is a valid triangle.
    
    .PARAMETER Sides
    The lengths of a triangle's sides.

    .EXAMPLE
    Get-Triangle -Sides @(1,2,3)
    Return: [Triangle]::SCALENE
    #>
    
    [CmdletBinding()]
    Param (
        [double[]]$Sides
    )
    $isTriangle = $Sides[0] + $Sides[1] -ge $Sides[2] -and $Sides[1] + $Sides[2] -ge $Sides[0] -and $Sides[0] + $Sides[2] -ge $Sides[1]
    if($Sides[0] -gt 0 -and $Sides[1] -gt 0 -and $Sides[2] -gt 0){
        if($isTriangle ){
            If($Sides[0] -eq $Sides[1] -and $Sides[0] -eq $Sides[2]){
                return [Triangle]::EQUILATERAL 
            }elseif($Sides[0] -eq $Sides[1] -or $Sides[1] -eq $Sides[2] -or $Sides[0] -eq $Sides[2]){
                return  [Triangle]::ISOSCELES 
            }else{
                return  [Triangle]::SCALENE 
            }
        }else{
            throw "*Side lengths violate triangle inequality.*"
        }
    }else{
        throw "*All side lengths must be positive.*"
    }
   
    
}
Enum Triangle {
    EQUILATERAL       #default internal value 0
    ISOSCELES      #default internal value 1
    SCALENE       #default internal value 2
} 
#Get-Triangle -Sides @(2, 2, 2)

#Get-Triangle -Sides @(0.5, 0.5, 0.5)

#Get-Triangle -Sides @(3, 4, 3)

#Get-Triangle -Sides @(0, 0, 0)

Get-Triangle -Sides @(1, 1, 3)