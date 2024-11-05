# Check if the Az module is installed
if (-not (Get-Module -ListAvailable -Name Az)) {
    Write-Output "Az module not found. Installing Az module..."
    Install-Module -Name Az -AllowClobber -Force
} else {
    Write-Output "Az module is already installed."
	# Import the Az module
	Import-Module Az
}

# Connect to your Azure account
Connect-AzAccount

# Get all available contexts (subscriptions)
$contexts = Get-AzContext -ListAvailable

# Check if more than one subscription is detected
if ($contexts.Count -gt 1) {
    Write-Output "Multiple subscriptions detected. Please select a subscription:"
    for ($i = 0; $i -lt $contexts.Count; $i++) {
        Write-Output "$($i + 1). $($contexts[$i].Subscription.Name) ($($contexts[$i].Subscription.Id))"
    }

    # Prompt user to select a subscription
    $selection = Read-Host "Enter the number of the subscription you want to use"
    $selectedContext = $contexts[$selection - 1]

    # Set the selected context
    Set-AzContext -SubscriptionId $selectedContext.Subscription.Id
}

# Get details of all VMs in the selected subscription
$vms = Get-AzVM

# Create an array to hold the VM details
$vmDetails = @()


# Get-AzVM -ResourceGroupName "ResourceGroup11" -Name "VirtualMachine07" -Status
#     ResourceGroupName        : ResourceGroup11
#     Id                       : /subscriptions/00000000-0000-0000-0000-000000000000/resourceGroups/ResourceGroup11/providers/M
#     VmId                     : 00000000-0000-0000-0000-000000000000
#     Name                     : VirtualMachine07
#     Type                     : Microsoft.Compute/virtualMachines
#     Location                 : eastus
#     Tags                     : {"creationSource":"acs-VirtualMachine07"}
#     AvailabilitySetReference : {Id}
#     DiagnosticsProfile       : {BootDiagnostics}
#     Extensions               : {linuxdiagnostic, waitforleader}
#     HardwareProfile          : {VmSize}
#     NetworkProfile           : {NetworkInterfaces}
#     OSProfile                : {ComputerName, AdminUsername, LinuxConfiguration, Secrets}
#     ProvisioningState        : Succeeded
#     StorageProfile           : {ImageReference, OsDisk, DataDisks}


# Loop through each VM and capture all details
foreach ($vm in $vms) {
	
    $vmDetail = [PSCustomObject]@{
        VMName                       = $vm.Name
        VmId                         = $vm.VmId
        Id                           = $vm.Id
		Type                         = $vm.Type
		AvailabilitySetReference     = $vm.AvailabilitySetReference
		DiagnosticsProfile           = $vm.DiagnosticsProfile
		Extensions                   = $vm.OSProfile
        ResourceGroup                = $vm.ResourceGroupName
        Location                     = $vm.Location
        HardwareProfile              = $vm.HardwareProfile.VmSize
        OS                           = $vm.StorageProfile.OsDisk.OsType
        OSVersion                    = $vm.StorageProfile.ImageReference.Version
        DataDisks                    = $vm.StorageProfile.DataDisks.Count
        NetworkProfile               = ($vm.NetworkProfile.NetworkInterfaces | ForEach-Object { $_.Id }) -join ", "
		OSProfile_ComputerName       = $vm.OSProfile.ComputerName
		OSProfile_AdminUsername      = $vm.OSProfile.AdminUsername
		OSProfile_LinuxConfiguration = $vm.OSProfile.LinuxConfiguration
		OSProfile_Secrets            = $vm.OSProfile.Secrets
        ProvisioningState            = $vm.ProvisioningState
        PowerState                   = (Get-AzVM -ResourceGroupName $vm.ResourceGroupName -Name $vm.Name -Status).Statuses[1].DisplayStatus
        Tags                         = ($vm.tags| ForEach-Object { $_.Id }) -join ", "
    }

    # Add the custom object to the array
    $vmDetails += $vmDetail
}

# Export the VM details to a CSV file
$vmDetails | Export-Csv -Path "AzureVMDetails.csv" -NoTypeInformation

Write-Output "VM details have been exported to AzureVMDetails.csv"
