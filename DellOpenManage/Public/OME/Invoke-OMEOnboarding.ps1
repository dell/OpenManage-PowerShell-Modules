using module ..\..\Classes\Device.psm1

function Get-DeviceCredentialPayload($Name, $DeviceIds, $Username, [SecureString] $Password, $SetRedfish) {
    $Payload = '{
        "DeviceId": [10089],
        "CredentialProfile": {
          "CredentialProfileId": 0,
          "CredentialProfile":"{
            \"profileName\":\"\",
            \"profileDescription\":\"\",
            \"type\":\"MANAGEMENT\",
            \"credentials\":[{
                \"type\":\"WSMAN\",
                \"authType\":\"Basic\",
                \"modified\":false,
                \"credentials\": {
                    \"username\":\"\",
                    \"password\":\"\",
                    \"caCheck\":false,
                    \"cnCheck\":false,
                    \"port\":443,
                    \"retries\":3,
                    \"timeout\": 60,
                    \"isHttp\":false,
                    \"keepAlive\":false
                }
            }]
        }",
          "ProfileType": "2"
        }
      }' | ConvertFrom-Json

    $Payload.DeviceId = $DeviceIds
    #$Payload.JobName = $Name
    $PasswordText = (New-Object PSCredential "user", $Password).GetNetworkCredential().Password

    $CredentialProfile = $Payload.CredentialProfile.CredentialProfile | ConvertFrom-Json
    $CredentialProfile.credentials[0].credentials.'username' = $UserName
    $CredentialProfile.credentials[0].credentials.'password' = $PasswordText

    # Create REDFISH credential
    if ($SetRedfish) {
        $CredentialProfile.credentials += $CredentialProfile.credentials[0].PSObject.Copy()
        $CredentialProfile.credentials[1].type = "REDFISH"
    }

    $Payload.CredentialProfile.CredentialProfile = $CredentialProfile | ConvertTo-Json -Depth 6
    return $Payload
}

function Get-OnboardingJobPayload($Name, $TargetPayload, $SetTrapDestination, $SetCommunityString) {
    $Payload = '{
        "Id":0,
        "JobName":"OnBoarding Task",
        "JobDescription":"OnBoarding Task",
        "Schedule":"startnow",
        "State":"Enabled",
        "JobType": {
            "Id": 127,
            "Name": "Onboarding_Task",
            "Internal": false
        },
        "Targets":[
            {
                "Id": 25915,
                "Data": "",
                "TargetType":
                {
                "Id":1000,
                "Name":"DEVICE"
                }
            }
        ],
        "Params": [
            {
                "Key": "setCommunityString",
                "Value": "false"
            },
            {
                "Key": "setTrapDestination",
                "Value": "false"
            },
            {
                "Key": "operationName",
                "Value": "ONBOARDING"
            },
            {
                "Key": "connectionProfile",
                "Value": "0"
            }]
    }' | ConvertFrom-Json

    $Payload.Targets = $TargetPayload
    $Payload.JobName = $Name
    # Update Params
    for ($i = 0; $i -le $Payload.'Params'.Length; $i++) {
        if ($Payload.'Params'[$i].'Key' -eq 'setCommunityString') {
            if ($SetCommunityString) {
                $Payload.'Params'[$i].'Value' = "true"
            }
        }
        if ($Payload.'Params'[$i].'Key' -eq 'setTrapDestination') {
            if ($SetTrapDestination) {
                $Payload.'Params'[$i].'Value' = "true"
            }
        }
    }
    return $payload
}

