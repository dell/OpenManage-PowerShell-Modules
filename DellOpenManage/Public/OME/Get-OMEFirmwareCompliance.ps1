
using module ..\..\Classes\Device.psm1
using module ..\..\Classes\FirmwareBaseline.psm1
using module ..\..\Classes\ComponentCompliance.psm1

function Get-FirmwareComplianceObject($UpdateActionSet, $Component, $ComplianceDevice) {
    # Check for UpdateAction to allow for downgrade of firmware
    if ($UpdateActionSet.ToUpper().Contains($Component.UpdateAction)) {
        # Create object for display to user
        $ReportObject = [ComponentCompliance]@{
            DeviceId = $ComplianceDevice.DeviceId
            ServiceTag = $ComplianceDevice.ServiceTag
            DeviceModel = $ComplianceDevice.DeviceModel
            DeviceName = $ComplianceDevice.DeviceName
            Id = $Component.Id
            Version = $Component.Version
            CurrentVersion = $Component.CurrentVersion
            Path = $Component.Path
            Name = $Component.Name
            Criticality = $Component.Criticality
            UniqueIdentifier = $Component.UniqueIdentifier
            TargetIdentifier = $Component.TargetIdentifier
            UpdateAction = $Component.UpdateAction
            SourceName = $Component.SourceName
            PrerequisiteInfo = $Component.PrerequisiteInfo
            ImpactAssessment = $Component.ImpactAssessment
            Uri = $Component.Uri
            RebootRequired = $Component.RebootRequired
            ComplianceStatus = $Component.ComplianceStatus
            ComponentType = $Component.ComponentType
        }
        return $ReportObject
    }
}

