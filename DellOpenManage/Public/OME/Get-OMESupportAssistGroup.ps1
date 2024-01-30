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
    "Support Assist Group 1" | Get-OMEGroup | Get-OMESupportAssistGroup | Format-Table

    Get group by name
.EXAMPLE
    "Support Assist Group 1" | Get-OMEGroup | Get-OMESupportAssistGroup | ConvertTo-Json | Set-Content "C:\Temp\export.json"

    Get group by name to file
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
    # Add version check for SupportAssist commandlets
    if ($SessionAuth.Version -lt [System.Version]"3.5.0") {
        Write-Error "SupportAssist API not supported in version $($SessionAuth.Version) of OpenManage Enterprise"
        Return
    }
    Try {
        if ($SessionAuth.IgnoreCertificateWarning) { Set-CertPolicy }
        $BaseUri = "https://$($SessionAuth.Host)"
        $GroupUrl = $BaseUri + "/api/SupportAssistService/GroupSummary/Groups('$($Group.Id)')/CustomerContactDetails"
        $ContentType = "application/json"
        $Headers = @{}
        $Headers."X-Auth-Token" = $SessionAuth.Token

        $GroupData = @()
        $GrpResp = Invoke-WebRequest -Uri $GroupUrl -UseBasicParsing -Method Get -Headers $Headers -ContentType $ContentType
        if ($GrpResp.StatusCode -in 200, 201) {
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
