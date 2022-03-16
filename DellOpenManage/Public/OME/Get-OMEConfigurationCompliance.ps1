
using module ..\..\Classes\Device.psm1
using module ..\..\Classes\ConfigurationBaseline.psm1
using module ..\..\Classes\ConfigurationCompliance.psm1

function Get-OMEConfigurationCompliance {
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
    Get device configuration compliance report from OpenManage Enterprise
.DESCRIPTION
    To get the configuration compliance for a device you need to create a Configuration Baseline first.
.PARAMETER Baseline
    Array of type Baseline returned from Get-OMEConfigurationBaseline function
.PARAMETER DeviceFilter
    Array of type Device returned from Get-OMEDevice function. Used to limit the devices updated within the baseline.
.PARAMETER Output
.INPUTS
    Baseline[]
.EXAMPLE
    "TestBaseline01" | Get-OMEConfigurationBaseline | Get-OMEConfigurationCompliance | Format-Table

    Get configuration compliance report for all devices in baseline
.EXAMPLE
    "TestBaseline01" | Get-OMEConfigurationBaseline | Get-OMEConfigurationCompliance -DeviceFilter $("FVKGSWZ" | Get-OMEDevice -FilterBy "ServiceTag") | Format-Table

    Get configuration compliance report for specific devices in baseline
#>

[CmdletBinding()]
param(
    [Parameter(Mandatory=$false, ValueFromPipeline)]
    [ConfigurationBaseline]$Baseline,

    [Parameter(Mandatory=$false)]
    [Device[]]$DeviceFilter

    # Not implemented yet
    #[Parameter(Mandatory=$false)]
    #[ValidateSet("Report", "Data")]
    #[String]$Output = "Report"
)

Begin {}
Process {
    if (!$(Confirm-IsAuthenticated)){
        Return
    }
    Try {
        if ($SessionAuth.IgnoreCertificateWarning) { Set-CertPolicy }
        $BaseUri = "https://$($SessionAuth.Host)"
        $Type = "application/json"
        $Headers = @{}
        $Headers."X-Auth-Token" = $SessionAuth.Token
        $BaselineId = $null
        if ($Baseline.Count -gt 0) {
            $BaselineId = $Baseline.Id
        } else {
            $BaselineId = $Id
        }
        $ComplURL = $BaseUri + "/api/TemplateService/Baselines($($BaselineId))/DeviceConfigComplianceReports"
        $Response = Invoke-WebRequest -Uri $ComplURL -UseBasicParsing -Headers $Headers -ContentType $Type -Method GET
        $DeviceComplianceReport = @()

        #$CONFIG_STATUS_MAP = @{
        #    1 = "Compliant";
        #    2 = "Not Compliant"
        #}

        if ($Response.StatusCode -eq 200) {
            $ComplData = $Response | ConvertFrom-Json
            $ComplianceDeviceList = $ComplData.'value'

            if($ComplData.'@odata.nextLink') {
                $NextLinkUrl = $BaseUri + $ComplData.'@odata.nextLink'
            }
            while($NextLinkUrl)
            {
                $NextLinkResponse = Invoke-WebRequest -Uri $NextLinkUrl -UseBasicParsing -Method GET -Headers $Headers -ContentType $Type
                if($NextLinkResponse.StatusCode -eq 200) {
                    $NextLinkData = $NextLinkResponse.Content | ConvertFrom-Json
                    $ComplianceDeviceList = $ComplianceDeviceList + $NextLinkData.'value'
                    if($NextLinkData.'@odata.nextLink')
                    {
                        $NextLinkUrl = $BaseUri + $NextLinkData.'@odata.nextLink'
                    }
                    else
                    {
                        $NextLinkUrl = $null
                    }
                } else {
                    Write-Warning "Unable to get nextlink response for $($NextLinkUrl)"
                    $NextLinkUrl = $null
                }
            }

            if ($ComplianceDeviceList.Length -gt 0) {
                # Loop through devices
                foreach ($ComplianceDevice in $ComplianceDeviceList) {
                    # Required for OME 3.4 support. OME 3.5 switched over to using an Integer for ComplianceStatus
                    $ComplianceStatus = ""
                    if ($ComplianceDevice.ComplianceStatus -eq 1 -or $ComplianceDevice.ComplianceStatus -eq "COMPLIANT") {
                        $ComplianceStatus = "Compliant"
                    } elseif ($ComplianceDevice.ComplianceStatus -eq 2 -or $ComplianceDevice.ComplianceStatus -eq "NONCOMPLIANT") {
                        $ComplianceStatus = "Not Compliant"
                    } else {
                        $ComplianceStatus = $ComplianceDevice.ComplianceStatus
                    }

                    # Check if the device is in the provided Devices list. Only return results for devices in the list, if a list was provided
                    if (($DeviceFilter.Count -gt 0 -and $DeviceFilter.Id -contains $ComplianceDevice.Id) -or $DeviceFilter.Count -eq 0) {
                        $DeviceComplianceReport += [ConfigurationCompliance]@{
                            Id = $ComplianceDevice.Id
                            ServiceTag = $ComplianceDevice.ServiceTag
                            DeviceModel = $ComplianceDevice.Model
                            DeviceName = $ComplianceDevice.DeviceName
                            ComplianceStatus = $ComplianceStatus
                            InventoryTime = $ComplianceDevice.InventoryTime
                        }
                    }
                }
            }
            else {
                Write-Warning "Compliance value list is empty"
            }
        }
        else {
            Write-Warning "Unable to fetch device compliance info..."
        }
        return $DeviceComplianceReport
    }
    Catch {
        Resolve-Error $_
    }
}

End {}

}

