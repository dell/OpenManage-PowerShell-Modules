


function Get-iDRACFirmwarePayload($UpdateSchedule, $Source, $SourcePath, $CatalogFile, $DomainName, $RepositoryType, $RepositoryUserName, [securestring] $RepositoryPassword, $CheckCertificate) {
    $Payload = '{
        "ApplyUpdate": "False",
        "CatalogFile": "Catalog.xml",
        "IPAddress": "",
        "IgnoreCertWarning": "On",
        "Mountpoint": "",
        "RebootNeeded": false,
        "ShareName": "",
        "ShareType": "",
    }' | ConvertFrom-Json

    if ($UpdateSchedule -eq "RebootNow") {
        $Payload.ApplyUpdate = "True"
        $Payload.RebootNeeded = $true
    } elseif ($UpdateSchedule -eq "StageForNextReboot") {
        $Payload.ApplyUpdate = "True"
        $Payload.RebootNeeded = $false
    } elseif ($UpdateSchedule -eq "Preview") {
        $Payload.ApplyUpdate = "False"
        $Payload.RebootNeeded = $false
    } 

    if ($CheckCertificate) {
        $Payload.IgnoreCertWarning = "Off"
    } else {
        $Payload.IgnoreCertWarning = "On"
    }

    $Payload.CatalogFile = $CatalogFile
    $Payload.ShareType = $RepositoryType # CIFS|FTP|HTTP|HTTPS|NFS|TFTP
    $Payload.IPAddress = $Source
    $Payload.ShareName = $SourcePath
    if ($RepositoryType -eq "CIFS") {
        #$Payload.Mountpoint = $SourcePath # CIFS
        $Payload | Add-Member -NotePropertyName UserName -NotePropertyValue $RepositoryUserName
        $RepositoryPasswordText = (New-Object PSCredential "user", $RepositoryPassword).GetNetworkCredential().Password
        $Payload | Add-Member -NotePropertyName Password -NotePropertyValue $RepositoryPasswordText
        $Payload | Add-Member -NotePropertyName Workgroup -NotePropertyValue $DomainName
    }
    #$Payload.ProxyPasswd = "",
    #$Payload.ProxyPort = "Off", #DefaultProxy|Off|ParametersProxy
    #$Payload.ProxyServer = "",
    #$Payload.ProxySupport = "",
    #$Payload.ProxyType = "", # HTTP|SOCKS
    #$Payload.ProxyUname = "",

    return $payload
}

function Get-iDRACFirmwareCompliance () {
    [CmdletBinding()]
    param(
        [Parameter(Mandatory)]
        [String]$BaseUri,

        [Parameter(Mandatory)]
        [pscredential]$Credentials
    )

    $Payload = @{} | ConvertTo-Json -Compress
    $ComplianceURL = $BaseUri + "/Dell/Systems/System.Embedded.1/DellSoftwareInstallationService/Actions/DellSoftwareInstallationService.GetRepoBasedUpdateList"
    $ComplianceResp = Invoke-WebRequest -Uri $ComplianceURL -Credential $Credentials -Method POST -Body $Payload -ContentType 'application/json' -Headers @{"Accept"="application/json"}
    if ($ComplianceResp.StatusCode -eq 200 -or $ComplianceResp.StatusCode -eq 202) {
        $ComplianceInfo = $ComplianceResp.Content | ConvertFrom-Json
        [xml]$xmlAttr = $ComplianceInfo.PackageList
        $props = @()
        $xmlAttr.CIM.MESSAGE.SIMPLEREQ."VALUE.NAMEDINSTANCE" | ForEach-Object {
            $_.INSTANCENAME | ForEach-Object {
                $instance = @()
                $_.PROPERTY | ForEach-Object {
                    $Name = $_ | Select-Object -ExpandProperty NAME
                    $Value = $_.VALUE
                    $instance += @{
                        $Name = $Value
                    }
                }
                $props += $instance
            }
        }
        #Write-Host $($props | Format-Table | Out-String)
        return $props
    }
    else {
        Write-Error "Update job creation failed"
    }
}

function Get-iDRACCredential($UserName, [SecureString] $Password) {
    return New-Object System.Management.Automation.PSCredential($UserName, $Password)
}


