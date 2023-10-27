using module ..\..\Classes\Profile.psm1

function Invoke-OMEProfileRename {
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
    Rename profile
.DESCRIPTION
    Rename existing profile
.PARAMETER ServerProfile
    Object of type Profile returned from Get-OMEProfile
.INPUTS
    [Profile] Profile
.EXAMPLE
    "Profile 00005" | Get-OMEProfile | Invoke-OMEProfileRename -Name "Test Profile 00005"
    
    Rename Profile
.EXAMPLE
    Get-OMEProfile | Where-Object { $_.ProfileName -eq "Profile from template 'Test Template 01' 00001" } | Invoke-OMEProfileRename -Name "Test Profile 01 - 00001"

    Rename Profile deployed from Template on MX platform
#>

[CmdletBinding()]
param(
    [Parameter(Mandatory, ValueFromPipeline)]
    [Profile]$ServerProfile,

    [Parameter(Mandatory)]
    [String]$Name
)

Begin {}
Process {
    if (!$(Confirm-IsAuthenticated)){
        Return
    }
    Try {
        if ($SessionAuth.IgnoreCertificateWarning) { Set-CertPolicy }
        $BaseUri = "https://$($SessionAuth.Host)"
        $Type = "application/json"
        $Headers = @{}
        $Headers."X-Auth-Token" = $SessionAuth.Token

        $Payload = '{
            "ProfileId": 10079,
            "Name": "Edit_Profile_Name"
        }' | ConvertFrom-Json

        $Payload.ProfileId = $ServerProfile.Id
        $Payload.Name = $Name

        $ProfileRenameURL = $BaseUri + "/api/ProfileService/Actions/ProfileService.Rename"
        $ProfileRenamePayload = $Payload | ConvertTo-Json -Depth 6
        Write-Verbose $ProfileRenamePayload
        $JobResponse = Invoke-WebRequest -Uri $ProfileRenameURL -UseBasicParsing -Headers $Headers -ContentType $Type -Method POST -Body $ProfileRenamePayload
        if ($JobResponse.StatusCode -eq 200) {
            return "Completed"
            Write-Verbose "Job run successful..."
        }
        else {
            Write-Error "Job run failed"
        }
    }
    Catch {
        Resolve-Error $_
    }
}

End {}

}

