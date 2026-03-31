<#
.SYNOPSIS
  This script will get a list of LogicModules and save the xml files plus a README.md for git.
  
.DESCRIPTION
  This script will get a list of LogicModules and save the xml files to a folder with the module name.
  Ensure that Powershell module is installed and updated via:
   Install-Module -Name "Logic.Monitor"
   Update-Module -Name "Logic.Monitor"

.INPUTS
  None
  
.OUTPUTS
  Will write to the screen.
  Will create/overwrite the files with new exports into the base folder/<instance>/datasourcename.
  Files saved are: datasourcename.xml and README.md file with key fields recorded.


.NOTES
  Author:         Ryan Gillan
  Creation Date:  14-Mar-2025


.EXAMPLE
   get-help .\get-logicmodules_and_backup.ps1
   

#Requires -Modules @{ ModuleName="Logic.Monitor" } # This has been commented out. Needs admin rights to install but is a pain to always run in elevated.


#>
#============================ Variables ======================================================
$AccountName = "Portal1"                        # Portal to use
$ModTypes = "datasources"                       # datasources | propertyrules | eventsources | topologysources | configsources | logsources | functions | oids
#$ModTypes = "logsources"
#$ModTypes = "functions"
#$ModTypes = "reports"
#$ModTypes = "propertyrules"
#$ModTypes = "configsources"
$BasePath = "C:\backup\LogicMonitor\$ModTypes"    # Base folder for downloads to be saved eg $DownloadPath = "C:\temp\DS\ will be: "C:\temp\DS\<$AccountName>

# ------ (optional variables) ------
# Use these variables to target a single module or only run against a specific amount.
#$singleDSnumber = 365                          # Specify a single DS to run against. ie only backup a single file.
$singleDSnumber = $null                         # All DS. This should be the default
#============================= end of variables===============================================
# Adjusting the $DownloadPath to include the Portal name.
$DownloadPath = "$($BasePath)\$($AccountName)"

# The following will check if connected to LogicMonitor already using the Connect-LMAccount, else prompt to connect.
$LMportal = Get-LMPortalInfo | Select-Object -ExpandProperty companyDisplayName

if ($LMportal -like "*Portal1*") {
    Write-Host "Connected to portal: $($AccountName)" -ForegroundColor Green
} elseif ($LMportal -like "*Portal2*") {
    Write-Host "Connected to portal: $($AccountName)" -ForegroundColor Green
} else {
    Write-Host "Not connected. Prompting user"
    $AccountName = Read-Host -Prompt "Enter LM portal to connect to: "
    if (-not $AccountName) {
        $AccountName = "epworthhealthcare"
    }
    # If this is not set or we are connected, prompt.
    $AccessId = Read-Host -Prompt "Enter LM portal API user"
    $AccessKey = Read-Host -Prompt "Enter LM portal API Key"
    # Output to the screen.
    Write-Host "Account Name: $AccountName" `n "Access ID: $AccessId" `n "Access Key: $AccessKey"

    # Try to connect to LM instance else error.
    Try {
        Connect-LMAccount -AccessId $AccessId -AccessKey $AccessKey -AccountName $AccountName -ErrorAction Stop
    }
    Catch {
        $_.Exception
        Write-Host "An error occurred connecting to LogicMonitor $AccountName as $AccessId" -ForegroundColor Red
        break
    }
}

#<--- -------------------- Overview menu ----------------------------- --->
$menu = @(
    [PSCustomObject]@{ Name = "LM instance"; Value = $AccountName },
    [PSCustomObject]@{ Name = "Will use Parent folder"; Value = $BasePath },
    [PSCustomObject]@{ Name = "Exports written to"; Value = $DownloadPath },
    [PSCustomObject]@{ Name = "Exporting"; Value = $ModTypes },
    [PSCustomObject]@{ Name = ""; Value = "" } # Blank line
)
$menu | Format-SpectreTable -Property Name, Value -title "Overview of setup details"

read-host "This is about to run against the above items. ENTER to continue or ctrl c to end."