function Update-iDRACFirmware {
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
    Update firmware on devices in OpenManage Enterprise
.DESCRIPTION
    This will use an existing firmware baseline to submit a Job that updates firmware on a set of devices.
.PARAMETER Name
    Name of the firmware update job
.PARAMETER Baseline
    Array of type Baseline returned from Get-Baseline function
.PARAMETER UpdateSchedule
    Determines when the updates will be performed. (Default="Preview", "RebootNow", "ScheduleLater", "StageForNextReboot")
.PARAMETER UpdateAction
    Determines what type of updates will be performed. (Default="Upgrade", "Downgrade", "All")
.PARAMETER Wait
    Wait for job to complete
.PARAMETER WaitTime
    Time, in seconds, to wait for the job to complete
.INPUTS
    None
.EXAMPLE
    Update-OMEFirmware -Baseline $("AllLatest" | Get-OMEFirmwareBaseline) | Format-Table

    Display device compliance report for all devices in baseline. No updates are installed by default.
.EXAMPLE
    Update-OMEFirmware -Baseline $("AllLatest" | Get-OMEFirmwareBaseline) -UpdateSchedule "RebootNow"

    Update firmware on all devices in baseline immediately ***Warning: This will force a reboot of all servers
.EXAMPLE
    Update-OMEFirmware -Baseline $("AllLatest" | Get-OMEFirmwareBaseline) -UpdateSchedule "StageForNextReboot"

    Update firmware on all devices in baseline on next reboot
.EXAMPLE
    Update-OMEFirmware -Baseline $("AllLatest" | Get-OMEFirmwareBaseline) -DeviceFilter $("C86C0Q2" | Get-OMEDevice -FilterBy "ServiceTag") -UpdateSchedule "ScheduleLater" -UpdateScheduleCron "0 0 0 1 11 ?"

    Update firmware on 11/1/2020 12:00AM UTC
.EXAMPLE
    Update-OMEFirmware -Baseline $("AllLatest" | Get-OMEFirmwareBaseline) -DeviceFilter $("C86C0Q2" | Get-OMEDevice -FilterBy "ServiceTag") -UpdateSchedule "RebootNow"

    Update firmware on specific devices in baseline immediately ***Warning: This will force a reboot of all servers
.EXAMPLE
    Update-OMEFirmware -Baseline $("AllLatest" | Get-OMEFirmwareBaseline) -ComponentFilter "iDRAC" -UpdateSchedule "StageForNextReboot" -ClearJobQueue
    
    Update firmware on specific components in baseline on next reboot and clear job queue before update
#>

[CmdletBinding()]
param(
    [Parameter(Mandatory)]
    [String]$iDRAC,
  
    [Parameter(Mandatory)]
    [String]$UserName,
    
    [Parameter(Mandatory)]
    [SecureString]$Password,

    [Parameter(Mandatory)]
    [String]$Source = "downloads.dell.com",

    [Parameter(Mandatory)]
    [String]$SourcePath = "catalog/catalog.gz",

    [Parameter(Mandatory)]
    [String]$CatalogFile = "catalog.xml",

    [Parameter(Mandatory)]
    [ValidateSet("CIFS", "FTP", "HTTP", "HTTPS", "NFS", "TFTP")]
    [String]$RepositoryType,

    [Parameter(Mandatory=$false)]
    [String]$DomainName,

    [Parameter(Mandatory=$false)]
    [String]$RepositoryUserName,

    [Parameter(Mandatory=$false)]
    [SecureString]$RepositoryPassword,    

    [Parameter(Mandatory=$false)]
    [Switch]$CheckCertificate,

    [Parameter(Mandatory=$false)]
    [ValidateSet("Preview", "RebootNow", "StageForNextReboot")]
    [String]$UpdateSchedule = "Preview",

    [Parameter(Mandatory=$false)]
    [Switch]$Wait,

    [Parameter(Mandatory=$false)]
    [int]$WaitTime = 3600
)

Begin {
}
Process {
    Try {
        if (-not $CheckCertificate) { Set-CertPolicy }
        $BaseUri = "https://$($iDRAC)/redfish/v1"
        $ContentType  = "application/json"
        $Headers = @{}
        $Headers."X-Auth-Token" = $SessionAuth.Token
        $Credentials =  Get-iDRACCredential -UserName $UserName -Password $Password

        $UpdateURL = $BaseUri + "/Dell/Systems/System.Embedded.1/DellSoftwareInstallationService/Actions/DellSoftwareInstallationService.InstallFromRepository"
        $UpdatePayload = Get-iDRACFirmwarePayload -UpdateSchedule $UpdateSchedule `
            -Source $Source -SourcePath $SourcePath -CatalogFile $CatalogFile `
            -RepositoryType $RepositoryType -RepositoryUserName $RepositoryUserName -RepositoryPassword $RepositoryPassword `
            -DomainName $DomainName -CheckCertificate $CheckCertificate
        $UpdatePayload = $UpdatePayload | ConvertTo-Json -Depth 6
        Write-Verbose $UpdatePayload
        $JobResp = Invoke-WebRequest -Uri $UpdateURL -Credential $Credentials -Headers $Headers -ContentType $ContentType -Method POST -Body $UpdatePayload
        if ($JobResp.StatusCode -eq 200 -or $JobResp.StatusCode -eq 202) {
            Write-Verbose "Update job creation successful"
            #$JobInfo = $JobResp.Content | ConvertFrom-Json
            $JobId = $JobResp.Headers["Location"].Split("/")[-1]
            Write-Verbose "Created job $($JobId) to update firmware..."
            if ($UpdateSchedule -eq "Preview") { # Only show report, do not perform any updates
                return Get-iDRACFirmwareCompliance -BaseUri $BaseUri -Credentials $Credentials
            }
            if ($Wait) {
                $JobStatus = $($JobId | Wait-iDRACOnJob -BaseUri $BaseUri -Credentials $Credentials -WaitTime $WaitTime)
                return $JobStatus
            } else {
                return $JobId
            }
        }
        else {
            Write-Error "Update job creation failed"
        }

    }
    Catch {
        Write-Error ($_.ErrorDetails)
        Write-Error ($_.Exception | Format-List -Force | Out-String)
        Write-Error ($_.InvocationInfo | Format-List -Force | Out-String)
    }
}

End {}

}

