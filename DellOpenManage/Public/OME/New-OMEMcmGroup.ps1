
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
   Create an MCM group and add all possible members to the created group

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
    [String] $GroupName,

    [Parameter(Mandatory=$false)]
    [Switch]$Wait,

    [Parameter(Mandatory=$false)]
    [int]$WaitTime = 3600
)

function Create-McmGroup($BaseUri, $Headers, $ContentType, $GroupName) {
    $CreateGroupURL = $BaseUri + "/api/ManagementDomainService"
    $payload = '{
        "GroupName": "",
        "GroupDescription": "",
        "JoinApproval": "AUTOMATIC",
        "ConfigReplication": [{
            "ConfigType": "Power",
            "Enabled": "false"
        }, {
            "ConfigType": "UserAuthentication",
            "Enabled": "false"
        }, {
            "ConfigType": "AlertDestinations",
            "Enabled": "false"
        }, {
            "ConfigType": "TimeSettings",
            "Enabled": "false"
        }, {
            "ConfigType": "ProxySettings",
            "Enabled": "false"
        }, {
            "ConfigType": "SecuritySettings",
            "Enabled": "false"
        }, {
            "ConfigType": "NetworkServices",
            "Enabled": "false"
        }, {
            "ConfigType": "LocalAccessConfiguration",
            "Enabled": "false"
        }]
    }' | ConvertFrom-Json

    $JobId = 0
    $Payload."GroupName" = $GroupName
    $Body = $payload | ConvertTo-Json -Depth 6
    $Response = Invoke-WebRequest -Uri $CreateGroupURL -Headers $Headers -ContentType $ContentType -Method PUT -Body $Body 
    if ($Response.StatusCode -eq 200) {
        $GroupData = $Response | ConvertFrom-Json
        $JobId = $GroupData.'JobId'
        Write-Host "MCM group created successfully...JobId is $($JobId)"
    }
    else {
        Write-Warning "Failed to create MCM group"
    }

    return $JobId
}

## Script that does the work
if(!$SessionAuth.Token){
    Write-Error "Please use Connect-OMEServer first"
    Break
    Return
}

Try {
    if ($SessionAuth.IgnoreCertificateWarning) { Set-CertPolicy }
    $BaseUri = "https://$($SessionAuth.Host)"
    $Headers = @{}
    $Headers."X-Auth-Token" = $SessionAuth.Token
    $ContentType = "application/json"

    ## Sending in non-existent targets throws an exception with a "bad request"
    ## error. Doing some pre-req error checking as a result to validate input
    ## This is a Powershell quirk on Invoke-WebRequest failing with an error
    # Create mcm group
    $JobId = 0
    Write-Host "Creating mcm group"
    $JobId = Create-McmGroup -BaseUri $BaseUri -Headers $Headers -ContentType $ContentType -GroupName $GroupName
    if ($JobId) {
        Write-Host "Created job $($JobId) to create mcm group ... Polling status now"
        if ($Wait) {
            $JobId | Wait-OnJob -WaitTime $WaitTime
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