<#
.SYNOPSIS
  This script will connect to AD and query users in a group.
  
.DESCRIPTION
  This should run from a host that can connect to AD
  
  In a nutshell, this is all we need for a quick return of details.
  Get-ADGroupMember -id "$AD_group" -recursive | sort samaccountname | select -expandproperty samaccountname |get-aduser -properties *|select samaccountname,Mail,Enabled,DistinguishedName

  
.INPUTS
  See Declarations section below
  
.OUTPUTS
  Will write to a file and email results into the body of an email.


.NOTES
  Author:         Ryan Gillan
  Creation Date:  30-June-2023
  1.0 live version 
  
.EXAMPLE
   get-help .\List_of_users_in_groups.ps1
  
  #Run via:
    .\List_of_users_in_groups.ps1

.LINK

#>

# Import the required modules
Import-Module ActiveDirectory

# Set the email parameters
$SMTPServer = "mail.host.name"
$From = "no-reply@mail.host.name"
$To = "to@mail.host.name"
$Subject = "List of users in AD Groups"
$Body = ""

# Set the target OU and retrieve all groups within it
$OU = "OU=Users,OU=HOSTS,DC=ad,DC=gsoa,DC=ddau"
$Groups = Get-ADGroup -Filter * -SearchBase $OU

# Iterate through each group and retrieve its members
foreach ($Group in $Groups) {
    $GroupName = $Group.Name
    $GroupMembers = Get-ADGroupMember -Identity $Group | Where-Object { $_.objectClass -eq "user" }
    #Write-host $GroupMembers
    # Append group name and member names to the email body
    $Body += "Group: $GroupName`n"
    $Body += "Members:`n"
    foreach ($Member in $GroupMembers) {
        #$Body += "- $($Member.Name)`n"         #Was just the name but samaccountname is better to search by.
        $Body += "- $($Member.SamAccountName)`n" 
    }
    $Body += "`n"
}

# Send the email
$SMTPMessage = @{
    To = $To
    From = $From
    Subject = $Subject
    Body = $Body
    SmtpServer = $SMTPServer
}

Send-MailMessage @SMTPMessage
# EOF