#datasources | propertyrules | eventsources | topologysources | configsources | logsources | functions | oids | reports
# Check the value of $ModTypes. Setup an alias of Show-Modules so we can reuse variable for later.
switch ($ModTypes) {
    "datasources" {
        Set-Alias -Name Show-Modules -Value Get-LMDatasource
        if ($null -ne $singleDSnumber) {
            $ids = Show-Modules -BatchSize 1000 -id $singleDSnumber	
        } else {
            $ids = Show-Modules -BatchSize 1000
        }
    }
    "propertyrules" {
        Set-Alias -Name Show-Modules -Value Get-LMPropertySource
        if ($null -ne $singleDSnumber) {
            $ids = Show-Modules -BatchSize 1000 -id $singleDSnumber	
        } else {
            $ids = Show-Modules -BatchSize 1000
        }
    }
    "PropertySource" {
        Set-Alias -Name Show-Modules -Value Get-LMPropertySource
        if ($null -ne $singleDSnumber) {
            $ids = Show-Modules -BatchSize 1000 -id $singleDSnumber	
        } else {
            $ids = Show-Modules -BatchSize 1000
        }
    }
    "eventsources" {
        Set-Alias -Name Show-Modules -Value Get-LMEventSource
        if ($null -ne $singleDSnumber) {
            $ids = Show-Modules -BatchSize 1000 -id $singleDSnumber
        } else {
            $ids = Show-Modules -BatchSize 1000
        }
    }
    "topologysources" {
        Set-Alias -Name Show-Modules -Value Get-LMTopologySource
        if ($null -ne $singleDSnumber) {
            $ids = Show-Modules -BatchSize 1000 -id $singleDSnumber
        } else {
            $ids = Show-Modules -BatchSize 1000
        }
    }
    "configsources" {
        Set-Alias -Name Show-Modules -Value Get-LMConfigSource
        if ($null -ne $singleDSnumber) {
            $ids = Show-Modules -BatchSize 1000 -id $singleDSnumber
        } else {
            $ids = Show-Modules -BatchSize 1000
        }
    }
    "logsources" {
        Set-Alias -Name Show-Modules -Value Get-LMLogSource
        if ($null -ne $singleDSnumber) {
            $ids = Show-Modules -BatchSize 1000 -id $singleDSnumber
        } else {
            $ids = Show-Modules -BatchSize 1000
        }
    }
    "functions" {
        Set-Alias -Name Show-Modules -Value Get-LMAppliesToFunction
        if ($null -ne $singleDSnumber) {
            $ids = Show-Modules -BatchSize 1000 -id $singleDSnumber
        } else {
            $ids = Show-Modules -BatchSize 1000
        }
    }
#    "reports" {
	     #To backup reports to a json file, use:
		 # Get-LMReport -Id 125 | Select-Object * | ConvertTo-Json -Depth 5 | Out-File "C:\Reports\LMReport_125.json
#        Set-Alias -Name Show-Modules -Value Get-LMReport
#        if ($null -ne $singleDSnumber) {
#            $ids = Show-Modules -BatchSize 1000 -id $singleDSnumber
#        } else {
#            $ids = Show-Modules -BatchSize 1000
#        }
#    }
    "oids" {
        Set-Alias -Name Show-Modules -Value Get-LMSysOIDMap
        if ($null -ne $singleDSnumber) {
            $ids = Show-Modules -BatchSize 1000 -id $singleDSnumber
        } else {
            $ids = Show-Modules -BatchSize 1000
        }
    }
    default {
        Write-Host "Unknown value for the variable ModTypes"
        break
    }
}

# Output the result
if ($singleDSnumber) {
    Write-Host "The count to be processed: $($ids.name.count)"
} else {
    Write-Host "The count to be processed: $($ids.count)"
}

