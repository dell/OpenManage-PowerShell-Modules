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
    Assign profile to device in OpenManage Enterprise
.DESCRIPTION
    This action will assign the profile to a chassis slot or directly to a device. 
.PARAMETER ServerProfile
    Object of type Profile returned from Get-OMEProfile function
.PARAMETER TargetId
    Integer representing the SlotId for Slot based deployment or DeviceId for device based deployment.
.PARAMETER AttachAndApply
    Immediately Apply To Compute Sleds. Only applies to Slot based assignments. ***This will force a reseat of the sled***
.PARAMETER NetworkBootShareType
    Share type ("NFS", "CIFS")
.PARAMETER NetworkBootShareIpAddress
    IP Address of the share server
.PARAMETER NetworkBootIsoPath
    Full path to the ISO
.PARAMETER NetworkBootIsoTimeout
    Lifecycle Controller timeout setting (Default=1) Hour
.PARAMETER NetworkBootShareName
    Share name (CIFS Only)
.PARAMETER NetworkBootShareUser
    Share user (CIFS Only)
.PARAMETER NetworkBootShareWorkGroup
    Share workgroup (CIFS Only)
.PARAMETER NetworkBootSharePassword
    Share password (CIFS Only)
.PARAMETER Wait
    Wait for job to complete
.PARAMETER WaitTime
    Time, in seconds, to wait for the job to complete
.INPUTS
    [Profile] $ServerProfile
.EXAMPLE
    See README for examples
#>

[CmdletBinding()]
param(
    [Parameter(Mandatory, ValueFromPipeline)]
    [Profile] $ServerProfile,

    [Parameter(Mandatory)]
    [Int] $TargetId,

    [Parameter(Mandatory=$false)]
    [Switch]$AttachAndApply,

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
            "AttachAndApply": false,
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

        $ProfileAssignPayload.Id = $ServerProfile.Id
        $ProfileAssignPayload.TargetId = $TargetId

        if ($AttachAndApply) {
            $ProfileAssignPayload.AttachAndApply = $true
        }
        
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
        if ($ProfileAssignResponse.StatusCode -in (200,201)) {
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

