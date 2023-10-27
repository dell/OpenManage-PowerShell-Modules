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
.PARAMETER Device
    Array of type Device returned from Get-OMEDevice function
.PARAMETER ProfileName
    Name of Profile to detach. Uses contains style operator and supports partial string matching.
.PARAMETER ForceReclaim
    Force Reclaim Identities. This action will reclaim the identities from this device and the server will be forcefully rebooted. All VLANs configured on the server will be removed.
.PARAMETER Wait
    Wait for job to complete
.PARAMETER WaitTime
    Time, in seconds, to wait for the job to complete
.INPUTS
    Device
.EXAMPLE
    Invoke-OMEProfileUnassign -Device $("37KP0ZZ" | Get-OMEDevice) -Wait -Verbose

    Unassign profile by device
.EXAMPLE
    $("37KP0ZZ", "37KT0ZZ" | Get-OMEDevice) | Invoke-OMEProfileUnassign -Wait -Verbose

    Unassign profile on multiple device
.EXAMPLE
    Invoke-OMEProfileUnassign -Template $("TestTemplate01" | Get-OMETemplate) -Wait -Verbose

    Unassign profile by template
.EXAMPLE
    Invoke-OMEProfileUnassign -ProfileName "Profile from template 'TestTemplate01' 00001" -Wait -Verbose
    
    Unassign profile by profile name
#>

[CmdletBinding()]
param(
    [Parameter(Mandatory=$false, ValueFromPipeline)]
    [Device] $Device,

    [Parameter(Mandatory=$false)]
    [Template] $Template,

    [Parameter(Mandatory=$false)]
    [String]$ProfileName,

    [Parameter(Mandatory=$false)]
    [Switch]$ForceReclaim,

    [Parameter(Mandatory=$false)]
    [Switch]$Wait,

    [Parameter(Mandatory=$false)]
    [int]$WaitTime = 3600
)

Begin {}
Process {
    if (!$(Confirm-IsAuthenticated)){
        Return
    }
    Try {
        if ($SessionAuth.IgnoreCertificateWarning) { Set-CertPolicy }
        $BaseUri = "https://$($SessionAuth.Host)"
        $Type        = "application/json"
        $Headers     = @{}
        $Headers."X-Auth-Token" = $SessionAuth.Token

        $ProfileUnassignUrl = $BaseUri + "/api/ProfileService/Actions/ProfileService.UnassignProfiles"
        $ProfileUnassignPayload = '{
            "SelectAll":true,
            "Filters":"=contains()",
            "ForceReclaim":false
        }' | ConvertFrom-Json

        if ($Device) {
            $ProfileUnassignPayload.Filters = "=contains(TargetName, '$($Device.DeviceName)')"
        } elseif ($Template) {
            $ProfileUnassignPayload.Filters = "=contains(TemplateName, '$($Template.Name)')"
        } elseif ($ProfileName) {
            $ProfileUnassignPayload.Filters = "=contains(ProfileName, '$($ProfileName)')"
        } else {
            throw [System.Exception] "You must specify one of the following parameters: -Device -Template -ProfileName"
        }

        if ($ForceReclaim) {
            $ProfileUnassignPayload.ForceReclaim = $true
        }

        $ProfileUnassignPayload = $ProfileUnassignPayload |ConvertTo-Json -Depth 6
        Write-Verbose $ProfileUnassignPayload
        Try { # Workaround to capture 400 (Bad Request) error when trying to unassign profile without target device found
            $ProfileUnassignResponse = Invoke-WebRequest -Uri $ProfileUnassignUrl -UseBasicParsing -Method Post -Body $ProfileUnassignPayload -ContentType $Type -Headers $Headers
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
            Write-Warning "No profiles unassigned"
        }
    }
    Catch {
        Resolve-Error $_
    }
}

End {}

}

