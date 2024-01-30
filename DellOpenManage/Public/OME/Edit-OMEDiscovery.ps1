using module ..\..\Classes\Discovery.psm1

function Update-DiscoverDevicePayload($HostList, $DiscoveryJob, $Mode, $DiscoveryUserName, [SecureString] $DiscoveryPassword, $Email, $Schedule, $ScheduleCron) {
    $DiscoveryConfigPayload = '{
            "DiscoveryConfigGroupId":11,
            "DiscoveryConfigGroupName":"Server Discovery",
            "DiscoveryStatusEmailRecipient":"",
            "DiscoveryConfigModels":[
                {
                 "DiscoveryConfigTargets":[
				 {
						  "NetworkAddressDetail":"",
                          "AddressType":  30
                     }
                 ],
                 "ConnectionProfile":"{
                    \"profileName\":\"\",
                    \"profileDescription\":\"\",
                    \"type\":\"DISCOVERY\",
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
                            \"timeout\": 60
                        }
                    },
                    {
                        \"type\":\"REDFISH\",
                        \"authType\":\"Basic\",
                        \"modified\":false,
                        \"credentials\": {
                            \"username\":\"\",
                            \"password\":\"\",
                            \"caCheck\":false,
                            \"cnCheck\":false,
                            \"port\":443,
                            \"retries\":3,
                            \"timeout\": 60
                        }
                    }]
                }",
                "DeviceType":[1000]
            }],
            "Schedule":{
                "RunNow":true,
                "Cron":"startnow"
            },
            "CreateGroup":false,
            "TrapDestination":false,
            "CommunityString": false
    }' | ConvertFrom-Json

    $DiscoveryPasswordText = (New-Object PSCredential "user", $DiscoveryPassword).GetNetworkCredential().Password
    $DiscoveryConfigPayload.DiscoveryConfigGroupId = $DiscoveryJob.Id
    $DiscoveryConfigPayload.DiscoveryConfigGroupName = $DiscoveryJob.Name
    if ($Email) {
        $DiscoveryConfigPayload.DiscoveryStatusEmailRecipient = $Email
    } else {
        $DiscoveryConfigPayload.DiscoveryStatusEmailRecipient = $DiscoveryJob.EmailRecipient
    }
    $DiscoveryConfigPayload.DiscoveryConfigModels[0].DeviceType = $DiscoveryJob.DeviceType
    $DiscoveryConfigPayload.Schedule = $DiscoveryJob.Schedule
    $DiscoveryConfigPayload.CreateGroup = $DiscoveryJob.CreateGroup
    $DiscoveryConfigPayload.TrapDestination = $DiscoveryJob.TrapDestination
    $DiscoveryConfigPayload.CommunityString = $DiscoveryJob.CommunityString

    # Update credentials
    $ConnectionProfile = $DiscoveryConfigPayload.DiscoveryConfigModels[0].ConnectionProfile | ConvertFrom-Json
    $ConnectionProfile.credentials[0].credentials.'username' = $DiscoveryUserName
    $ConnectionProfile.credentials[0].credentials.'password' = $DiscoveryPasswordText
    $ConnectionProfile.credentials[1].credentials.'username' = $DiscoveryUserName
    $ConnectionProfile.credentials[1].credentials.'password' = $DiscoveryPasswordText
    $DiscoveryConfigPayload.DiscoveryConfigModels[0].ConnectionProfile = $ConnectionProfile | ConvertTo-Json -Depth 6

    # Update target hosts
    if ($Hosts.Count -gt 0) {
        $NewHostList = @()
        if ($Mode.ToLower() -eq "append") {
            $NewHostList = $DiscoveryJob.Hosts
            $CurrentHostList = $DiscoveryJob.Hosts | Select-Object -ExpandProperty NetworkAddressDetail
            foreach ($DiscoveryHost in $HostList) {
                if ($CurrentHostList -notcontains $DiscoveryHost) {
                    $NewHostList += [PSCustomObject]@{
                        "AddressType" = 30
                        "NetworkAddressDetail" = $DiscoveryHost
                    }
                }
            }
        } elseif ($Mode.ToLower() -eq "replace") {
            foreach ($DiscoveryHost in $HostList) {
                $NewHostList += [PSCustomObject]@{
                    "AddressType" = 30
                    "NetworkAddressDetail" = $DiscoveryHost
                }
            }
        } elseif ($Mode.ToLower() -eq "remove") {
            $NewHostList = [System.Collections.ArrayList]$DiscoveryJob.Hosts # Need to cast to ArrayList, standard array is fixed size
            foreach ($CurrentHost in $DiscoveryJob.Hosts) {
                if ($HostList -contains $CurrentHost.NetworkAddressDetail) {
                    $NewHostList.Remove($CurrentHost)
                }
            }
        }
        $DiscoveryConfigPayload.DiscoveryConfigModels[0].DiscoveryConfigTargets = $NewHostList
    } else { # If -Hosts not provided set to existing list of hosts
        $DiscoveryConfigPayload.DiscoveryConfigModels[0].DiscoveryConfigTargets = $DiscoveryJob.Hosts
    }

    # Update schedule
    if ($Schedule.ToLower() -eq "runlater") {
        $DiscoveryConfigPayload.Schedule.RunNow = $false
        $DiscoveryConfigPayload.Schedule.RunLater = $true
        $DiscoveryConfigPayload.Schedule.Cron = $ScheduleCron
    } else {
        $DiscoveryConfigPayload.Schedule.RunNow = $true
        $DiscoveryConfigPayload.Schedule.RunLater = $false
        $DiscoveryConfigPayload.Schedule.Cron = "startnow"
    }

    return $DiscoveryConfigPayload
}

