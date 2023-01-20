using module ..\..\Classes\Domain.psm1

function Get-BackupJobPayload($Name, $Description, $Share, $SharePath, $ShareType, $BackupFile, $DeviceId, [SecureString] $EncryptionPassword, $UserName, [SecureString] $Password, $IncludePw, $IncludeCertificates, $ScheduleCron) {
    $Payload = '{
        "Id": 0,
        "JobName": "Backup Task",
        "JobDescription": "Create a Backup of the chassis",
        "Schedule": "startnow",
        "State": "Enabled",
        "Targets": [],
        "Params": [ 
            {
                "Key": "includePasswords",
                "Value": "false"
            },
            {
                "Key": "includeCertificates",
                "Value": "false"
            },
            {
                "Key": "shareName",
                "Value": "Folder_Name"
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
                "Key": "shareAddress",
                "Value": "<IP Address>"
            },
            {
                "Key": "device_id",
                "Value": "<Chassis ID>"
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
            },
            {
                "Key": "verifyCert",
                "Value": "false"
            }               
        ],
        "JobType": {
            "Id": 106,
            "Name": "Appliance_Backup_Task",
            "Internal": false
        }
    }' | ConvertFrom-Json

    $Payload.JobName = $Name
    $Payload.JobDescription = $Description
    $Payload.Schedule = $ScheduleCron
    $ParamsHashValMap = @{
        "shareName" = $SharePath
        "backup_filename" = $BackupFile
        "shareType" = $ShareType
        "shareAddress" = $Share
        "device_id" = $DeviceId.ToString()
        "userName" =  $UserName
        "password" = if ($Password) {
            $PasswordText = (New-Object PSCredential "user", $Password).GetNetworkCredential().Password
            $PasswordText
        }
        "encryption_password" = if ($EncryptionPassword) {
            $EncryptionPasswordText = (New-Object PSCredential "user", $EncryptionPassword).GetNetworkCredential().Password
            $EncryptionPasswordText
        }
        "includePasswords" = $(if ($IncludePw) { "true" } else { "false"})
        "includeCertificates" = $(if ($IncludeCertificates) { "true" } else { "false"})
    }

    # Update Params from ParamsHashValMap
    for ($i = 0; $i -le $Payload.'Params'.Length; $i++) {
        if ($ParamsHashValMap.Keys -Contains ($Payload.'Params'[$i].'Key')) {
            $value = $Payload.'Params'[$i].'Key'
            $Payload.'Params'[$i].'Value' = $ParamsHashValMap.$value
        }
    }
    return $payload
} 

