using module ..\..\Classes\Template.psm1
using module ..\..\Classes\Device.psm1

function Invoke-OMEProfileUnassign {
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
    Unassign profile from device in OpenManage Enterprise
.DESCRIPTION
    This action will unassign the profile(s) from all selected targets, disassociating the profile(s) from target(s).
    The server will be forcefully rebooted in order to remove any deployed identities from applicable devices.
    As of OME 3.4 only one template can be associated to a device. However, you can deploy a template to multiple devices.
.PARAMETER Template
    Object of type Template returned from Get-OMETemplate function
.PARAMETER Devices
    Array of type Device returned from Get-OMEDevice function
.PARAMETER ProfileName
    Name of Profile to detach. Uses contains style operator and supports partial string matching.
.PARAMETER Wait
    Wait for job to complete
.PARAMETER WaitTime
    Time, in seconds, to wait for the job to complete
.INPUTS
    Devices
.EXAMPLE
    Invoke-OMEProfileUnassign -Devices $("37KP0ZZ", "GV6V0ZZ" | Get-OMEDevice) -Wait -Verbose
    Unassign profile by device
.EXAMPLE
    Invoke-OMEProfileUnassign -Template $("TestTemplate01" | Get-OMETemplate) -Wait -Verbose
    Unassign profile by template
.EXAMPLE
    Invoke-OMEProfileUnassign -ProfileName "Profile from template 'TestTemplate01' 00001" -Wait -Verbose
    Unassign profile by profile name
#>

[CmdletBinding()]
param(
    [Parameter(Mandatory=$false)]
    [Device[]] $Devices,

    [Parameter(Mandatory=$false)]
    [Template] $Template,

    [Parameter(Mandatory=$false)]
    [String]$ProfileName,

    [Parameter(Mandatory=$false)]
    [Switch]$Wait,

    [Parameter(Mandatory=$false)]
    [int]$WaitTime = 3600
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
        $Type        = "application/json"
        $Headers     = @{}
        $Headers."X-Auth-Token" = $SessionAuth.Token

        $ProfileUnassignUrl = $BaseUri + "/api/ProfileService/Actions/ProfileService.ProfileUnassigns"
        $ProfileUnassignPayload = '{
            "SelectAll":true,
            "Filters":"=contains(TargetId, 0, 0)"
        }' | ConvertFrom-Json

        $DeviceIds = @()
        foreach ($Device in $Devices) {
            $DeviceIds += $Device.Id
        }
        if ($DeviceIds.Length -gt 0) {
            $ProfileUnassignPayload.Filters = "=contains(TargetId, $($DeviceIds -join ','))"
        } elseif ($Template) {
            $ProfileUnassignPayload.Filters = "=contains(TemplateId, $($Template.Id))"
        } elseif ($ProfileName) {
            $ProfileUnassignPayload.Filters = "=contains(ProfileName, '$($ProfileName)')"
        } else {
            throw [System.Exception] "Must specify one of the following parameters: -Devices -Template -ProfileName"
        }
        $ProfileUnassignPayload = $ProfileUnassignPayload |ConvertTo-Json -Depth 6
        Write-Verbose $ProfileUnassignPayload
        $ProfileUnassignResponse = Invoke-WebRequest -Uri $ProfileUnassignUrl -Method Post -Body $ProfileUnassignPayload -ContentType $Type -Headers $Headers
        if ($ProfileUnassignResponse.StatusCode -eq 200) {
            $ProfileUnassignContent = $ProfileUnassignResponse.Content | ConvertFrom-Json
            $JobId = $ProfileUnassignContent
            if ($JobId -ne 0) {
                Write-Verbose "Created job $($JobId) to unassign profiles..."
                if ($Wait) {
                    $JobStatus = $($JobId | Wait-OnJob -WaitTime $WaitTime)
                    return $JobStatus
                } else {
                    return $JobId
                }
            } else {
                Write-Warning "No profiles unassigned"
            }
        } else {
            Write-Error "Failed to unassign profiles"
        }
        return $ProfileUnassignResponse
    }
    Catch {
        Resolve-Error $_
    }
}

End {}

}