function Get-OMEFirmwareCompliance {
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
    Get device firmware compliance report from OpenManage Enterprise
.DESCRIPTION
    To get the list of firmware updates for a device you need a Catalog and a Baseline first.
    Then you can see the firmware that needs updated.
.PARAMETER Baseline
    Array of type Baseline returned from Get-OMEFirmwareBaseline function
.PARAMETER DeviceFilter
    Array of type Device returned from Get-OMEDevice function. Used to limit the devices updated within the baseline.
.PARAMETER ComponentFilter
    Array of Strings that represent component name. Used to limit the components updated within the baseline. Supports regex via Powershell -match
.PARAMETER UpdateAction
    Determines what type of updates will be performed. (Default="Upgrade", "Downgrade", "All")
.PARAMETER Output
.INPUTS
    Baseline[]
.EXAMPLE
    "AllLatest" | Get-OMEFirmwareBaseline | Get-OMEFirmwareCompliance | Format-Table

    Get report for existing baseline
.EXAMPLE
    "AllLatest" | Get-OMEFirmwareBaseline | Get-OMEFirmwareCompliance -DeviceFilter $("FVKGSWZ" | Get-OMEDevice -FilterBy "ServiceTag") | Format-Table

    Filter report by device in baseline
.EXAMPLE
    "AllLatest" | Get-OMEFirmwareBaseline | Get-OMEFirmwareCompliance -ComponentFilter "iDRAC" | Format-Table
    
    Filter report by component in baseline
.EXAMPLE
    "AllLatest" | Get-OMEFirmwareBaseline | Get-OMEFirmwareCompliance -ComponentFilter -ComponentFilter "iDRAC", "BIOS"  | Format-Table
    
    Filter report by multiple components in baseline
#>

[CmdletBinding()]
param(
    [Parameter(Mandatory=$false, ValueFromPipeline)]
    [FirmwareBaseline[]]$Baseline,

    [Parameter(Mandatory=$false)]
    [Device[]]$DeviceFilter,

    [Parameter(Mandatory=$false)]
    [String[]]$ComponentFilter,

    [Parameter(Mandatory=$false)]
    [ValidateSet("Upgrade", "Downgrade", "All")]
    [String[]]$UpdateAction = "Upgrade",

    [Parameter(Mandatory=$false)]
    [ValidateSet("Report", "Data")]
    [String]$Output = "Report"
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

        $ComplURL = $BaseUri + "/api/UpdateService/Baselines($($BaselineId))/DeviceComplianceReports"
        $Response = Invoke-WebRequest -Uri $ComplURL -UseBasicParsing -Headers $Headers -ContentType $Type -Method GET
        $DeviceComplianceReport = @()
        $DeviceComplianceReportTargetList = @()

        $UpdateActionSet = @()
        if ($UpdateAction -eq "All") {
            $UpdateActionSet += "Upgrade"
            $UpdateActionSet += "Downgrade"
            $UpdateActionSet += "Equal"
        } else {
            $UpdateActionSet += $UpdateAction
        }

        if ($Response.StatusCode -in 200, 201) {
            $ComplData = $Response | ConvertFrom-Json
            $ComplianceDeviceList = $ComplData.'value'

            if($ComplData.'@odata.nextLink') {
                $NextLinkUrl = $BaseUri + $ComplData.'@odata.nextLink'
            }
            while($NextLinkUrl)
            {
                $NextLinkResponse = Invoke-WebRequest -Uri $NextLinkUrl -UseBasicParsing -Method GET -Headers $Headers -ContentType $Type
                if($NextLinkResponse.StatusCode -in 200, 201) {
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
                    # Check if the device is in the provided Devices list. Only return results for devices in the list, if a list was provided
                    if (($DeviceFilter.Count -gt 0 -and $DeviceFilter.Id -contains $ComplianceDevice.DeviceId) -or $DeviceFilter.Count -eq 0) {
                        $sourcesString = $null
                        $DeviceComplianceReportPerDevice = @()
                        $CompList = $ComplianceDevice.'ComponentComplianceReports'
                        if ($CompList.Length -gt 0) {
                            # Loop through components
                            foreach ($Component in $CompList) {
                                $DeviceComplianceComponentReportObject = $null
                                # No Component filter set
                                if ($ComponentFilter.Length -eq 0) {
                                    $DeviceComplianceComponentReportObject = Get-FirmwareComplianceObject -UpdateActionSet $UpdateActionSet -Component $Component -ComplianceDevice $ComplianceDevice
                                    if ($null -ne $DeviceComplianceComponentReportObject) {
                                        $DeviceComplianceReportPerDevice += $DeviceComplianceComponentReportObject
                                        $DeviceComplianceReport += $DeviceComplianceComponentReportObject
                                    }
                                } else {
                                    foreach ($Filter in $ComponentFilter) {
                                        if (($Filter -ne "" -and $Component.Name -match $Filter)) {
                                            $DeviceComplianceComponentReportObject = Get-FirmwareComplianceObject -UpdateActionSet $UpdateActionSet -Component $Component -ComplianceDevice $ComplianceDevice
                                            if ($null -ne $DeviceComplianceComponentReportObject) {
                                                $DeviceComplianceReportPerDevice += $DeviceComplianceComponentReportObject
                                                $DeviceComplianceReport += $DeviceComplianceComponentReportObject
                                            }
                                        }
                                    }
                                }
                            }
                        }

                        # Now what we have the filtered list of updatable components, let's build the sourceString
                        foreach ($DeviceComplianceComponentReport in $DeviceComplianceReportPerDevice) {
                            # Create string to be used in payload
                            if ($null -ne $DeviceComplianceComponentReport) {
                                $sourceName = $DeviceComplianceComponentReport.'SourceName'
                                if ($sourcesString.Length -eq 0) {
                                    $sourcesString += $sourceName
                                }
                                else {
                                    $sourcesString += ';' + $sourceName
                                }
                            }
                        }
                        
                        # Create object to be used in payload
                        if ($null -ne $sourcesString) {
                            $DeviceComplianceReportTargetList += @{
                                Data = $sourcesString
                                Id = $ComplianceDevice.'DeviceId'
                            }
                        }
                    }
                }
            }
            else {
                Write-Warning "Compliance value list is empty"
            }
        }
        else {
            Write-Warning "Unable to fetch device compliance info...skipping"
        }
        # Display data to user or return data to be used in the update process
        if ($Output -eq "Data") {
            return $DeviceComplianceReportTargetList
        } else {
            return $DeviceComplianceReport
        }
    }
    Catch {
        Resolve-Error $_
    }
}

End {}

}

