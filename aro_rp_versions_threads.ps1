#Requires -Version 7.0

<#
.SYNOPSIS
    Pulls RPVersion and OCPVersions for each RP region location provided as an array of strings or as an input file (one region per line)

.DESCRIPTION
    This script is useful to compare RP versions and OCP streams between regions
    Pulls RPVersion and OCPVersions for each RP region location provided as an array of strings or as an input file (one region per line)

.PARAMETER InputLocationsFile
    Optional input file if different from default.

.PARAMETER location
    Optional region location if only selected output is needed.

.EXAMPLE
    .\aro_rp_versions_threads.ps1

.EXAMPLE
    .\aro_rp_versions_threads.ps1 -location "westeurope","eastasia"

.EXAMPLE
    .\aro_rp_versions_threads.ps1 -InputLocationsFile=".\locations.txt"
#>

[CmdletBinding()]
param (
    [Parameter(ParameterSetName='Location', Mandatory=$false)]
    [string[]]$location
)

[array]$locations = @()
[array]$colLocations = @()
$count = 0

$ParameterSet = $PSCmdlet.ParameterSetName
if($ParameterSet -eq "Location"){
    $locations = $location
}
else{
    $locations = "eastus2euap", "westcentralus", "australiaeast", "japaneast", "koreacentral",
    "australiasoutheast", "centralindia", "southindia", "japanwest", "eastasia",
    "centralus", "eastus", "eastus2", "northcentralus", "southcentralus",
    "westus", "westus2", "canadacentral", "canadaeast", "francecentral",
    "germanywestcentral", "northeurope", "norwayeast", "switzerlandnorth", "switzerlandwest",
    "westeurope", "brazilsouth", "brazilsoutheast", "southeastasia", "uaenorth",
    "southafricanorth", "uksouth", "ukwest"

}

$Jobs = @()

foreach($loc in $locations){
    $count++

    $Jobs += Start-ThreadJob -ScriptBlock {
        param(
            $loc
        )

        return $locHash = @{
            Location = $loc
            OCPVersions = Get-OCPVersions -location $loc
            RPVersion = Get-RPVersion -location $loc
        }

    } -ArgumentList $loc `
      -ThrottleLimit 50 -Name $loc `
      -InitializationScript {
        function Get-OCPVersions {
            param (
                [string]$location
            )

            try{
                $versions = Invoke-RestMethod "https://arorpversion.blob.core.windows.net/ocpversions/${location}"
                return $versions.version -join ','
            }
            catch{
                Write-Verbose "Failed to retrieve OCP versions for ${location}: $_"
                return $null
            }
        }

        function Get-RPVersion {
            param (
                [string]$location
            )

            try {
                $rpCommit = Invoke-RestMethod -Uri "https://arorpversion.blob.core.windows.net/rpversion/${location}"
                return $rpCommit
            }
            catch {
                write-Verbose "Failed to retrieve RP versions for ${location}: $_"
                return $null
            }

        }
    }

}

$colLocations = $Jobs | Wait-Job | Receive-Job

$Results = @()
foreach($item in $colLocations){
    $Results += New-Object -TypeName PSCustomObject -Property $item
}

$Results | Sort-Object -Property Location | Format-Table Location, RPVersion, OCPVersions -AutoSize
