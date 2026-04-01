<#
.SYNOPSIS
    Will get a list of devices and for each, check for CPU/MEM/FS etc

.DESCRIPTION
    Will get a list of devices and for each, check for CPU/MEM/FS etc. The results are exported to a CSV file.

.EXAMPLE
    ./Capture_Resources_and_Components.ps1

.NOTES
    Created by Ryan Gillan
    Version 1.2
	Works with PS DataSources_List (Locator: EWZY2K) to write: auto.activedatasources

.LINK
   https://github.com/AUrhino/PowerShell/blob/main/LogicMonitor/Audit/Capture_Resources_and_Components.ps1
#>
# filter to the devices you want:

# Devices by grooup
#$devices = Get-LMDeviceGroupDevices -Id "1570"

# devices with filtering on a property
#$devices = Get-LMDevice -Filter 'customProperties -eq "{\"name\":\"monitoring.level\",\"value\":\"Full monitoring\"}"'

# All devices
$devices = Get-LMDevice

Write-Host "Devices found: $($devices.Count)"
$deviceDetails = @()
$total = $devices.Count
$counter = 0
foreach ($device in $devices) {
    $counter++
    Write-Host "Processing device $($counter) of $($total): $($device.displayName)"

    try {
        $fullDevice       = Get-LMDevice -DisplayName $device.displayName
        $autoProperties   = $fullDevice.autoProperties
        $systemProperties = $fullDevice.systemProperties
        $customProperties = $fullDevice.customProperties

        $activedatasources = $autoProperties   | Where-Object { $_.Name -eq 'auto.activedatasources' }
        $ResourceType      = $autoProperties   | Where-Object { $_.Name -eq 'predef.externalResourceType' }
        $snmpoperational   = $autoProperties   | Where-Object { $_.Name -eq 'auto.snmp.responding' }
        $wmioperational    = $autoProperties   | Where-Object { $_.Name -eq 'auto.wmi.responding' }
        $wmiUser           = $customProperties | Where-Object { $_.Name -eq 'wmi.user' }
        $snmpUser          = $customProperties | Where-Object { $_.Name -eq 'snmp.security' }
        $systemsysinfo     = $systemProperties | Where-Object { $_.Name -eq 'system.sysinfo' }
        $systemmodel       = $systemProperties | Where-Object { $_.Name -eq 'system.model' }
        $systemsysoid      = $systemProperties | Where-Object { $_.Name -eq 'system.sysoid' }

        $datasources = $activedatasources.value -join ','

        # Extract specific datasource categories
        $interfaceDatasources = ($datasources -split ',') | Where-Object { $_ -match 'Interface|WinIf|Network' }
        $interfaceDatasourcesString = $interfaceDatasources -join ', '

        $cpuDatasources = ($datasources -split ',') | Where-Object { $_ -match 'CPU|Processor|Proc' }
        $cpuDatasourcesString = $cpuDatasources -join ', '

        $fileDatasources = ($datasources -split ',') | Where-Object { $_ -match 'File|Store' }
        $fileDatasourcesString = $fileDatasources -join ', '

        $memoryDatasources = ($datasources -split ',') | Where-Object { $_ -match 'Memory|Mem' }
        $memoryDatasourcesString = $memoryDatasources -join ', '

        # Boolean flags for key datasource types
        $memoryStatus     = if ($memoryDatasources)                    { 'True' } else { 'False' }
        $cpuStatus        = if ($cpuDatasources)                       { 'True' } else { 'False' }
        $diskStatus       = if ($datasources -match 'Disk|drive')      { 'True' } else { 'False' }
        $filesystemStatus = if ($fileDatasources)                      { 'True' } else { 'False' }
        $InterfaceStatus  = if ($interfaceDatasources)                 { 'True' } else { 'False' }
        $WMIStatus        = if ($datasources -match 'WMI|WinOS')       { 'True' } else { 'False' }
        $SNMPStatus       = if ($datasources -match 'SNMP_Status') { 'True' } else { 'False' }
        $httpsStatus      = if ($datasources -match 'HTTPS|Services')  { 'True' } else { 'False' }

        $deviceDetails += [PSCustomObject]@{
            id                            = $device.id
            name                          = $device.name
            displayName                   = $device.displayName
            'snmp.operational'            = $snmpoperational.value
            'wmi.operational'             = $wmioperational.value
            'wmiUser'                     = $wmiUser.value
            'SNMPUser'                    = $snmpUser.value
            'system.sysinfo'              = $systemsysinfo.value
            'predef.externalResourceType' = $ResourceType.value
            'system.model'                = $systemmodel.value
            'system.sysoid'               = $systemsysoid.value
            'DS - Memory'                 = $memoryStatus
            'DS - CPU'                    = $cpuStatus
            'DS - Disk'                   = $diskStatus
            'DS - Filesystem'             = $filesystemStatus
            'DS - Interfaces'             = $InterfaceStatus
            'DS - WMIStatus'              = $WMIStatus
            'DS - SNMPStatus'             = $SNMPStatus
            'DS - HTTPSStatus'            = $httpsStatus
            #'All datasources'             = $datasources
            'DS - Interface (name)'       = $interfaceDatasourcesString
            'DS - CPU (name)'             = $cpuDatasourcesString
            'DS - File (name)'            = $fileDatasourcesString
            'DS - Memory (name)'          = $memoryDatasourcesString
        }
    } catch {
        Write-Host "Failed to process device: $($device.displayName) - $($_.Exception.Message)"
    }
}
$deviceDetails | Export-Csv -Path "DeviceDetails.csv" -NoTypeInformation

# EOF
