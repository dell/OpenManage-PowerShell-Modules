
function Get-McmGroupPayload($Name, $Description, $JoinApproval, $VIPIPv4Address, $VIPSubnetMask, $VIPGateway) {
    $Payload = '{
        "GroupName": "",
        "GroupDescription": "",
        "JoinApproval": "AUTOMATIC",
        "ConfigReplication": [{
            "ConfigType": "Power",
            "Enabled": "true"
        }, {
            "ConfigType": "UserAuthentication",
            "Enabled": "true"
        }, {
            "ConfigType": "AlertDestinations",
            "Enabled": "true"
        }, {
            "ConfigType": "TimeSettings",
            "Enabled": "true"
        }, {
            "ConfigType": "ProxySettings",
            "Enabled": "true"
        }, {
            "ConfigType": "SecuritySettings",
            "Enabled": "true"
        }, {
            "ConfigType": "NetworkServices",
            "Enabled": "true"
        }, {
            "ConfigType": "LocalAccessConfiguration",
            "Enabled": "true"
        }]
    }' | ConvertFrom-Json

    $VirtualIPConfiguration = '{
        "Ipv4": {
            "StaticIPAddress":"10.35.155.155",
            "SubnetMask":"255.255.255.32",
            "Gateway":"10.35.2.1"
        }
    }' | ConvertFrom-Json

    $Payload.GroupName = $Name
    $Payload.GroupDescription = $Description
    $Payload.JoinApproval = $JoinApproval

    if ($null -ne $VIPIPv4Address -and $VIPIPv4Address -ne "") {
        $VirtualIPConfiguration.Ipv4.StaticIPAddress = $VIPIPv4Address
        $VirtualIPConfiguration.Ipv4.SubnetMask = $VIPSubnetMask
        $VirtualIPConfiguration.Ipv4.Gateway = $VIPGateway
        $Payload | Add-Member -NotePropertyName VirtualIPConfiguration -NotePropertyValue $VirtualIPConfiguration
    }
    $Payload = $Payload | ConvertTo-Json -Depth 6
    return $Payload
}

function New-OMEMcmGroup {
<#
_author_ = Vittalareddy Nanjareddy <vittalareddy_nanjare@Dell.com>

Copyright (c) 2021 Dell EMC Corporation

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
   Create an MCM group 

 .DESCRIPTION
   This script uses the OME REST API to create mcm group, find memebers and add the members to the group.

 .PARAMETER GroupName
   The Name of the MCM Group.

 .EXAMPLE
   New-OMEMcmGroup -GroupName TestGroup -Wait

#>
[CmdletBinding()]
param(
    [Parameter(Mandatory)]
    [String] $Name,

    [Parameter(Mandatory=$false)]
    [String] $Description,

    [Parameter(Mandatory=$false)]
    [ValidateSet("Automatic", "Manual")]
    [String]$JoinApproval = "Automatic",

    [Parameter(Mandatory=$false)]
    [String] $VIPIPv4Address,
    
    [Parameter(Mandatory=$false)]
    [String] $VIPSubnetMask,

    [Parameter(Mandatory=$false)]
    [String] $VIPGateway,

    [Parameter(Mandatory=$false)]
    [Switch]$Wait,

    [Parameter(Mandatory=$false)]
    [int]$WaitTime = 3600
)

## Script that does the work
if (!$(Confirm-IsAuthenticated)){
    Return
}

Try {
    if ($SessionAuth.IgnoreCertificateWarning) { Set-CertPolicy }
    $BaseUri = "https://$($SessionAuth.Host)"
    $Headers = @{}
    $Headers."X-Auth-Token" = $SessionAuth.Token
    $ContentType = "application/json"

    if ($null -ne $VIPIPv4Address -and $VIPIPv4Address -ne "") {
        if ($null -eq $VIPSubnetMask) { throw [System.ArgumentNullException] "VIPSubnetMask when specifing VIPIPv4Address" }
        if ($null -eq $VIPGateway) { throw [System.ArgumentNullException] "VIPGateway when specifing VIPIPv4Address" }
    }

    # Create mcm group
    $JobId = 0
    Write-Verbose "Creating mcm group"
    $McmGroupPayload = Get-McmGroupPayload -Name $Name -Description $Description -JoinApproval $JoinApproval -VIPIPv4Address $VIPIPv4Address -VIPSubnetMask $VIPSubnetMask -VIPGateway $VIPGateway
    Write-Verbose $McmGroupPayload
    $CreateGroupURL = $BaseUri + "/api/ManagementDomainService"
    $Response = Invoke-WebRequest -Uri $CreateGroupURL -UseBasicParsing -Headers $Headers -ContentType $ContentType -Method PUT -Body $McmGroupPayload 
    if ($Response.StatusCode -eq 200) {
        $GroupData = $Response | ConvertFrom-Json
        $JobId = $GroupData.JobId
        Write-Verbose "MCM group created successfully...JobId is $($JobId)"
    }
    else {
        Write-Warning "Failed to create MCM group"
    }
    if ($JobId -ne 0) {
        Write-Verbose "Created job $($JobId) to create mcm group ... Polling status now"
        if ($Wait) {
            $JobStatus = $($JobId | Wait-OnJob -WaitTime $WaitTime)
            return $JobStatus
        } else {
            return $JobId
        }
    }
    else {
        Write-Error "Unable to track group creation .. Exiting" 
    }

}
catch {
    Resolve-Error $_
}

}