function Invoke-OMEOnboarding {
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
    Update onboarding credentials on devices in OpenManage Enterprise
.DESCRIPTION
    Change onboarding credentials for device and submit an onboarding job to update device credentials in OME
.PARAMETER Name
    Name of the job
.PARAMETER Devices
    Array of type Device returned from Get-OMEDevice function.
.PARAMETER OnboardingUserName
    OnBoarding user name. The iDRAC user for server onboarding.
.PARAMETER OnboardingPassword
    OnBoarding password. The iDRAC user's password for server onboarding.
.PARAMETER SetRedfish
    Sets REDFISH as well as WSMAN onboarding credentials. Typically required devices discovered using OME 3.9 and newer. Use this parameter if you receive the error "Unable to complete the operation because the value provided for {0} is invalid."
.PARAMETER SetTrapDestination
    Set trap destination of iDRAC to OpenManage Enterprise 
.PARAMETER SetCommunityString
    Set Community String for trap destination from Application Settings > Incoming Alerts > SNMP Listener
.PARAMETER Wait
    Wait for job to complete
.PARAMETER WaitTime
    Time, in seconds, to wait for the job to complete
.INPUTS
    Device
.EXAMPLE
    Invoke-OMEOnboarding -Devices $("PowerEdge R640" | Get-OMEDevice -FilterBy "Model") -OnboardingUserName "admin" -OnboardingPassword $(ConvertTo-SecureString "calvin" -AsPlainText -Force)
    Change onboarding credentials
#>

[CmdletBinding()]
param(
    [Parameter(Mandatory=$false)]
    [String]$Name = "OnBoarding Task $((Get-Date).ToString('yyyyMMddHHmmss'))",

    [Parameter(Mandatory=$false, ValueFromPipeline)]
    [Device[]] $Devices,

    [Parameter(Mandatory)]
    [String]$OnboardingUserName,

    [Parameter(Mandatory)]
    [SecureString]$OnboardingPassword,

    [Parameter(Mandatory=$false)]
    [Switch]$SetRedfish,

    [Parameter(Mandatory=$false)]
    [Switch]$SetTrapDestination,

    [Parameter(Mandatory=$false)]
    [Switch]$SetCommunityString,

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
        $Type  = "application/json"
        $Headers = @{}
        $Headers."X-Auth-Token" = $SessionAuth.Token

        $DeviceIds = @()
        foreach ($Device in $Devices) {
            $DeviceIds += $Device.Id
        }
        if ($DeviceIds.Length -gt 0) {
            # First we need to update the device credentials. 
            $DeviceCredentialPayload = Get-DeviceCredentialPayload -DeviceIds $DeviceIds -Username $OnboardingUsername -Password $OnboardingPassword -SetRedfish $SetRedfish
            $DeviceCredentialURL = $BaseUri + "/api/DeviceService/Actions/DeviceService.AddCredentialToDevice"
            $DeviceCredentialPayload = $DeviceCredentialPayload | ConvertTo-Json -Depth 6
            #Write-Verbose $DeviceCredentialPayload 
            $DeviceCredentialJobResp = Invoke-WebRequest -Uri $DeviceCredentialURL -UseBasicParsing -Headers $Headers -ContentType $Type -Method POST -Body $DeviceCredentialPayload
            if ($DeviceCredentialJobResp.StatusCode -eq 204) {
                Write-Verbose "Updated device credentials on $($DeviceIds.Length) devices"

                # Next we need to submit an onboarding task to the job service. This isn't created automatically.
                $TargetPayload = Get-JobTargetPayload $DeviceIds
                $JobPayload = Get-OnboardingJobPayload -Name $Name -TargetPayload $TargetPayload -SetTrapDestination $SetTrapDestination -SetCommunityString $SetCommunityString
                $JobURL = $BaseUri + "/api/JobService/Jobs"
                $JobPayload = $JobPayload | ConvertTo-Json -Depth 6
                Write-Verbose $JobPayload
                $JobResp = Invoke-WebRequest -Uri $JobURL -UseBasicParsing -Headers $Headers -ContentType $Type -Method POST -Body $JobPayload
                if ($JobResp.StatusCode -eq 201) {
                    Write-Verbose "Job creation successful..."
                    $JobInfo = $JobResp.Content | ConvertFrom-Json
                    $JobId = $JobInfo.Id
                    Write-Verbose "Created job $($JobId) to configure onboarding credentials..."
                    if ($Wait) {
                        $JobStatus = $($JobId | Wait-OnJob -WaitTime $WaitTime)
                        return $JobStatus
                    } else {
                        return $JobId
                    }
                }
                else {
                    Write-Error "Job creation failed"
                }
            }
        } else {
            Write-Warning "No devices found"
            return "Completed"
        }
    }
    Catch {
        Resolve-Error $_
    }
}

End {}

}