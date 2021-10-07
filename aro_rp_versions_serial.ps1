function Get-OCPVersions {
    param (
        [string]$Url
    )


    try {
        $Versions = (Invoke-RestMethod -Uri $Url).version
    }
    catch {
        return $null
    }

    return $Versions -join ","

}

function Get-RPVersion {
    param (
        [string]$Url
    )

    try {
        $Version = Invoke-RestMethod -Uri $Url
    }
    catch {

        return $null
    }

    return $Version

}

function Start-ProcessLocation {
    param (
        [string]$Location
    )

    $OCPVersionsUrl = "https://arorpversion.blob.core.windows.net/ocpversions/${Location}"
    $RPVersionUrl = "https://arorpversion.blob.core.windows.net/rpversion/${Location}"

    [PSCustomObject]@{
        Location = $Location
        OCPVersions = Get-OCPVersions($OCPVersionsUrl)
        RPVersion = Get-RPVersion($RPVersionUrl)
    }

}


$Locations = "eastus2euap", "westcentralus", "australiaeast", "japaneast", "koreacentral",
             "australiasoutheast", "centralindia", "southindia", "japanwest", "eastasia",
             "centralus", "eastus", "eastus2", "northcentralus", "southcentralus",
             "westus", "westus2", "canadacentral", "canadaeast", "francecentral",
             "germanywestcentral", "northeurope", "norwayeast", "switzerlandnorth", "switzerlandwest",
             "westeurope", "brazilsouth", "brazilsoutheast", "southeastasia", "uaenorth",
             "southafricanorth", "uksouth", "ukwest"


[array]$Results = @()


foreach ($Location in $Locations) {
    $Results += Start-ProcessLocation($Location)

}

$Results | Sort-Object -Property Location
