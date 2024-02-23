
function New-OMEGroup {
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
    Create new static group in OpenManage Enterprise
.DESCRIPTION
    Only static groups are supported currently. Raise an issue on Github for query group support.
.PARAMETER Name
    Name of group
.PARAMETER Description
    Description of group
.INPUTS
    None
.EXAMPLE
    New-OMEGroup -Name "Test Group 01"
    
    Create a new static group
#>

[CmdletBinding()]
param(
    [Parameter(Mandatory)]
    [String]$Name,

    [Parameter(Mandatory=$false)]
    [String]$Description
)

Begin {}
Process {
    if (!$(Confirm-IsAuthenticated)){
        Return
    }
    Try {
        if ($SessionAuth.IgnoreCertificateWarning) { Set-CertPolicy }
        $BaseUri = "https://$($SessionAuth.Host)"
        $GroupURL = $BaseUri + "/api/GroupService/Actions/GroupService.CreateGroup"
        $Type = "application/json"
        $Headers = @{}
        $Headers."X-Auth-Token" = $SessionAuth.Token

        $GroupPayload = ' {
            "GroupModel":
                {
                "Name": "TestGroup01",
                "Description": "",
                "MembershipTypeId":12,
                "ParentId": 0
                }
        }' | ConvertFrom-Json
        $GroupPayload.GroupModel.Name = $Name
        $GroupPayload.GroupModel.Description = $Description
        $GroupPayload.GroupModel.MembershipTypeId = 12 # 12=Static Group, 24=Query Group

        $StaticGrpResp = Invoke-WebRequest -Uri $($BaseUri + "/api/GroupService/Groups?`$filter=Name eq 'Static Groups'") -UseBasicParsing -Method GET -Headers $Headers -ContentType $Type
        $StaticGrpData = $StaticGrpResp.Content | ConvertFrom-Json
        $StaticGrpId = $StaticGrpData.value[0].Id
        if ($StaticGrpId -gt 0) {
            $GroupPayload.GroupModel.ParentId = $StaticGrpId
        } else {
            throw [System.Exception] "Unable to retreive Id for the 'Static Groups' parent group"
        }

        $GroupPayload = $GroupPayload | ConvertTo-Json -Depth 6
        Write-Verbose $GroupPayload

        $GroupResponse = Invoke-WebRequest -Uri $GroupURL -UseBasicParsing -Headers $Headers -ContentType $Type -Method POST -Body $GroupPayload
        Write-Verbose "Creating Group..."
        if ($GroupResponse.StatusCode -in 200, 201) {
            return $GroupResponse.Content | ConvertFrom-Json
        }
        else {
            Write-Error "Group creation failed..."
        }
    }
    Catch {
        Resolve-Error $_
    }
}

End {}

}

