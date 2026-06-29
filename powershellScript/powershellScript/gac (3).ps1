$assemblyName = "WebCon.WorkFlow.Data"
$gacPaths = @(
    "$env:windir\Microsoft.NET\assembly\GAC_MSIL",
    "$env:windir\Microsoft.NET\assembly\GAC_32",
    "$env:windir\Microsoft.NET\assembly\GAC_64"
)
 
$found = $false
 
foreach ($path in $gacPaths) {
    if (Test-Path $path) {
        $matches = Get-ChildItem -Recurse $path -Directory | Where-Object { $_.Name -like "*$assemblyName*" }
        if ($matches) {
            $found = $true
            $matches | Select-Object FullName
        }
    }
}
 
if (-not $found) { "Assembly $assemblyName nie znaleziono w GAC." }