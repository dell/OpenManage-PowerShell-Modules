using module ..\..\Classes\Group.psm1

function Remove-OMESupportAssistGroup {
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
    Get-OMEGroup "Test Group 01" | Remove-OMESupportAssistGroup
    
    Remove group
#>

[CmdletBinding()]
param(
    [Parameter(Mandatory, ValueFromPipeline)]
    [Group]$Group
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
        $GroupURL = $BaseUri + "/api/SupportAssistService/Actions/SupportAssistService.DeleteGroup"
        $ContentType = "application/json"
        $Headers = @{}
        $Headers."X-Auth-Token" = $SessionAuth.Token

        $Payload = @{
            GroupId = $Group.Id
        } | ConvertTo-Json -Depth 10
        Write-Verbose $Payload
        $GroupResponse = Invoke-WebRequest -Uri $GroupURL -Headers $Headers -ContentType $ContentType -Method POST -Body $Payload
        Write-Verbose "Removing group..."
        if ($GroupResponse.StatusCode -eq 200 -or $GroupResponse.StatusCode -eq 202) {
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

