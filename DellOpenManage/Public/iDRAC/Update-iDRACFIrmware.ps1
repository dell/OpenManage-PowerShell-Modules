


function Get-iDRACFirmwarePayload($UpdateSchedule, $Source, $SourcePath, $CatalogFile, $DomainName, $RepositoryType, $RepositoryUserName, [securestring] $RepositoryPassword, $CheckCertificate) {
    $Payload = '{
        "ApplyUpdate": "False",
        "CatalogFile": "Catalog.xml",
        "IPAddress": "",
        "IgnoreCertWarning": "On",
        "Mountpoint": "",
        "RebootNeeded": false,
        "ShareName": "",
        "ShareType": ""
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
        #$Payload.Mountpoint = $SourcePath # CIFS, I don't think this is required
        $Payload | Add-Member -NotePropertyName UserName -NotePropertyValue $RepositoryUserName
        $RepositoryPasswordText = (New-Object PSCredential "user", $RepositoryPassword).GetNetworkCredential().Password
        $Payload | Add-Member -NotePropertyName Password -NotePropertyValue $RepositoryPasswordText
        $Payload | Add-Member -NotePropertyName Workgroup -NotePropertyValue $DomainName
    }
    # Proxy support not implemented yet
    #$Payload.ProxyPasswd = "",
    #$Payload.ProxyPort = "Off", #DefaultProxy|Off|ParametersProxy
    #$Payload.ProxyServer = "",
    #$Payload.ProxySupport = "",
    #$Payload.ProxyType = "", # HTTP|SOCKS
    #$Payload.ProxyUname = "",

    return $payload
}

