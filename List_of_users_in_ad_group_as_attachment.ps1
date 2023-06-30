<#
.SYNOPSIS
  This script will connect to AD and query users in a group. Output tweaked a bit with css.
  
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
  Creation Date:  17-Jan-2023
  1.0 live version
  
.EXAMPLE
   get-help .\List_of_users_in_ad_group_as_attachment.ps1
  
  #Run via:
    .\List_of_users_in_ad_group_as_attachment.ps1

.LINK

#>

#Declarations - edit as needed
$SMTPserver = "mail.host.name"
$from = "no-reply@mail.host.name"
$to = "ton@mail.host.name"  #for testing
$AD_group = "AD_GroupName_here"
$Body_title = "<h2>Users who have access to: ( $AD_group ).</h2>"
$subject = "Users who have access to: ( $AD_group )."
$outfile = "C:\tmp\output.html"

$header = @"
<style>
    h1 {

        font-family: Arial, Helvetica, sans-serif;
        color: #e68a00;
        font-size: 28px;
    }

    h2 {
        font-family: Arial, Helvetica, sans-serif;
        color: #000099;
        font-size: 16px;
    }

   table {
		font-size: 12px;
		border: 0px; 
		font-family: Arial, Helvetica, sans-serif;
	} 
	
    td {
		padding: 4px;
		margin: 0px;
		border: 0;
	}

    th {
        background: #395870;
        background: linear-gradient(#49708f, #293f50);
        color: #fff;
        font-size: 11px;
        text-transform: uppercase;
        padding: 10px 15px;
        vertical-align: middle;
	}

    tbody tr:nth-child(even) {
        background: #f0f0f2;
    }
        #CreationDate {
        font-family: Arial, Helvetica, sans-serif;
        color: #ff3300;
        font-size: 12px;
    }
</style>
"@

#Just show 10 users
#$Users = Get-ADGroupMember -id "$AD_group" -recursive | sort samaccountname| select -expandproperty samaccountname |get-aduser -properties *|select samaccountname,c,Enabled,DistinguishedName | Select-Object -First 10  |ConvertTo-Html -Property samaccountname,Enabled,c,DistinguishedName -Fragment
#Show all users
$Users = Get-ADGroupMember -id "$AD_group" -recursive | sort samaccountname | select -expandproperty samaccountname |get-aduser -properties *|select samaccountname,Mail,c,Enabled,DistinguishedName |ConvertTo-Html -Property samaccountname,Mail,Enabled,c,DistinguishedName -Fragment

#The command below will combine all the information gathered into a single HTML report
$Report = ConvertTo-HTML -Body "$Body_title,$Users" -Title "User report for: $AD_group " -Head $header -PostContent "<p>Report creation date: $(Get-Date)<p>" -PreContent "<p>The following are users with access via an AD group.<br> These should be checked and a ticket raised if any of the staff have left or are NOT a member of the group: $AD_group .<p>"

#The command below will generate the report to an HTML file
$Report | Out-File $outfile

#If you want to view the file
#invoke-item $outfile

Write-host "--- Sending email ---"
$mailer = New-Object Net.Mail.SMTPclient($SMTPserver)
$msg = New-Object Net.Mail.MailMessage($from, $to, $subject, $Report)
$msg.IsBodyHTML = $true
$mailer.send($msg)

#EOF
