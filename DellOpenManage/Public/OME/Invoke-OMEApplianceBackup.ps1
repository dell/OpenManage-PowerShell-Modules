using module ..\..\Classes\Domain.psm1

function Get-BackupJobPayload($Name, $Description, $Share, $SharePath, $ShareType, $BackupFile, $DeviceId, [SecureString] $EncryptionPassword, $UserName, [SecureString] $Password) {
    $Payload = '{
        "Id": 0,
        "JobName": "Backup Task",
        "JobDescription": "Create a Backup of the chassis",
        "Schedule": "startnow",
        "State": "Enabled",
        "Targets": [],
        "Params": [
            {
                "Key": "shareName",
                "Value": "Floder_Name"
            },
            {
                "Key": "backup_filename",
                "Value": "backup file name.bin"
            },
            {
                "Key": "shareType",
                "Value": "CIFS/NFS"
            },
            {
                "Key": "device_id",
                "Value": "<Chassis ID>"
            },
            {
                "Key": "shareAddress",
                "Value": "<IP Address>"
            },
            {
                "Key": "encryption_password",
                "Value": "<encryption password>"
            },
            {
                "Key": "userName",
                "Value": "<Share username>"
            },
            {
                "Key": "password",
                "Value": "<Share user password>"
            }
        ],
        "JobType": {
        "Id": 21,
        "Name": "Appliance_Backup_Task",
        "Internal": false
        }
    }' | ConvertFrom-Json

    $Payload.JobName = $Name
    $Payload.JobDescription = $Description
    # Update Params
    for ($i = 0; $i -le $Payload.'Params'.Length; $i++) {
        if ($Payload.'Params'[$i].'Key' -eq 'shareName') {
            if ($SharePath) {
                $Payload.'Params'[$i].'Value' = $SharePath
            }
        }
        if ($Payload.'Params'[$i].'Key' -eq 'backup_filename') {
            if ($BackupFile) {
                $Payload.'Params'[$i].'Value' = $BackupFile
            }
        }
        if ($Payload.'Params'[$i].'Key' -eq 'shareType') {
            if ($ShareType) {
                $Payload.'Params'[$i].'Value' = $ShareType
            }
        }
        if ($Payload.'Params'[$i].'Key' -eq 'device_id') {
            if ($DeviceId) {
                $Payload.'Params'[$i].'Value' = $DeviceId
            }
        }
        if ($Payload.'Params'[$i].'Key' -eq 'shareAddress') {
            if ($Share) {
                $Payload.'Params'[$i].'Value' = $Share
            }
        }
        if ($Payload.'Params'[$i].'Key' -eq 'encryption_password') {
            if ($EncryptionPassword) {
                $EncryptionPasswordText = (New-Object PSCredential "user", $EncryptionPassword).GetNetworkCredential().Password
                $Payload.'Params'[$i].'Value' = $EncryptionPasswordText
            }
        }
        if ($Payload.'Params'[$i].'Key' -eq 'userName') {
            if ($UserName) {
                $Payload.'Params'[$i].'Value' = $UserName
            }
        }
        if ($Payload.'Params'[$i].'Key' -eq 'password') {
            if ($Password) {
                $PasswordText = (New-Object PSCredential "user", $Password).GetNetworkCredential().Password
                $Payload.'Params'[$i].'Value' = $PasswordText
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
    [String]$Name = "Appliance Backup Task $((Get-Date).ToString('yyyyMMddHHmmss'))",

    [Parameter(Mandatory=$false)]
    [String]$Description = "Create a backup of the appliance",

    [Parameter(Mandatory)]
    [String]$Share,

    [Parameter(Mandatory)]
    [String]$SharePath,

    [Parameter(Mandatory=$false)]
    [ValidateSet("NFS", "CIFS", "HTTP", "HTTPS")]
    [String]$ShareType = "CIFS",

    [Parameter(Mandatory=$false)]
    [String]$BackupFile = "BACKUP_$((Get-Date).ToString('yyyyMMddHHmmss')).bin",

    [Parameter(Mandatory=$false, ValueFromPipeline)]
    [Domain] $Chassis,

    [Parameter(Mandatory=$false)]
    [String]$Username,

    [Parameter(Mandatory=$false)]
    [SecureString]$Password,    

    [Parameter(Mandatory)]
    [SecureString]$EncryptionPassword,

    [Parameter(Mandatory=$false)]
    [Switch]$Wait,

    [Parameter(Mandatory=$false)]
    [int]$WaitTime = 80
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

        if ($Chassis.DeviceId -ne $null -and $Chassis.DeviceId -ne 0) {
            $JobPayload = Get-BackupJobPayload -Name $Name -Description $Description -Share $Share -SharePath $SharePath -ShareType `
                $ShareType -BackupFile $BackupFile DeviceId $Chassis.DeviceId -EncryptionPassword $EncryptionPassword -UserName $UserName -Password $Password
            $JobURL = $BaseUri + "/api/JobService/Jobs"
            $JobPayload = $JobPayload | ConvertTo-Json -Depth 6
            Write-Verbose $JobPayload
            $JobResp = Invoke-WebRequest -Uri $JobURL -UseBasicParsing -Headers $Headers -ContentType $Type -Method POST -Body $JobPayload
            if ($JobResp.StatusCode -eq 201) {
                Write-Verbose "Job creation successful..."
                $JobInfo = $JobResp.Content | ConvertFrom-Json
                $JobId = $JobInfo.Id
                Write-Verbose "Created job $($JobId) to create appliance backup..."
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