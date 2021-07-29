using module ..\..\Classes\Device.psm1
using module ..\..\Classes\Group.psm1

function Edit-OMESupportAssistGroup {
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
    Edit Support Assist group in OpenManage Enterprise
.DESCRIPTION

.PARAMETER Group
    Object of type Group returned from Get-OMEGroup function
.PARAMETER Name
    Name of group
.PARAMETER Description
    Description of group
.PARAMETER Devices
    Array of type Device returned from Get-OMEDevice function.
.PARAMETER Mode
    Method by which devices are added or removed (Default="Append", "Remove")
.INPUTS
    Group
.EXAMPLE
    Get-OMEGroup "Test Group 01" | Edit-OMEGroup
    Force group update. This is a workaround that will trigger baselines to update devices in the associated group.
.EXAMPLE
    Get-OMEGroup "Test Group 01" | Edit-OMEGroup -Name "Test Group 001" -Description "This is a new group"
    Edit group name and description
.EXAMPLE
    Get-OMEGroup "Test Group 01" | Edit-OMEGroup -Devices $("PowerEdge R640" | Get-OMEDevice -FilterBy "Model")
    Add devices to group
.EXAMPLE
    Get-OMEGroup "Test Group 01" | Edit-OMEGroup -Mode "Remove" -Devices $("PowerEdge R640" | Get-OMEDevice -FilterBy "Model")
    Remove devices from group
#>

[CmdletBinding()]
param(
    [Parameter(Mandatory, ValueFromPipeline)]
    [Group]$Group,

    [Parameter(Mandatory=$false)]
    [String]$EditGroup,

    [Parameter(Mandatory=$false)]
    [Device[]] $Devices,

    [Parameter(Mandatory=$false)]
	[ValidateSet("Append", "Remove")]
    [String] $Mode = "Append"
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
        $GroupURL = $BaseUri + "/api/SupportAssistService/Actions/SupportAssistService.CreateOrUpdateGroup"
        $ContentType = "application/json"
        $Headers = @{}
        $Headers."X-Auth-Token" = $SessionAuth.Token

        # Update devices in group
        if ($Devices.Length -gt 0) {
            $GroupDeviceURL = $BaseUri + "/api/SupportAssistService/Actions/SupportAssistService.AddMemberDevices"
            $GroupDevicePayload = '{
                "GroupId": 0,
                "MemberDeviceIds": []
            }' | ConvertFrom-Json
            # Build list of device ids in group currently
            $CurrentDeviceIds = @()
            $CurrentDevices = $Group | Get-OMEDevice
            foreach ($Device in $CurrentDevices) {
                $CurrentDeviceIds += $Device.Id
            }

            # Build list of device ids to be updated
            $DeviceIds = @()
            if ($Mode.ToLower() -eq "append") {
                foreach ($Device in $Devices) {
                    if ($CurrentDeviceIds -notcontains $Device.Id) {
                        $DeviceIds += $Device.Id
                    }
                }
            } elseif ($Mode.ToLower() -eq "remove") {
                $GroupDeviceURL = $BaseUri + "/api/SupportAssistService/Actions/SupportAssistService.RemoveMemberDevices"
                foreach ($Device in $Devices) {
                    $DeviceIds += $Device.Id
                }
            }

            $GroupDevicePayload.MemberDeviceIds = $DeviceIds
            $GroupDevicePayload.GroupId = $Group.Id
            $GroupDevicePayload = $GroupDevicePayload | ConvertTo-Json -Depth 6
            Write-Verbose $GroupDevicePayload
            if ($DeviceIds.Length -gt 0) {
                $GroupDeviceResponse = Invoke-WebRequest -Uri $GroupDeviceURL -UseBasicParsing -Headers $Headers -ContentType $ContentType -Method POST -Body $GroupDevicePayload
                Write-Verbose "Updating group devices..."
                if ($GroupDeviceResponse.StatusCode -eq 200 -or $GroupDeviceResponse.StatusCode -eq 202) {
                    Write-Verbose "Group device update successful..."
                }
                else {
                    Write-Error "Group device update failed..."
                }
            } else {
                Write-Verbose "No devices added/removed from group..."
            }
        }

        # Update group
        if ($PSBoundParameters.ContainsKey('EditGroup')) {
            if (-not $(Confirm-PathIsValid -InputFilePath $EditGroup)) {
                Write-Error "File not found $($EditGroup)"
                Exit
            }

            $GroupPayload = $(Get-Content -Path $EditGroup) | ConvertFrom-Json
            $GroupPayload.Id = $Group.Id
            $GroupPayload = $GroupPayload | ConvertTo-Json -Depth 6
            Write-Verbose $GroupPayload

            $GroupResponse = Invoke-WebRequest -Uri $GroupURL -UseBasicParsing -Headers $Headers -ContentType $ContentType -Method POST -Body $GroupPayload
            Write-Verbose "Updating group..."
            if ($GroupResponse.StatusCode -eq 200 -or $GroupResponse.StatusCode -eq 202) {
                Write-Verbose "Group update successful!"
                return $GroupResponse.Content | ConvertFrom-Json
            }
            else {
                Write-Error "Group update failed..."
            }
        }

    }
    Catch {
        Resolve-Error $_
    }
}

End {}

}

