#>
# Script that will capture the basic Windows cluster configuration to a text file.


<#
.SYNOPSIS
  Script that will capture the basic Windows cluster configuration to a text file.
  
.DESCRIPTION
  This should run from one of the clustered nodes
   
  In a nutshell will capture the following outputs:
    Get-ClusterGroup
    Get-ClusterResource
    Get-ClusterNode –Name “NODENAME” | Get-ClusterGroup
    Get-ClusterGroup “GROUPNAME” | Get-ClusterResource
    Get-ClusterResource “Cluster Disk 1” | Get-ClusterParameter
  
.INPUTS
  N/A but has the following requirments:
   -RunAsAdministrator
   -Modules FailoverClusters
  
.OUTPUTS
  Will write to a file in the same path as the script executed.


.NOTES
  Author:         Ryan Gillan
  Creation Date:  16-Jun-2023
  1.0 live version 
  
  
.EXAMPLE
   get-help .\Cluster_configuration_report.ps1
  
  #Run via:
    .\Cluster_configuration_report.ps1 --help

#.LINK
#    N/A



#>

#Requires -RunAsAdministrator
#Requires -Modules FailoverClusters


#Import-Module FailoverClusters
Try {
     Import-Module FailoverClusters -ErrorAction Stop
}
Catch {
    Write-Host "Error importing module FailoverClusters"
}



$OutputFileLocation = “.\Clusterdetails-$(get-date -uformat ‘%Y-%m-%d’).log”
# Heading comment
write-output “******Clustered IP-Address*****” | Out-File $OutputFileLocation -Append
write-output “—————————–” | Out-File $OutputFileLocation -Append

$ClusterName=Get-Cluster;
$ClusterName.name | Out-File $OutputFileLocation -Append
$ipV4 = Test-Connection -ComputerName $ClusterName -Count 1 | Select IPV4Address
$ipV4 | Out-File $OutputFileLocation -Append

Write-Output “****** Dump all the properties of $ClusterName *****” | Out-File $OutputFileLocation -Append
# Dump all the properties of $ClusterName
$ClusterName_full=Get-Cluster | Format-List -Property *;
$ClusterName_full | Out-File $OutputFileLocation -Append

#———————————————————————
Write-Output “****** Cluster Node*****” | Out-File $OutputFileLocation -Append
Get-ClusterNode | Out-File $OutputFileLocation -Append

#———————————————————————-
Write-Output ” ClusterNodes IP address ” | Out-File $OutputFileLocation -Append
$ClusterNodes=Get-ClusterNode

ForEach($item in $ClusterNodes)
{
write-output “********************************************* $item **************************************************” | Out-File $OutputFileLocation -Append

$ipV4 = Test-Connection -ComputerName $item.name -Count 1 | Select IPV4Address
$ipV4 | Out-File $OutputFileLocation -Append

}

#———————————————————————-
write-output ” ——–Resources Dependency ———————” | Out-File $OutputFileLocation -Append

$clusterNodes = Get-ClusterGroup | Where {$_.Name -like “S*”};
ForEach($item in $clusterNodes)
{
write-output “********************************************* $item *************************************************” | Out-File $OutputFileLocation -Append

Get-ClusterGroup $item.Name | Get-ClusterResource | Get-ClusterResourceDependency | Out-File $OutputFileLocation -Append -Width 400

}
#———————————————————————–
# Existing resource group list
write-output “******Cluster group******” | Out-File $OutputFileLocation -Append
Get-ClusterGroup | Out-File $OutputFileLocation -Append

#———————————————————————–
#Ip-Address of SQL server
write-output “****** Cluster IP addresses ******” | Out-File $OutputFileLocation -Append
$ClusterResource=Get-ClusterResource -Cluster $ClusterName | Where-Object {$_.Name -like “SQL IP*”} | Sort-Object -Property OwnerGroup
ForEach($item in $ClusterResource)
{
write-output “********************************************* IP-Address of $item *************************************************” | Out-File $OutputFileLocation -Append

Get-ClusterResource $item.name | Get-ClusterParameter | Out-File $OutputFileLocation -Append -width 200

}
#————————————————————————–
#Cluster disk information
write-output “*****List of Cluster disk with Group*****” | Out-File $OutputFileLocation -App
#$clusterNodes = Get-ClusterGroup | Where {$_.Name -like “S*”};
$clusterNodes = Get-ClusterGroup;
ForEach($item in $ClusterNodes)
{
write-output “********************************************* Disk of $item *************************************************” | Out-File $OutputFileLocation -App
Get-ClusterGroup | Get-ClusterResource | Where {$_.ResourceType.Name -eq “Physical Disk” -and $_.OwnerGroup.name -eq $item.name } | Out-File $OutputFileLocation -Append
}


#————————————————————————–
#Cluster log details information
#write-output “*****Cluster log for X time *****” | Out-File $OutputFileLocation -App
#get-clusterlog $ClusterName.name -Health -TimeSpan 60 | Out-File $OutputFileLocation -Append



Write-Verbose "Finished. Review the text file in the current path as this script."

#EOF
