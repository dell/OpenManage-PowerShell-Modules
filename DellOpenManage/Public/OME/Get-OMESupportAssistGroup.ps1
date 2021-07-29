using module ..\..\Classes\Group.psm1
Function Get-OMESupportAssistGroup {
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
    Get groups from OpenManage Enterprise
.DESCRIPTION
    Returns all groups if no input received
.PARAMETER Value
    String containing search value. Use with -FilterBy parameter
.PARAMETER FilterBy
    Filter the results by ("Name", "Id")
.INPUTS
    String[]
.EXAMPLE
    Get-OMESupportAssistGroup | Format-Table
    Get all groups
.EXAMPLE
    "Servers_Win" | Get-OMESupportAssistGroup | Format-Table
    Get group by name
.EXAMPLE
    "Servers_ESXi", "Servers_Win" | Get-OMESupportAssistGroup | Format-Table
    Get multiple groups
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
        $GroupUrl = $BaseUri + "/api/SupportAssistService/GroupSummary/Groups('$($Group.Id)')/CustomerContactDetails"
        $ContentType = "application/json"
        $Headers = @{}
        $Headers."X-Auth-Token" = $SessionAuth.Token

        $GroupData = @()
        $GrpResp = Invoke-WebRequest -Uri $GroupUrl -UseBasicParsing -Method Get -Headers $Headers -ContentType $ContentType
        if ($GrpResp.StatusCode -eq 200) {
            $GroupData = $GrpResp.Content | ConvertFrom-Json
            return $(New-SupportAssistGroupFromJson -Group $GroupData)
        }
        else {
            Write-Error "Unable to retrieve Support Assist group from $($SessionAuth.Host)"
        }
    } 
    Catch {
        Resolve-Error $_
    }
}

End {}

}