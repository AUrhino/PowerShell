# PowerCLI script for copying a file to a guest VM

#Define variables
Write-Host "Prompt for Guest credentials" -ForegroundColor Yellow
$Cred = Get-Credential
$VMs = Read-Host -Prompt 'Prompt for guest VM'
$File = Read-Host -Prompt 'Prompt for file to copy'
$SrcPath = Read-Host -Prompt 'Prompt for source'
$DstPath = Read-Host -Prompt 'Prompt for the destination'

Foreach ($VMName in $VMs) {
  $VM = Get-VM $VMName

  #Define file information. Include File Name, Parameters, Source and Destination
  $Fullpath = $SrcPath + $File

  Write-Host Copying $Fullpath to $VMName -ForegroundColor Cyan
  Copy-VMGuestFile -VM $VM -Source $Fullpath -Destination $DstPath -LocalToGuest -GuestCredential $Cred -Force
}
