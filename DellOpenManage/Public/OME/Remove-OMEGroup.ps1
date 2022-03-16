using module ..\..\Classes\Group.psm1

function Remove-OMEGroup {
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
    Remove group from OpenManage Enterprise
.DESCRIPTION
    Remove group from OpenManage Enterprise
.PARAMETER Group
    Object of type Group returned from Get-OMEGroup function
.INPUTS
    None
.EXAMPLE
    Get-OMEGroup "Test Group 01" | Remove-OMEGroup
    
    Remove group
#>

[CmdletBinding()]
param(
    [Parameter(Mandatory, ValueFromPipeline)]
    [Group]$Group
)

Begin {}
Process {
    if (!$(Confirm-IsAuthenticated)){
        Return
    }
    Try {
        if ($SessionAuth.IgnoreCertificateWarning) { Set-CertPolicy }
        $BaseUri = "https://$($SessionAuth.Host)"
        $GroupURL = $BaseUri + "/api/GroupService/Groups(" + $Group.Id + ")"
        $Type = "application/json"
        $Headers = @{}
        $Headers."X-Auth-Token" = $SessionAuth.Token

        $GroupResponse = Invoke-WebRequest -Uri $GroupURL -UseBasicParsing -Headers $Headers -ContentType $Type -Method DELETE
        Write-Verbose "Removing group..."
        if ($GroupResponse.StatusCode -eq 204) {
            Write-Verbose "Remove group successful..."
        }
        else {
            Write-Error "Remove group failed..."
        }
    }
    Catch {
        Resolve-Error $_
    }
}

End {}

}

