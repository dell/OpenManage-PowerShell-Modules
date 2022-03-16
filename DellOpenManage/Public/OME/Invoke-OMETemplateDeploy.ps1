using module ..\..\Classes\Template.psm1
using module ..\..\Classes\Device.psm1

function Set-AssignedIdentity($BaseUri, $Type, $Headers, $TemplateId, $TargetIds) {
    $Payload = '{
        "TemplateId" : 13,
        "BaseEntityIds" : []
    }'
    $TemplateUrl = $BaseUri + "/api/TemplateService/Actions/TemplateService.GetAssignedIdentities"
    $Payload = $Payload|ConvertFrom-Json
    $Payload.TemplateId = $TemplateId
    $Payload.BaseEntityIds = @()
    $Payload.BaseEntityIds = $TargetIds
    $AssignedIdentitiesPayload = $Payload|ConvertTo-Json -Depth 6
    $AssignedIdentitiesResponse = Invoke-WebRequest -Uri $TemplateUrl -Method Post -Body $AssignedIdentitiesPayload -ContentType $Type -Headers $Headers
    if ( $AssignedIdentitiesResponse.StatusCode -eq 200) {
        $AssignIdentitiesInfo = $AssignedIdentitiesResponse.Content | ConvertFrom-Json
        $AssignIdentitiesInfo = $AssignIdentitiesInfo |ConvertTo-Json -Depth 6
        Write-Verbose $AssignIdentitiesInfo
    }
    else {
        Write-Warning "unable to get assigned identities"
    }
}

