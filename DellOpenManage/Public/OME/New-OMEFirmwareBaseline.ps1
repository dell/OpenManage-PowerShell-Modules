using module ..\..\Classes\Device.psm1
using module ..\..\Classes\Group.psm1
using module ..\..\Classes\Catalog.psm1
using module ..\..\Classes\Baseline.psm1

function New-OMEFirmwareBaseline {
<#
Copyright (c) 2018 Dell EMC Corporation

Licensed under the Apache License, Version 2.0 (the "License");
you may not use this file except in compliance with the License.
You may obtain a copy of the License at

      http://www.apache.org/licenses/LICENSE-2.0

Unless required by applicable law or agreed to in writing, software
distributed under the License is distributed on an "AS IS" BASIS,
WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
See the License for the specific language governing permissions and
limitations under the License.
#>

<#
.SYNOPSIS
    Create new firmware baseline in OpenManage Enterprise
.DESCRIPTION
    A baseline is used to compare updates in a catalog against a set of devices.
.PARAMETER Name
    Name of baseline
.PARAMETER Description
    Description of baseline
.PARAMETER Catalog
    Object of type Catalog returned from Get-OMECatalog function
.PARAMETER Group
    Object of type Group returned from Get-OMEGroup function
.PARAMETER Devices
    Array of type Device returned from Get-OMEDevice function
.PARAMETER AllowDowngrade
    Allow downgrade of component firmware
.PARAMETER Wait
    Wait for job to complete
.PARAMETER WaitTime
    Time, in seconds, to wait for the job to complete
.INPUTS
    None
.EXAMPLE
    New-OMEFirmwareBaseline -Name "TSTestBaseline01" -Catalog $("Auto-Update-Online" | Get-OMECatalog) -Devices $("C86C0Q2" | Get-OMEDevice -FilterBy "ServiceTag") | Format-Table
    Create new firmware baseline using existing catalog
#>

[CmdletBinding()]
param(
    [Parameter(Mandatory)]
    [String]$Name,

    [Parameter(Mandatory=$false)]
    [String]$Description,

    [Parameter(Mandatory)]
    [Catalog]$Catalog,

    [Parameter(Mandatory=$false)]
    [Group]$Group,

    [Parameter(Mandatory=$false)]
    [Device[]]$Devices,

    [Parameter(Mandatory=$false)]
    [Switch]$AllowDowngrade,

    [Parameter(Mandatory=$false)]
    [Switch]$Wait,

    [Parameter(Mandatory=$false)]
    [int]$WaitTime = 30
)

Begin {
    if(!$SessionAuth.Token){
        Write-Error "Please use Connect-OMEServer first"
        Break
        Return
    }
}
Process {
    Try {
        if ($SessionAuth.IgnoreCertificateWarning) { Set-CertPolicy }
        $BaseUri = "https://$($SessionAuth.Host)"
        $Type = "application/json"
        $Headers = @{}
        $Headers."X-Auth-Token" = $SessionAuth.Token

        $payload = '{
            "Name": "Factory Baseline1",
            "Description": "Factory test1",
            "CatalogId": 1104,
            "RepositoryId": 604,
            "DowngradeEnabled": false,
            "Is64Bit": true,
            "Targets": [
                {
                    "Id":"target_id",
                    "Type": {
                        "Id": "target_type",
                        "Name": "target_name"
                }
                }
            ]
        }' | ConvertFrom-Json

        $TargetArray = @()
        if ($Devices.Count -gt 0) {
            $TargetTypeHash = @{
                Id = 1000
                Name = "DEVICE"
            }
            foreach ($Device in $Devices) {
                $TargetTempHash = @{
                    Id = $Device.Id
                    Type = $TargetTypeHash
                }
                $TargetArray += $TargetTempHash
            }
        } 
        elseif ($Group) {
            $TargetTypeHash = @{
                Id = 2000
                Name = "GROUP"
            }
            $TargetTempHash = @{
                Id = $Group.Id
                Type = $TargetTypeHash
            }
            $TargetArray += $TargetTempHash
        }
        $payload."Targets" = $TargetArray
        $payload."Name" = $Name
        $payload."Description" = $Description
        $payload."DowngradeEnabled" = $AllowDowngrade.IsPresent
        $payload."CatalogId" = $Catalog.Id
        $payload."RepositoryId" = $Catalog.Repository.Id
        $BaselinePayload = $payload

        $BaselineURL = $BaseUri + "/api/UpdateService/Baselines"
        $BaselinePayload = $BaselinePayload | ConvertTo-Json -Depth 6
        Write-Verbose $BaselinePayload
        $BaselineResponse = Invoke-WebRequest -Uri $BaselineURL -UseBasicParsing -Headers $Headers -ContentType $Type -Method POST -Body $BaselinePayload
        if ($BaselineResponse.StatusCode -eq 201) {
            #$BaselineData = $BaselineResponse.Content | ConvertFrom-Json
            if ($Wait) {
                Start-Sleep -s $WaitTime
                $NewBaselineResponse = Invoke-WebRequest -Uri $BaselineURL -UseBasicParsing -Headers $Headers -ContentType $Type -Method GET
                $NewBaselineInfo = $NewBaselineResponse | ConvertFrom-Json
                foreach ($Baseline in $NewBaselineInfo.'value') {
                    if ($Baseline.Name -eq $Name) {
                        #$repoId = [uint64]$catalog.'Repository'.'Id'
                        #$catalog_id = [uint64]$catalog.'Id'
                        return $Baseline
                    }
                }
            }
            Write-Verbose "Baseline creation successful..."
        }
        else {
            Write-Error "Baseline creation failed"
        }
    } 
    Catch {
        Write-Error ($_.ErrorDetails)
        Write-Error ($_.Exception | Format-List -Force | Out-String) 
        Write-Error ($_.InvocationInfo | Format-List -Force | Out-String)
    }
}

End {}

}

