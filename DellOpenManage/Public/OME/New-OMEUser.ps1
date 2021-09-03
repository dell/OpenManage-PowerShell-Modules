
function New-OMEUser {
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
    Create new user in OpenManage Enterprise
.DESCRIPTION
.PARAMETER Name
    Name of user
.PARAMETER Password
    Password of user
.PARAMETER Role 
    Role of user ("VIEWER", "DEVICE_MANAGER", "ADMINISTRATOR")
.PARAMETER Locked
    Description of user (True, Default=False)
.PARAMETER Enabled
    Description of user (Default=True, False)
.INPUTS
    None
.EXAMPLE
    New-OMEUser -Name "tstest1" -Description "Test user 1" -Password $(ConvertTo-SecureString -Force -AsPlainText "calvin") -Role "ADMINISTRATOR"
    
    Create a new user
#>

[CmdletBinding()]
param(
    [Parameter(Mandatory)]
    [String]$Name,

    [Parameter(Mandatory)]
    [SecureString] $Password,
    
    [Parameter(Mandatory=$false)]
    [string] $Description = "User created via the OME API.",

    [Parameter(Mandatory)]
    [ValidateSet("VIEWER", "DEVICE_MANAGER", "ADMINISTRATOR")]
    [string] $Role,

    [Parameter(Mandatory=$false)]
    [boolean] $Locked = $false,

    [Parameter(Mandatory=$false)]
    [boolean] $Enabled = $true
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
        $AccountURL = $BaseUri + "/api/AccountService/Accounts"
        $Type = "application/json"
        $Headers = @{}
        $Headers."X-Auth-Token" = $SessionAuth.Token

        $RoleMap = @{
            "VIEWER" = "16"
            "DEVICE_MANAGER" = "101"
            "ADMINISTRATOR" = "10"
        }
        $AccountPayload = '{
            "UserTypeId": 1,
            "DirectoryServiceId": 0,
            "Description": "user1 description",
            "Password": "Dell123$",
            "UserName": "user1",
            "RoleId": "10",
            "Locked": false,
            "Enabled": true
        }' | ConvertFrom-Json
        $AccountPayload.UserName = $Name
        $AccountPayload.Password = (New-Object PSCredential "user", $Password).GetNetworkCredential().Password
        $AccountPayload.RoleId = $RoleMap[$Role]
        $AccountPayload.Locked = $Locked
        $AccountPayload.Enabled = $Enabled
        $AccountPayload.Description = $Description
        $AccountPayload = $AccountPayload | ConvertTo-Json -Depth 6
        Write-Verbose $AccountPayload

        $AccountResponse = Invoke-WebRequest -Uri $AccountURL -UseBasicParsing -Headers $Headers -ContentType $Type -Method POST -Body $AccountPayload
        Write-Verbose "Creating Account..."
        if ($AccountResponse.StatusCode -eq 201) {
            return $AccountResponse.Content | ConvertFrom-Json
        }
        else {
            Write-Error "Account creation failed..."
        }
    }
    Catch {
        Resolve-Error $_
    }
}

End {}

}