function Get-JobId($BaseUri, $Headers, $DiscoverConfigGroupId) {
    $JobId = -1
    $JobUrl = $BaseUri + "/api/DiscoveryConfigService/Jobs"
    $JobResponse = Invoke-WebRequest -UseBasicParsing -Uri $JobUrl -Headers $Headers -Method Get
    if ($JobResponse.StatusCode -in (200,201)) {
        $JobInfo = $JobResponse.Content | ConvertFrom-Json
        $JobValues = $JobInfo.value
        foreach ($value in $JobValues) {
            if ($value.DiscoveryConfigGroupId -eq $DiscoverConfigGroupId) {
                $JobId = $value.JobId
                break;
            }
        }
    }
    else {
        Write-Error "Unable to get JobId $($JobId)"
    }
    return $JobId
}

function Edit-OMEDiscovery {
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
    Edit device discovery job in OpenManage Enterprise
.DESCRIPTION
    This is used to onboard devices into OpenManage Enterprise. Specify a list of IP Addresses or hostnames. You can also specify a subnet. Wildcards are supported as well.
.PARAMETER Name
    Name of the discovery job
.PARAMETER Hosts
    Array of IP Addresses, Subnets or Hosts
    Valid Format:
    10.35.0.0
    10.36.0.0-10.36.0.255
    10.37.0.0/24
    2607:f2b1:f083:135::5500/118
    2607:f2b1:f083:135::a500-2607:f2b1:f083:135::a600
    hostname.domain.tld
    hostname
    2607:f2b1:f083:139::22a
    Invalid IP Range Format:
    10.35.0.*
    10.36.0.0-255
    10.35.0.0/255.255.255.0
.PARAMETER DiscoveryUserName
    Discovery user name. The iDRAC user for server discovery.
.PARAMETER DiscoveryPassword
    Discovery password. The iDRAC user's password for server discovery.
.PARAMETER Email
    Email upon completion
.PARAMETER Schedule
    Determines when the discovery job will be executed. (Default="RunNow", "RunLater")
.PARAMETER ScheduleCron
    Cron string to schedule discovery job at a later time. Uses UTC time. Used with -Schedule "RunLater"
    Example: Every Sunday at 12:00AM UTC: '0 0 0 ? * sun *'
.PARAMETER Mode
    Method by which hosts are added or removed from discovery job ("Append", Default="Replace", "Remove")
.PARAMETER Wait
    Wait for job to complete
.PARAMETER WaitTime
    Time, in seconds, to wait for the job to complete
.INPUTS
    None
.EXAMPLE
    "TestDiscovery01" | Get-OMEDiscovery | Edit-OMEDiscovery -Hosts @('server01-idrac.example.com') -DiscoveryUserName "root" -DiscoveryPassword $(ConvertTo-SecureString 'calvin' -AsPlainText -Force) -Wait -Verbose

    Replace host list and run now
.EXAMPLE
    "TestDiscovery01" | Get-OMEDiscovery | Edit-OMEDiscovery -Hosts @('server02-idrac.example.com') -Mode "Append" -DiscoveryUserName "root" -DiscoveryPassword $(ConvertTo-SecureString 'calvin' -AsPlainText -Force) -Wait -Verbose

    Append host to host list and run now
.EXAMPLE
    "TestDiscovery01" | Get-OMEDiscovery | Edit-OMEDiscovery -Hosts @('server02-idrac.example.com') -Mode "Remove" -DiscoveryUserName "root" -DiscoveryPassword $(ConvertTo-SecureString 'calvin' -AsPlainText -Force) -Wait -Verbose

    Remove host from host list and run now
.EXAMPLE
    "TestDiscovery01" | Get-OMEDiscovery | Edit-OMEDiscovery -Schedule "RunNow" -DiscoveryUserName "root" -DiscoveryPassword $(ConvertTo-SecureString 'calvin' -AsPlainText -Force) -Wait -Verbose

    Run discovery job now
.EXAMPLE
    "TestDiscovery01" | Get-OMEDiscovery | Edit-OMEDiscovery -Schedule "RunLater" -ScheduleCron "0 0 0 ? * sun *" -DiscoveryUserName "root" -DiscoveryPassword $(ConvertTo-SecureString 'calvin' -AsPlainText -Force) -Wait -Verbose
    
    Run discovery job every Sunday at 12:00AM UTC
#>

[CmdletBinding()]
param(
    [parameter(Mandatory, ValueFromPipeline)]
    [Discovery]$Discovery,

    [Parameter(Mandatory=$false)]
    [String]$Name = "Server Discovery $((Get-Date).ToString('yyyyMMddHHmmss'))",

    [parameter(Mandatory=$false)]
    [String[]]$Hosts,

    [Parameter(Mandatory)]
    [String]$DiscoveryUserName,

    [Parameter(Mandatory)]
    [SecureString]$DiscoveryPassword,

    [Parameter(Mandatory=$false)]
    [String]$Email,

    [Parameter(Mandatory=$false)]
    [ValidateSet("RunNow", "RunLater")]
    [String]$Schedule = "RunNow",

    [Parameter(Mandatory=$false)]
    [String]$ScheduleCron = "0 0 0 ? * sun *",

    [Parameter(Mandatory=$false)]
	[ValidateSet("Append", "Replace", "Remove")]
    [String] $Mode = "Replace",

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

        $Payload = Update-DiscoverDevicePayload -Name $Name -HostList $Hosts -Mode $Mode -DiscoveryJob $Discovery -DiscoveryUserName $DiscoveryUserName -DiscoveryPassword $DiscoveryPassword -Email $Email -Schedule $Schedule -ScheduleCron $ScheduleCron
        $Payload = $Payload | ConvertTo-Json -Depth 6
        $DiscoveryId = $Discovery.Id
        $DiscoverUrl = $BaseUri + "/api/DiscoveryConfigService/DiscoveryConfigGroups(" + $DiscoveryId + ")"
        $DiscoverResponse = Invoke-WebRequest -Uri $DiscoverUrl -UseBasicParsing -Method Put -Body $Payload -Headers $Headers -ContentType $Type
        if ($DiscoverResponse.StatusCode -in (200,201)) {
            Write-Verbose "Discovering devices...."
            Start-Sleep -Seconds 10
            $DiscoverInfo = $DiscoverResponse.Content | ConvertFrom-Json
            $DiscoverConfigGroupId = $DiscoverInfo.DiscoveryConfigGroupId
            $JobId = Get-JobId -BaseUri $BaseUri -Headers $Headers -DiscoverConfigGroupId $DiscoverConfigGroupId
            if ($Wait -and $Schedule.ToLower() -eq "runnow") {
                $JobStatus = $($JobId | Wait-OnJob -WaitTime $WaitTime)
                return $JobStatus
            } else {
                return $JobId
            }
        }
        else {
            Write-Error "Unable to discover device $($DiscoverResponse)"
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

