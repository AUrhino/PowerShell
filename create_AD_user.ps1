<#
.SYNOPSIS
  This script will connect to AD and add a user
  
.DESCRIPTION
  This should run from a host that can connect to AD
  
.INPUTS
  Will prompt for first and last name

  
.OUTPUTS
  Will ensure the input of first and last starts with a capital
  Will write to the screen.


.NOTES
  Author:         Ryan Gillan
  Creation Date:  02-Dec-2021
  1.0 live version

.EXAMPLE
   get-help .\create_AD_user.ps1
  
  #Run via:
  .\create_AD_user.ps1

.LINK
    More documentation to follow via:

#>
#=================================================================================================
# Will prompt for first and last name

$firstname = Read-Host -Prompt 'Users first name?'
$lastname = Read-Host -Prompt 'Users last name?'
$firstin = $firstname[0]                              # First initial. Handy for people with multiple first names
Write-Host "Entered: $firstname $lastname"  -ForegroundColor Yellow

# Converts first letter of first/lastname to uppercase
$firstname = $firstname.substring(0,1).toupper()+$firstname.substring(1).tolower()    
$lastname = $lastname.substring(0,1).toupper()+$lastname.substring(1).tolower()

# Need to build samaccount name as first.last
$SamAccountName = $firstname+'.'+$lastname
Write-Host "Using: $firstname $lastname"  -ForegroundColor Green
Write-Host "SamAccountName: $SamAccountName"  -ForegroundColor Green

# Need to set a complex temporary default password
$password = convertto-securestring "C0mpl3x#P@55w0rd" -asplaintext -force

# Need to specify the group to add to user to.
$GroupName = "My User group"

$splat = @{
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
    Country               = "AU"
    company               = "NTT"
    Path                  = "OU=Users,OU=GSOA,DC=ad,DC=xyz" 
    OtherAttributes       = @{'info'="Created using powershell script"} 
}

# Add user to the AD security group
Write-Host "Adding $SamAccountName to: $GroupName"  -ForegroundColor Green
New-ADUser -Confirm @splat
Write-Host "Adding $SamAccountName to: $GroupName"  -ForegroundColor Green
Add-ADGroupMember -Identity $GroupName $SamAccountName

# Print a summary of what was completed.
Write-Host "Printing the AD setup for: $SamAccountName" -ForegroundColor Yellow
Get-ADUser $SamAccountName -Properties * | Select name,givenname,sn,displayName,samaccountname,UserPrincipalName,Mail,userAccountControl,enabled,DistinguishedName,MemberOf,OtherAttributes

Start-Sleep -s 10
Write-Host -NoNewLine 'Press any key to continue...'  -ForegroundColor Green

