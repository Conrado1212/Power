Function Add-Gigasecond() {
    <#
    .SYNOPSIS
    Add a gigasecond to a date.

    .DESCRIPTION
    Take a moment and add a gigasecond to it.

    .PARAMETER Time
    A datetime object, to which a gigasecond will be added.

    .EXAMPLE
    Add-Gigasecond -Time
    #>
    [CmdletBinding()]
    Param(
        [DateTime]$Time
    )
   
    $czas = New-TimeSpan -Seconds 1000000000
    return $Time + $czas 
   # return   $newDate.ToString("yyyy-MM-dd HH:mm:ss.fff")
}