$FailedExports = @()
$counter = 1
foreach ($item in $ids) {
    $percentComplete = ($counter / $ids.count) * 100
    Write-Progress -Activity "Exporting LogicModules: $($ModTypes)" -Status "Working on module: $($item.Id) --> $($item.Name)" -PercentComplete $percentComplete
    try {
        # Retrieve the name of the data source
        $dsName = (Show-Modules -BatchSize 1000 -Id $item.Id | Select-Object -ExpandProperty name)
        $dsName = $dsName -replace ":", "" #strip ":" as this is not supported in folder names.

        # Create a unique folder for each LogicModule using the name
        $itemDownloadPath = "$DownloadPath\$dsName"
        if (-not (Test-Path -Path $itemDownloadPath)) {
            New-Item -ItemType Directory -Path $itemDownloadPath | Out-Null
        }
        
        # Export module.
        Export-LMLogicModule -id $item.Id -Type $ModTypes -DownloadPath $itemDownloadPath | Out-Null #hide errors. Not sure why we see errors
        
        # Check if the file exists
        $fileName = "$itemDownloadPath\$($item.name).*" #(only DS export as xml, most are now json)
        if (-not (Test-Path -Path $fileName)) {
            $FailedExports += $item.Id
            Write-Host "Failed export on: $item.Id" -ForegroundColor Red | Export-Csv -Path "$DownloadPath\FailedExports.csv" -NoTypeInformation
        }

        # Get details about the LMDatasource
        $lmds = Show-Modules -BatchSize 1000 -Id $item.Id | Select-Object @(
            @{N="id"; E={$_.id}},
            @{N="appliesTo"; E={$_.appliesTo -replace "`n", ""}},
            @{N="name"; E={$_.name}},
            @{N="displayName"; E={$_.displayName}},
            @{N="tags"; E={$_.tags}},
            @{N="technology"; E={$_.technology -replace "`n", ""}},
            @{N="collectInterval"; E={$_.collectInterval}},
            @{N="collectMethod"; E={$_.collectMethod}},
            @{N="description"; E={$_.description}}
        )

        # Gather the last write time of the file to use in the menu.
        $formattedTimestamp = Get-Date -Format "dd-MM-yyyy"

        # Create the markdown content. Do not adjust indenting or you may break the array and the markdown table.
        $markdownContent = @"
## LogicMonitor Module details
### Module type: $ModTypes

| Item:                 | Details|
| ----|----|
| ID:                   | $($lmds.id) |
| Name:                 | $($lmds.name) |
| Display Name:         | $($lmds.displayName) |
| Applies To:           | $($lmds.appliesTo) |
| Description:          | $($lmds.description) |
| Tags:                 | $($lmds.tags) |
| Collect Method:       | $($lmds.collectMethod) |
| Collect Interval:     | $($lmds.collectInterval) |
| Namespace:            | $($lmdsmeta.namespace) |
| Registry version:     | $($lmdsmeta.registryVersion) |
| Quality:              | $($lmdsmeta.quality) |
| LMLocator:            | $($lmdsmeta.lmLocator) |
| Status:               | $($lmdsmeta.status)|
| Tech note:            | $($lmds.technology) |
| Export date:          | $formattedTimestamp |
"@

        # Define the path for the README.md file
        $readmePath = "$itemDownloadPath\README.md"

        # Write the markdown content to the README.md file
        $markdownContent | Out-File -FilePath $readmePath -Encoding utf8

    } catch {
        $FailedExports += $item.Id
        #Write-Host "Failed with: $($item)" | Export-Csv -Path "$DownloadPath\FailedExports.csv" -NoTypeInformation
    }
    Start-Sleep -s 1 # slowing things down.
    $counter++
}
Write-Progress -Activity "Exporting Modules" -Completed

# Write failed exports to CSV
if ($FailedExports.Count -gt 0) {
    #$FailedExports | Export-Csv -Path "$DownloadPath\FailedExports.csv" -NoTypeInformation
    Write-Host "May not have fully exported." -ForegroundColor Red
} else {
    Write-Host "All LogicModules exported successfully." -ForegroundColor Green
}

# Check how many Modules have been exported.
$xmlFiles = Get-ChildItem -Path $DownloadPath -Recurse | Where-Object { $_.Extension -in ".xml", ".json" }
$xmlFileCount = $xmlFiles.Count
$difference = $ids.Count - $xmlFileCount

if ($xmlFileCount -ne $ids.Count) {
    Write-Host "Error: Found $($ids.Count) Modules, but only $($xmlFileCount) XML files." -ForegroundColor Red
    Write-Host "The difference between IDs count and XML files count is: $difference" -ForegroundColor Red
} else {
    Write-Host "Export completed. Found $($ids.Count) Modules. Saved $($xmlFileCount) exported files." -ForegroundColor Green
    Write-Host "Export count OK." -ForegroundColor Green
}

Write-Host "Markdown files have been created for each LogicModule for: $($AccountName) into: $DownloadPath" -ForegroundColor Green

#EOF