function Get-iDRACFirmwareCompliance ($BaseUri, [pscredential]$Credentials) {
    $props = @()
    try {
        $Payload = @{} | ConvertTo-Json -Compress
        $ComplianceURL = $BaseUri + "/Dell/Systems/System.Embedded.1/DellSoftwareInstallationService/Actions/DellSoftwareInstallationService.GetRepoBasedUpdateList"
        $ComplianceResp = Invoke-WebRequest -Uri $ComplianceURL -Credential $Credentials -Method POST -Body $Payload -ContentType 'application/json' -Headers @{"Accept"="application/json"}  -ErrorVariable RespErr
        if ($ComplianceResp.StatusCode -eq 200 -or $ComplianceResp.StatusCode -eq 202) {
            $ComplianceInfo = $ComplianceResp.Content | ConvertFrom-Json
            # The package list is in XML. We need to parse it and extract the properties.
            # The iDRAC doesn't compare versions against the repository catalog. It will upgrade or downgrade to whatever is in the catalog. 
            [xml]$xmlAttr = $ComplianceInfo.PackageList 
            $xmlAttr.CIM.MESSAGE.SIMPLEREQ."VALUE.NAMEDINSTANCE" | ForEach-Object {
                $_.INSTANCENAME | ForEach-Object {
                    $instance = @{}
                    $_.PROPERTY | ForEach-Object {
                        $Name = $_ | Select-Object -ExpandProperty NAME
                        $Value = $_.VALUE
                        $instance.Add($Name, $Value)
                    }
                    $_."PROPERTY.ARRAY" | ForEach-Object {
                        $Name = $_ | Select-Object -ExpandProperty NAME
                        $Value = $_."VALUE.ARRAY".VALUE
                        $instance.Add($Name, $Value)
                    }
                    $props += $instance
                }
            }
            return $props
        }
        else {
            Write-Error "Update job creation failed"
        }
    } catch {
        $response = $_.ErrorDetails.Message | ConvertFrom-Json
        Write-Verbose -Message $response.error."@Message.ExtendedInfo"[0].Message
        return $props
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
    Update firmware on iDRAC
.DESCRIPTION
    ***Warning*** The iDRAC does not compare firmware versions against the catalog. It will just upgrade or downgrade to whatever version is in the catalog.
.PARAMETER Source
    Hostname or IP Address of server
.PARAMETER SourcePath
    Directory or share path of server
.PARAMETER CatalogFile
    Filename of catalog (Default=Catalog.xml)
.PARAMETER RepositoryType
    Type of repository ("CIFS", "FTP", "HTTP", "HTTPS", "NFS", "TFTP")
.PARAMETER DomainName
    Domain name *Only used for CIFS
.PARAMETER RepositoryUserName
    Share Username *Only used for CIFS
.PARAMETER RepositoryPassword
    Share Password *Only used for CIFS
.PARAMETER CheckCertificate
    Enable certificate check *Only used for HTTPS
.PARAMETER UpdateSchedule
    Determines when the updates will be performed. (Default="Preview", "RebootNow", "StageForNextReboot")
.PARAMETER Wait
    Wait for job to complete
.PARAMETER WaitTime
    Time, in seconds, to wait for the job to complete
.INPUTS
    None
.EXAMPLE
    $Password = $(ConvertTo-SecureString 'calvin' -AsPlainText -Force)
    Update-iDRACFirmware -iDRAC 192.168.1.100 -UserName root -Password $Password `
        -RepositoryType "NFS" `
        -Source "192.168.1.200" `
        -SourcePath "/mnt/data/drm/R640" `
        -CatalogFile "R640_1.00_Catalog.xml" `
        -UpdateSchedule "Preview" -Verbose 

    Display component update list. No updates are installed by default.
.EXAMPLE
    $Password = $(ConvertTo-SecureString 'calvin' -AsPlainText -Force)
    Update-iDRACFirmware -iDRAC 192.168.1.100 -UserName root -Password $Password `
        -RepositoryType "NFS" `
        -Source "192.168.1.200" `
        -SourcePath "/mnt/data/drm/R640" `
        -CatalogFile "R640_1.00_Catalog.xml" `
        -UpdateSchedule "RebootNow" -Verbose

    Update firmware immediately ***Warning: This will force a reboot of all servers
.EXAMPLE
    $Password = $(ConvertTo-SecureString 'calvin' -AsPlainText -Force)
    Update-iDRACFirmware -iDRAC 192.168.1.100 -UserName root -Password $Password `
        -RepositoryType "NFS" `
        -Source "192.168.1.200" `
        -SourcePath "/mnt/data/drm/R640" `
        -CatalogFile "R640_1.00_Catalog.xml" `
        -UpdateSchedule "StageForNextReboot" -Verbose

    Stage update firmware for next reboot
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
    [String]$Source,

    [Parameter(Mandatory)]
    [String]$SourcePath,

    [Parameter(Mandatory=$false)]
    [String]$CatalogFile = "Catalog.xml",

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
    [Switch]$WaitForAll,

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
        $Headers."Accept" = "application/json"
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
            $JobId = $JobResp.Headers["Location"].Split("/")[-1]
            Write-Verbose "Created job $($JobId) to update firmware..."
            if ($Wait -or $WaitForAll) {
                $WaitForStatus = "Completed"
                if ($WaitForAll -and $UpdateSchedule -eq "StageForNextReboot") {
                    # We need to wait for the initial job to be status Downloaded before running GetRepoUpdateList to see the JID
                    $WaitForStatus = "Downloaded" 
                }
                # Wait for job to reach desired status before continuing
                $JobStatus = $($JobId | Wait-iDRACOnJob -BaseUri $BaseUri -Credentials $Credentials -WaitTime $WaitTime -WaitForStatus $WaitForStatus)
                if (-not $WaitForAll) { # If we're waiting for all jobs to complete we don't want to exit here
                    return $JobStatus
                }
            } else {
                return $JobId
            }
            if ($WaitForAll -and $UpdateSchedule -ne "Preview" -and $JobStatus -ne "Failed") {
                $MAX_RETRIES = $WaitTime / 10
                $SLEEP_INTERVAL = 30
                $Ctr = 0
                # Run GetRepoBasedUpdateList until the JID is filled in for each component update job
                do {
                    $Ctr++
                    Start-Sleep -s $SLEEP_INTERVAL
                    
                    $ComplianceData = Get-iDRACFirmwareCompliance -BaseUri $BaseUri -Credentials $Credentials
                    Write-Verbose $($ComplianceData | Format-Table | Out-String)
                    # Get a count of component updates that require a host reboot. This excludes iDRAC updates that don't require a reboot.
                    $UpdateCount = $ComplianceData | Where-Object {$_.RebootType -eq "HOST"} | Measure-Object | Select-Object -ExpandProperty Count
                    $JobCount = $ComplianceData | Where-Object {$_.RebootType -eq "HOST" -and $_.JobId -ne ""} | Measure-Object | Select-Object -ExpandProperty Count
                    if ($UpdateCount -eq $JobCount) {
                        break # Exit loop once all components have a JID
                    }
                } until ($Ctr -ge $MAX_RETRIES)
                
                $JobIds = $ComplianceData | Where-Object {$_.RebootType -eq "HOST"} | Select-Object -ExpandProperty JobId
                if ($JobIds.Length -gt 0) { # It could be possible that no component updates require a reboot but there are still components to update like the iDRAC.
                    $WaitForStatus2 = "Completed"
                    if ($UpdateSchedule -eq "StageForNextReboot") {
                        $WaitForStatus2 = "Scheduled" 
                    }
                    return $($JobIds | Wait-iDRACOnJob -BaseUri $BaseUri -Credentials $Credentials -WaitTime $WaitTime -WaitForStatus $WaitForStatus2)
                } else {
                    return $ComplianceData
                }
            } else {
                $ComplianceData = Get-iDRACFirmwareCompliance -BaseUri $BaseUri -Credentials $Credentials
                return $ComplianceData
            }
            
        }
        else {
            Write-Error "Update job creation failed"
        }

    }
    Catch {
        Resolve-Error $_
    }
}

End {}

}

