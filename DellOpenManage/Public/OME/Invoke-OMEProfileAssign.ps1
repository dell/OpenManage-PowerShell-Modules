using module ..\..\Classes\Profile.psm1

function Invoke-OMEProfileAssign {
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
    [Parameter(Mandatory, ValueFromPipeline)]
    [Profile] $Profile,

    [Parameter(Mandatory)]
    [Int] $TargetId,

    [Parameter(Mandatory=$false)]
    [ValidateSet("CIFS", "NFS")]
    [String]$NetworkBootShareType,

    [Parameter(Mandatory=$false)]
    [String]$NetworkBootShareIpAddress,

    [Parameter(Mandatory=$false)]
    [String]$NetworkBootIsoPath,

    [Parameter(Mandatory=$false)]
    [Int]$NetworkBootIsoTimeout = 1,

    [Parameter(Mandatory=$false)]
    [String]$NetworkBootShareName,

    [Parameter(Mandatory=$false)]
    [String]$NetworkBootShareUser,

    [Parameter(Mandatory=$false)]
    [String]$NetworkBootShareWorkGroup,

    [Parameter(Mandatory=$false)]
    [SecureString]$NetworkBootSharePassword,

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

        $ProfileAssignUrl = $BaseUri + "/api/ProfileService/Actions/ProfileService.AssignProfile"
        $ProfileAssignPayload = '{
            "Id": 10079,
            "TargetId": 10087,
            "NetworkBootToIso": {
                "BootToNetwork": false,
                "ShareType": "CIFS",
                "ShareDetail": {
                    "IpAddress": "",
                    "ShareName": "",
                    "WorkGroup": "",
                    "User": "",
                    "Password": ""
                },
                "IsoPath": "abc.iso",
                "IsoTimeout": 4
            },
            "Options": {
                "ShutdownType": 0,
                "TimeToWaitBeforeShutdown": 300,
                "EndHostPowerState": 1,
                "StrictCheckingVlan": true
            },
            "Schedule": {
                "RunNow": true,
                "RunLater": false
            }
        }' | ConvertFrom-Json

        $ProfileAssignPayload.Id = $Profile.Id
        $ProfileAssignPayload.TargetId = $TargetId
        
        if ($TargetId -eq 0) { throw [System.ArgumentNullException] "TargetId" }
        if ($NetworkBootShareType -ne "") {
            # Manually throw exceptions when required parameters are empty since this is an optional subset of parameters
            if (!$NetworkBootShareIpAddress) { throw [System.ArgumentNullException] "NetworkBootShareIpAddress" }
            if (!$NetworkBootIsoPath) { throw [System.ArgumentNullException] "NetworkBootIsoPath" }
            if ($NetworkBootShareType -eq "CIFS"){
                if (!$NetworkBootShareName) { throw [System.ArgumentNullException] "NetworkBootShareName" }
                if (!$NetworkBootShareUser) { throw [System.ArgumentNullException] "NetworkBootShareUser" }
                if (!$NetworkBootSharePassword) { throw [System.ArgumentNullException] "NetworkBootSharePassword" }
            }
            $ProfileAssignPayload.NetworkBootToIso.BootToNetwork = $true
            $ProfileAssignPayload.NetworkBootToIso.ShareType = $NetworkBootShareType
            $ProfileAssignPayload.NetworkBootToIso.IsoPath = $NetworkBootIsoPath
            $ProfileAssignPayload.NetworkBootToIso.IsoTimeout = $NetworkBootIsoTimeout
            $ProfileAssignPayload.NetworkBootToIso.ShareDetail.IpAddress = $NetworkBootShareIpAddress
            $ProfileAssignPayload.NetworkBootToIso.ShareDetail.ShareName = $NetworkBootShareName
            $ProfileAssignPayload.NetworkBootToIso.ShareDetail.User = $NetworkBootShareUser
            $ProfileAssignPayload.NetworkBootToIso.ShareDetail.WorkGroup = $NetworkBootShareWorkGroup
            if ($null -ne $NetworkBootSharePassword) {
                $NetworkBootSharePasswordText = (New-Object PSCredential "user", $NetworkBootSharePassword).GetNetworkCredential().Password
                $ProfileAssignPayload.NetworkBootToIso.ShareDetail.Password = $NetworkBootSharePasswordText
            }
        }

        $ProfileAssignPayload = $ProfileAssignPayload |ConvertTo-Json -Depth 6
        Write-Verbose $ProfileAssignPayload
        $ProfileAssignResponse = Invoke-WebRequest -Uri $ProfileAssignUrl -UseBasicParsing -Method Post -Body $ProfileAssignPayload -ContentType $Type -Headers $Headers
        if ($ProfileAssignResponse.StatusCode -eq 200) {
            $ProfileAssignContent = $ProfileAssignResponse.Content | ConvertFrom-Json
            $JobId = $ProfileAssignContent
            if ($JobId -ne 0) {
                Write-Verbose "Created job $($JobId) to assign profiles..."
                if ($Wait) {
                    $JobStatus = $($JobId | Wait-OnJob -WaitTime $WaitTime)
                    return $JobStatus
                } else {
                    return $JobId
                }
            } else {
                Write-Warning "No profiles assigned"
            }
        } else {
            Write-Error "Failed to assign profiles"
        }
        return $ProfileAssignResponse
    }
    Catch {
        Resolve-Error $_
    }
}

End {}

}

