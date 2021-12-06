<#
.SYNOPSIS
  This script will connect to AD and add a user
  
.DESCRIPTION
  This should run from a host that can connect to GSOA AD
  eg nw-gsoa-rds
  Will prompt user and will connect to AD and set user with groups

  
.INPUTS
  Will prompt for first and last name
  Prompts for AU or IN to set the country path of where the user is created.

  
.OUTPUTS
  Will ensure the input of first and last starts with a capital
  Will write to the screen.


.NOTES
  Author:         Ryan Gillan
  Creation Date:  02-Dec-2021
  1.0 live version
  1.1 Removed hard coded path from hash table and updating based on inputs
  1.2 Cleanup and better error checking

.EXAMPLE
   get-help .\create_ITO_AU_user.ps1
  
  #Run via:
  .\create_ITO_AU_user.ps1

.LINK
    More documentation to follow via:

#>
#=================================================================================================
# Will prompt for first and last name

$firstname = Read-Host -Prompt 'Users first name?'
$lastname = Read-Host -Prompt 'Users last name?'
$firstin = $firstname[0]                              # First initial. Handy but not used. Maybe for people with multiple first names???
Write-Host "Entered: $firstname $lastname"  -ForegroundColor Yellow
# Converts first letter of first/lastname to uppercase
$firstname = $firstname.substring(0,1).toupper()+$firstname.substring(1).tolower()    
$lastname = $lastname.substring(0,1).toupper()+$lastname.substring(1).tolower()
# Build $SamAccountName
$SamAccountName = "$firstname.$lastname"
Write-Host "Caculated SamAccountName: $SamAccountName"  -ForegroundColor Yellow

# Need to specify the group to add to user to.
$GroupName = "Horizon ITO entitlement"


# Check if account already exists. If they do, add to AD group only.
$userobj = $(try {Get-ADUser $SamAccountName} catch {$Null})
If ($userobj -ne $Null) {
    $UserExists = $true
    Write-Host "$SamAccountName already exists. Adding to groups"
    Write-Host "Adding $SamAccountName to: $GroupName"  -ForegroundColor Green
    Add-ADGroupMember -Identity $GroupName $SamAccountName
    Get-ADUser $SamAccountName -Properties * | Select name,givenname,sn,displayName,samaccountname,UserPrincipalName,Mail,userAccountControl,enabled,DistinguishedName,MemberOf,OtherAttributes,c
    exit
} else {
    Write-Host "$SamAccountName was not found. Creating user" -foregroundcolor "Yellow"
}


# This takes all the defaults and adds them to a Hash. https://docs.microsoft.com/en-us/powershell/module/microsoft.powershell.core/about/about_hash_tables?view=powershell-7.2
# These are common to all users. Else use: $hash.Add("Item", "data")
$hash = @{
    Name                  = "$firstname $lastname" 
    AccountPassword       = $password 
    SamAccountName        = "$firstname.$lastname"
    DisplayName           = "$firstname $lastname" 
    EmailAddress          = "$firstname.$lastname@global.ntt" 
    Enabled               = $False
    GivenName             = "$firstname" 
    Surname               = "$lastname" 
    UserPrincipalName     = "$firstname.$lastname" 
    ChangePasswordAtLogon = $False
    company               = "NTT"
    OtherAttributes       = @{'info'="Created using powershell script"} 
}

# Will prompt for country so we can set the path. new-ad
$Co = Read-Host -Prompt 'Enter users country, eg AU, IN or NZ?'
if ($Co -eq 'AU') {
  # Australia'
  $hash.Add("Country", "AU")
  $hash.Add("Path", "OU=GSC Users,OU=Users,OU=GSOA,DC=ad,DC=gsoa,DC=ddau")
  Write-Host "Country entered is: $Co in: $hash.path"
}
elseif ($Co -eq 'NZ') {
  # NZ
  $hash.Add("Country", "NZ")
  $hash.Add("Path", "OU=DBSolutions users,OU=Users,OU=GSOA,DC=ad,DC=gsoa,DC=ddau")
  Write-Host "Country entered is: $Co in: $hash.path"
} else {
  # 'India'
  $hash.Add("Country", "IN")
  $hash.Add("Path", "OU=CDO users,OU=Users,OU=GSOA,DC=ad,DC=gsoa,DC=ddau")
  Write-Host "Country entered is: $Co in: $hash.path"
}




# Need to build samaccount name as first.last
$SamAccountName = $firstname+'.'+$lastname
Write-Host "Using: $firstname $lastname"  -ForegroundColor Green
$hash
Write-Host "----------------------"  -ForegroundColor Yellow

# Need to set a complex temporary default password
$password = convertto-securestring "C0mpl3x#P@55w0rd" -asplaintext -force


# Create user
Write-Host "Adding $SamAccountName"  -ForegroundColor Green
New-ADUser -Confirm @hash
Write-Host "Please wait while we get our ducks in order."  -ForegroundColor Green
Start-Sleep -s 5


# Add user to the AD security group
Write-Host "Adding $SamAccountName to: $GroupName"  -ForegroundColor Green
Add-ADGroupMember -Identity $GroupName $SamAccountName


# Add user to other custom AD security groups based on country or the OU.
if ($Co -eq 'In') {
    Write-Host 'Adding more CDO groups'
    Add-ADGroupMember -Identity "CDO users" $SamAccountName
} 

if ($Co -eq 'NZ') {
    Write-Host 'Adding more CDO groups'
    Add-ADGroupMember -Identity "Horizon SQLS entitlement" $SamAccountName
}


# Print a summary of the user account that was added or modified.
$userobj = $(try {Get-ADUser $SamAccountName} catch {$Null})
If ($userobj -ne $Null) {
    $UserExists = $true
    Write-Host "Found $SamAccountName already exists. Adding to groups"  -ForegroundColor Green
    Get-ADUser $SamAccountName -Properties * | Select name,givenname,sn,displayName,samaccountname,UserPrincipalName,Mail,userAccountControl,enabled,DistinguishedName,MemberOf,OtherAttributes,c
    exit
} else {
    Write-Host "$SamAccountName was not found. It may exist but AD is slow to replicate." -foregroundcolor "Yellow"
}

Write-Host -NoNewLine 'Press any key to continue...'  -ForegroundColor Green

