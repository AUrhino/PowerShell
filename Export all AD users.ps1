# Show logon details, password set time, memberships and Account status. To allow export to a csv... we need to get PS to handle multi-valued property with the join function.

Get-ADUser -Filter * -Properties name,mail,userAccountControl,samaccountname,PasswordLastSet,"msDS-UserPasswordExpiryTimeComputed",CanonicalName,memberof `
| Select-Object name,mail,userAccountControl,samaccountname,PasswordLastSet,@{Name="ExpiryDate";Expression={[datetime]::FromFileTime($_."msDS-UserPasswordExpiryTimeComputed")}}, `
CanonicalName,@{name="MemberOf";expression={$_.MemberOf -join ";"}} `
| Export-Csv users.csv -NoTypeInformation -Encoding UTF8
