<#
.DESCRIPTION
    This is used delete all files in XXXX folder older than YY day(s)

.NOTES
    Author: Ryan Gillan
    Last updated: 04/11/2021

.EXAMPLE
    .\Remove_old_files.ps1

.INPUTS
    $Path - path to clear
    $Daysback - days to keep. Rest removed

.OUTPUTS
    None unless you uncomment "-WhatIf" 

#>

$Path = "C:\scripts\snapshots\reports"
$Daysback = "-10"

$CurrentDate = Get-Date
$DatetoDelete = $CurrentDate.AddDays($Daysback)
#Get-ChildItem $Path -Recurse | Where-Object { $_.LastWriteTime -lt $DatetoDelete } | Remove-Item -WhatIf  #Use WhatIf to test but not delete.
Get-ChildItem $Path -Recurse | Where-Object { $_.LastWriteTime -lt $DatetoDelete } | Remove-Item