function Invoke-OMETemplateDeploy {
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
    Deploy template to device in OpenManage Enterprise
.DESCRIPTION
    This will attempt to reboot the server to apply the template. iDRAC and EventFilter attributes should not cause a reboot but proceed with caution.
    As of OME 3.4 only one template can be associated to a device. However, you can deploy a template to multiple devices.
.PARAMETER Template
    Object of type Template returned from Get-OMETemplate function
.PARAMETER Devices
    Array of type Device returned from Get-OMEDevice function
.PARAMETER ForceHostReboot
    Forcefully reboot the host OS if the graceful reboot fails. *This will NOT prevent a reboot of the host, just a forced reboot.
    A soft reboot will be initiated upon template deploy.
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
    Template
.EXAMPLE
    "TestTemplate" | Get-OMETemplate | Invoke-OMETemplateDeploy -Devices $("37KP0ZZ" | Get-OMEDevice) -Wait

    Deploy template
.EXAMPLE
    "TestTemplate" | Get-OMETemplate | Invoke-OMETemplateDeploy -Devices $("37KP0ZZ" | Get-OMEDevice) -NetworkBootShareType "NFS" -NetworkBootShareIpAddress "192.168.1.100" -NetworkBootIsoPath "/mnt/data/iso/CentOS7-Unattended.iso" -Wait -Verbose

    Deploy template and boot to network ISO over NFS
.EXAMPLE
    "TestTemplate" | Get-OMETemplate | Invoke-OMETemplateDeploy -Devices $("37KP0ZZ" | Get-OMEDevice) -NetworkBootShareType "CIFS" -NetworkBootShareIpAddress "192.168.1.101" -NetworkBootIsoPath "/Share/ISO/CentOS7-Unattended.iso" -NetworkBootShareUser "Administrator" -NetworkBootSharePassword $(ConvertTo-SecureString 'calvin' -AsPlainText -Force) -NetworkBootShareName "Share" -Wait -Verbose
    
    Deploy template and boot to network ISO over CIFS
#>

[CmdletBinding()]
param(
    [Parameter(Mandatory, ValueFromPipeline)]
    [Template] $Template,

    [Parameter(Mandatory)]
    [Device[]] $Devices,

    [Parameter(Mandatory=$false)]
    [Switch]$ForceHostReboot,

    [Parameter(Mandatory=$false)]
    [ValidateSet("CIFS", "NFS")]
    [String]$NetworkBootShareType,

    [Parameter(Mandatory=$false)]
    [String]$NetworkBootShareIpAddress,

    [Parameter(Mandatory=$false)]
    [String]$NetworkBootIsoPath,

    [Parameter(Mandatory=$false)]
    [String]$NetworkBootIsoTimeout = 1,

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

        $TemplateDeployUrl = $BaseUri + "/api/TemplateService/Actions/TemplateService.Deploy"
        # Functionality removed in OME 3.3+ waiting for it to be reimplemented
        $TemplateDeployPayload = '{
            "Id": 11,
            "TargetIds": [5514],
            "Attributes": [],
            "Options": {
                "ShutdownType": 0,
                "TimeToWaitBeforeShutdown": 300,
                "EndHostPowerState": 1
            },
            "NetworkBootIsoModel": {
                "BootToNetwork": false,
                "ShareType": "CIFS",
                "IsoPath": "bootToIsoPath.iso",
                "IsoTimeout": 1,
                "ShareDetail": {
                    "IpAddress": "1.2.3.4",
                    "ShareName": "1.2.3.4",
                    "WorkGroup": "workGroup",
                    "User": "bootToIsoUsername",
                    "Password": "bootToIsoPassword"
                }
            },
            "Schedule": {
                "RunNow": true,
                "RunLater": false
            }
        }'
        $TemplateDeployPayload = $TemplateDeployPayload | ConvertFrom-Json
        $TemplateDeployPayload.Id = $Template.Id
        # The ShutdownType is set to force by default
        if ($ForceHostReboot) {
            $TemplateDeployPayload.Options.ShutdownType = 0
        } else {
            $TemplateDeployPayload.Options.ShutdownType = 1
        }
        # Functionality removed in OME 3.3+ waiting for it to be reimplemented
        if ($NetworkBootShareType -ne "") {
            # Manually throw exceptions when required parameters are empty since this is an optional subset of parameters
            if (!$NetworkBootShareIpAddress) { throw [System.ArgumentNullException] "NetworkBootShareIpAddress" }
            if (!$NetworkBootIsoPath) { throw [System.ArgumentNullException] "NetworkBootIsoPath" }
            if ($NetworkBootShareType -eq "CIFS"){
                if (!$NetworkBootShareName) { throw [System.ArgumentNullException] "NetworkBootShareName" }
                if (!$NetworkBootShareUser) { throw [System.ArgumentNullException] "NetworkBootShareUser" }
                if (!$NetworkBootSharePassword) { throw [System.ArgumentNullException] "NetworkBootSharePassword" }
            }
            $TemplateDeployPayload.NetworkBootIsoModel.BootToNetwork = $true
            $TemplateDeployPayload.NetworkBootIsoModel.ShareType = $NetworkBootShareType
            $TemplateDeployPayload.NetworkBootIsoModel.IsoPath = $NetworkBootIsoPath
            $TemplateDeployPayload.NetworkBootIsoModel.IsoTimeout = $NetworkBootIsoTimeout
            $TemplateDeployPayload.NetworkBootIsoModel.ShareDetail.IpAddress = $NetworkBootShareIpAddress
            $TemplateDeployPayload.NetworkBootIsoModel.ShareDetail.ShareName = $NetworkBootShareName
            $TemplateDeployPayload.NetworkBootIsoModel.ShareDetail.User = $NetworkBootShareUser
            $TemplateDeployPayload.NetworkBootIsoModel.ShareDetail.WorkGroup = $NetworkBootShareWorkGroup
            $NetworkBootSharePasswordText = (New-Object PSCredential "user", $NetworkBootSharePassword).GetNetworkCredential().Password
            $TemplateDeployPayload.NetworkBootIsoModel.ShareDetail.Password = $NetworkBootSharePasswordText
        }
        # Build TargetIds array from Devices
        $DeviceIds = @()
        foreach ($Device in $Devices) {
            $DeviceIds += $Device.Id
        }
        $TemplateDeployPayload.TargetIds = $DeviceIds
        $TemplateDeployPayload = $TemplateDeployPayload |ConvertTo-Json -Depth 6
        #Write-Verbose $TemplateDeployPayload
        # Associate Identity Pool to Template
        #$AssignIdentityResponse = Set-IdentitiesToTarget $IpAddress $Type $Headers $IdentityPoolId $TemplateId

        $DeployTemplateResponse = Invoke-WebRequest -Uri $TemplateDeployUrl -Method Post -Body $TemplateDeployPayload -ContentType $Type -Headers $Headers
        if ($DeployTemplateResponse.StatusCode -eq 200) {
            $DeployTemplateContent = $DeployTemplateResponse.Content | ConvertFrom-Json
            $JobId = $DeployTemplateContent
            if ($JobId -ne 0) {
                Write-Verbose "Created job $($JobId) to deploy template..."
                if ($Wait) {
                    $JobStatus = $($JobId | Wait-OnJob -WaitTime $WaitTime)
                    return $JobStatus
                } else {
                    return $JobId
                }
                if ($Template.HasIdentityAttributes) {
                    # Reserve virtual identities
                    Write-Verbose "Checking assigned identities........."
                    Start-Sleep -Seconds 30
                    Set-AssignedIdentity -BaseUri $BaseUri -Type $Type -Headers $Headers -TemplateId $Template.Id -TargetIds $DeviceIds
                }
            } else {
                Write-Warning "Failed to deploy template. Only 1 template can be associated to a device at a time. Check Audit Log and Configuration > Profiles"
            }
        } else {
            Write-Error "Failed to deploy template"
        }
        return $DeployResponse
    }
    Catch {
        Resolve-Error $_
    }
}

End {}

}

