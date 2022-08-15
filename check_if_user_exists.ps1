<#
.SYNOPSIS
  This script will connect to AD and check if a user exists or not.
  
.DESCRIPTION
  This should run from a host that can connect to GSOA AD
  eg nw-gsoa-rds
  Will connect to AD and check if a user exists or not.
  
.INPUTS
  List of user "cn" or "displayName"
  These are saved to a file users.txt
  eg. 
   Ryan Gillan
   Kelvin Low
  
.OUTPUTS
  C:\tmp\AD\AD_FOUND_output.txt
  C:\tmp\AD\AD_FOUND_output.txt

.NOTES
  Author:         Ryan Gillan
  Creation Date:  15-AUg-2022
  1.0 live version

.EXAMPLE
   get-help .\check_if_user_exists.ps1
  
  #Run via:
  .\check_if_user_exists.ps1
.LINK
    No other details
#>

#=================================================================================================

$UserList = get-content C:\tmp\AD\users.txt
Foreach ($Item in $UserList) {
	$user = $null
	#sAMAccountName
	#$user =  Get-ADUser -Prop samAccountName,Enabled -filter {sAMAccountName -eq $Item}
	# cn
	$user =  Get-ADUser -Prop samAccountName,Enabled -filter {cn -eq $Item}
	#Mail
	#user =  Get-ADUser -Prop samAccountName,Enabled -filter {Mail -eq $Item}
	if ($user) {
                $user | Select-Object samAccountName
		$user | Select-Object samAccountName | Out-File C:\tmp\AD\AD_FOUND_output.txt -encoding default -append
	}
    else {
		"$item NOT found"
		"$item NOT found" | Out-File C:\tmp\AD\NOTFOUND_output.txt -encoding default -append
    }
}