function Invoke-OMEApplianceBackup {
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
    Appliance backup to file on network share. Restore must be performed in OME-M at this time.
.DESCRIPTION
    Backup appliance to a file on a network share
.PARAMETER Name
    Name of the job
.PARAMETER Description
    Job description
.PARAMETER IncludePw
    Include passwords in backup
.PARAMETER IncludeCertificates
    Include certificates in backup
.PARAMETER Share
    Share host IP address or hostname
.PARAMETER SharePath
    Share directory path
.PARAMETER ShareType
    Share type ("NFS", Default="CIFS", "HTTP", "HTTPS")
.PARAMETER BackupFile
    Backup file name, .bin is automatically appended to file name. Default=BACKUP_$((Get-Date).ToString('yyyyMMddHHmmss'))
.PARAMETER Chassis
    Lead or standalone chassis to backup or restore to. Object of type Domain returned from Get-OMEMXDomain
.PARAMETER UserName
    Used for CIFS . Username to connect to share
.PARAMETER Password
    Used for CIFS . Password to connect to share
.PARAMETER EncryptionPassword
    Password used to encrypt backup
.PARAMETER ScheduleCron
    Specify cron string to schedule the job in the future. Leave out to run now.
.PARAMETER Wait
    Wait for job to complete
.PARAMETER WaitTime
    Time, in seconds, to wait for the job to complete
.INPUTS
    None
.EXAMPLE
    Invoke-OMEApplianceBackup -Chassis @("LEAD" | Get-OMEMXDomain | Select-Object -First 1) -Share "192.168.1.100" -SharePath "/SHARE" -ShareType "CIFS" -UserName "Administrator" -Password $(ConvertTo-SecureString 'calvin' -AsPlainText -Force) -BackupFile "BACKUP_$((Get-Date).ToString('yyyyMMddHHmmss'))" -IncludePw -IncludeCertificates -EncryptionPassword $(ConvertTo-SecureString 'nkQ*DTrNK7$b' -AsPlainText -Force) -Wait -Verbose

    Backup chassis to CIFS share now
.EXAMPLE
    Invoke-OMEApplianceBackup -Chassis  @("LEAD" | Get-OMEMXDomain | Select-Object -First 1) -Share "192.168.1.100" -SharePath "/mnt/data/backup" -ShareType "NFS" -BackupFile "BACKUP_$((Get-Date).ToString('yyyyMMddHHmmss'))" -ScheduleCron '0 0 0 ? * sun *' -IncludePw -IncludeCertificates -EncryptionPassword $(ConvertTo-SecureString 'nkQ*DTrNK7$b' -AsPlainText -Force) -Wait -Verbose
    
    Backup chassis to NFS share on schedule
#>

[CmdletBinding()]
param(
    [Parameter(Mandatory=$false)]
    [String]$Name = "Appliance Backup Task $((Get-Date).ToString('yyyyMMddHHmmss'))",

    [Parameter(Mandatory=$false)]
    [String]$Description = "Create a backup of the appliance",

    [Parameter(Mandatory=$false)]
    [Switch]$IncludePw,

    [Parameter(Mandatory=$false)]
    [Switch]$IncludeCertificates,
    
    [Parameter(Mandatory)]
    [String]$Share,

    [Parameter(Mandatory)]
    [String]$SharePath,

    [Parameter(Mandatory=$false)]
    [ValidateSet("NFS", "CIFS", "HTTP", "HTTPS")]
    [String]$ShareType = "CIFS",

    [Parameter(Mandatory=$false)]
    [String]$BackupFile = "BACKUP_$((Get-Date).ToString('yyyyMMddHHmmss'))",

    [Parameter(Mandatory)]
    [Domain[]] $Chassis,

    [Parameter(Mandatory=$false)]
    [String]$UserName,

    [Parameter(Mandatory=$false)]
    [SecureString]$Password,    

    [Parameter(Mandatory)]
    [SecureString]$EncryptionPassword,

    [Parameter(Mandatory=$false)]
    [String]$ScheduleCron = "startnow",

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

        if ($ShareType -eq "CIFS") {
            if ($null -eq $Username) { throw [System.ArgumentNullException] "Username required for CIFS" }
            if ($null -eq $Password) { throw [System.ArgumentNullException] "Password required for CIFS" }
        }

        $DeviceIds = @()
        if ($null -ne $Chassis.DeviceId -and $Chassis.DeviceId -ne 0) {
            $DeviceIds += $Chassis.DeviceId
            $JobPayload = Get-BackupJobPayload -Name $Name -Description $Description `
                -Share $Share -SharePath $SharePath -ShareType $ShareType `
                -BackupFile $BackupFile -DeviceId $Chassis.DeviceId -EncryptionPassword $EncryptionPassword `
                -UserName $UserName -Password $Password -ScheduleCron $ScheduleCron `
                -IncludePw $IncludePw -IncludeCertificates $IncludeCertificates
            
            $JobURL = $BaseUri + "/api/JobService/Jobs"
            $JobPayload = $JobPayload | ConvertTo-Json -Depth 6
            Write-Verbose $JobPayload
            $JobResp = Invoke-WebRequest -Uri $JobURL -UseBasicParsing -Headers $Headers -ContentType $Type -Method POST -Body $JobPayload
            if ($JobResp.StatusCode -eq 201) {
                Write-Verbose "Job creation successful..."
                $JobInfo = $JobResp.Content | ConvertFrom-Json
                $JobId = $JobInfo.Id
                Write-Verbose "Created job $($JobId) for application backup..."
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