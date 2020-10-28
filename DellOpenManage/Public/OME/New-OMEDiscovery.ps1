
function Get-DiscoverDevicePayload($HostList, $DeviceType, $DiscoveryUserName, $DiscoveryPassword, $Email, $SetTrapDestination) {
    $DiscoveryConfigPayload = '{
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
                }}]}",
                "DeviceType":[1000]
            }],
            "Schedule":{
                "RunNow":true,
                "Cron":"startnow"
            },
            "CreateGroup":false,
            "TrapDestination":false
    }' | ConvertFrom-Json

    $DeviceMap = @{
        'server' = 1000
        'chassis' = 2000
        'storage' = 5000
        'network' = 6000
    }
    $DiscoveryConfigPayload.DiscoveryConfigGroupName = $Name
    if ($Email) {
        $DiscoveryConfigPayload.DiscoveryStatusEmailRecipient = $Email
    } else {
        $DiscoveryConfigPayload.DiscoveryStatusEmailRecipient.PSObject.Properties.Remove("DiscoveryConfigTargets")
    }
    $DiscoveryConfigPayload.TrapDestination = $SetTrapDestination
    $DiscoveryConfigPayload.DiscoveryConfigModels[0].PSObject.Properties.Remove("DiscoveryConfigTargets")
    $DiscoveryConfigPayload.DiscoveryConfigModels[0]| Add-Member -MemberType NoteProperty -Name 'DiscoveryConfigTargets' -Value @()
    foreach ($DiscoveryHost in $HostList) {
        $jsonContent = [PSCustomObject]@{
            "AddressType" = 30
            "NetworkAddressDetail" = $DiscoveryHost
        }
        $DiscoveryConfigPayload.DiscoveryConfigModels[0].DiscoveryConfigTargets += $jsonContent
    }
    if ($DeviceType -eq 'server' -or $DeviceType -eq 'chassis') {
        $DiscoveryConfigPayload.DiscoveryConfigModels[0].DeviceType = @($DeviceMap[$DeviceType])
        $ConnectionProfile = $DiscoveryConfigPayload.DiscoveryConfigModels[0].ConnectionProfile | ConvertFrom-Json
        $ConnectionProfile.credentials[0].credentials.'username' = $DiscoveryUserName
        $ConnectionProfile.credentials[0].credentials.'password' = $DiscoveryPassword
        $DiscoveryConfigPayload.DiscoveryConfigModels[0].ConnectionProfile = $ConnectionProfile | ConvertTo-Json -Depth 6
    }
    return $DiscoveryConfigPayload
}

function Get-JobId($BaseUri, $Headers, $DiscoverConfigGroupId) {
    $JobId = -1
    $JobUrl = $BaseUri + "/api/DiscoveryConfigService/Jobs"
    $JobResponse = Invoke-WebRequest -UseBasicParsing -Uri $JobUrl -Headers $Headers -Method Get
    if ($JobResponse.StatusCode -eq 200) {
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

function New-OMEDiscovery {
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
    Create new device discovery job in OpenManage Enterprise
.DESCRIPTION
    This is used to onboard devices into OpenManage Enterprise. Specify a list of IP Addresses or hostnames. You can also specify a subnet. Wildcards are supported as well.
.PARAMETER Name
    Name of the discovery job
.PARAMETER DeviceType
    Type of device ("server", "chassis", "storage", "network")
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
.PARAMETER SetTrapDestination
    Set trap destination of iDRAC to OpenManage Enterprise upon discovery
.PARAMETER Wait
    Wait for job to complete
.PARAMETER WaitTime
    Time, in seconds, to wait for the job to complete
.INPUTS
    None
.EXAMPLE
    New-OMEDiscovery -Hosts @('server01-idrac.example.com') -DiscoveryUserName "root" -DiscoveryPassword $(ConvertTo-SecureString 'calvin' -AsPlainText -Force) -Wait -Verbose
    Discover servers by hostname
.EXAMPLE
    New-OMEDiscovery -Hosts @('10.35.0.0', '10.35.0.1') -DiscoveryUserName "root" -DiscoveryPassword $(ConvertTo-SecureString 'calvin' -AsPlainText -Force) -Wait -Verbose
    Discover servers by IP Address
.EXAMPLE
    New-OMEDiscovery -Hosts @('10.37.0.0/24') -DiscoveryUserName "root" -DiscoveryPassword $(ConvertTo-SecureString 'calvin' -AsPlainText -Force) -Wait -Verbose
    Discover servers by Subnet
#>

[CmdletBinding()]
param(
    [Parameter(Mandatory=$false)]
    [String]$Name = "Server Discovery $((Get-Date).ToString('yyyyMMddHHmmss'))",

    [Parameter(Mandatory=$false)]
	[ValidateSet("server", "chassis", "storage", "network")]
    [String] $DeviceType = "server",
    
    [parameter(Mandatory)]
    [String[]]$Hosts,

    [Parameter(Mandatory)]
    [String]$DiscoveryUserName,

    [Parameter(Mandatory)]
    [SecureString]$DiscoveryPassword,

    [Parameter(Mandatory=$false)]
    [String]$Email,

    [Parameter(Mandatory=$false)]
    [Switch]$SetTrapDestination,

    [Parameter(Mandatory=$false)]
    [Switch]$Wait,

    [Parameter(Mandatory=$false)]
    [int]$WaitTime = 3600
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
        $Type  = "application/json"
        $Headers = @{}
        $Headers."X-Auth-Token" = $SessionAuth.Token

        $DiscoverUrl = $BaseUri + "/api/DiscoveryConfigService/DiscoveryConfigGroups"
        if ($Hosts.Count -gt 0) {
            $DiscoveryPasswordText = (New-Object PSCredential "user", $DiscoveryPassword).GetNetworkCredential().Password
            $Payload = Get-DiscoverDevicePayload -HostList $Hosts -DeviceType $DeviceType -DiscoveryUserName $DiscoveryUserName -DiscoveryPassword $DiscoveryPasswordText -Email $Email -SetTrapDestination $SetTrapDestination.IsPresent
            $Payload = $Payload | ConvertTo-Json -Depth 6
            #Write-Verbose $Payload
            $DiscoverResponse = Invoke-WebRequest -Uri $DiscoverUrl -UseBasicParsing -Method Post  -Body $Payload -Headers $Headers -ContentType $Type
            if ($DiscoverResponse.StatusCode -eq 201) {
                Write-Verbose "Discovering devices...."
                Start-Sleep -Seconds 10
                $DiscoverInfo = $DiscoverResponse.Content | ConvertFrom-Json
                $DiscoverConfigGroupId = $DiscoverInfo.DiscoveryConfigGroupId
                $JobId = Get-JobId -BaseUri $BaseUri -Headers $Headers -DiscoverConfigGroupId $DiscoverConfigGroupId
                if ($Wait) {
                    $JobStatus = $($JobId | Wait-OnJob -WaitTime $WaitTime)
                    return $JobStatus
                } else {
                    return $JobId
                }
            }
            else {
                Write-Error "Unable to discover device $($DiscoverResponse)"
            }
        } else {
            Write-Error "Enter a valid IP Address"
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

