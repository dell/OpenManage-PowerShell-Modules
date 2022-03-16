Function Get-OMEGroup {
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
    Get-OMEGroup | Format-Table

    Get all groups
.EXAMPLE
    "Servers_Win" | Get-OMEGroup | Format-Table

    Get group by name
.EXAMPLE
    "Servers_ESXi", "Servers_Win" | Get-OMEGroup | Format-Table
    
    Get multiple groups
#>
[CmdletBinding()]
param(
    [Parameter(Mandatory=$false, ValueFromPipeline)]
    [String[]]$Value,

    [Parameter(Mandatory=$false)]
    [ValidateSet("Name", "Id")]
    [String]$FilterBy = "Name"
)

Begin {}
Process {
    if (!$(Confirm-IsAuthenticated)){
        Return
    }
    Try {
        if ($SessionAuth.IgnoreCertificateWarning) { Set-CertPolicy }
        $GroupUrl   = "https://$($SessionAuth.Host)/api/GroupService/Groups"
        $Type        = "application/json"
        $Headers     = @{}
        $FilterMap = @{'Name'='Name'; 'Id'='DefinitionId'; 'Type'='Type'}
        $FilterExpr  = $FilterMap[$FilterBy]
        $GroupData = @()

        $Headers."X-Auth-Token" = $SessionAuth.Token
        if ($Value.Count -gt 0) { 
            if ($FilterBy -eq 'Id') {
                $GroupUrl += "?`$filter=$($FilterExpr) eq $($Value)"
            }
            else {
                $GroupUrl += "?`$filter=$($FilterExpr) eq '$($Value)'"
            }
        }
        $GrpResp = Invoke-WebRequest -Uri $GroupUrl -UseBasicParsing -Method Get -Headers $Headers -ContentType $Type
        if ($GrpResp.StatusCode -eq 200) {
            $GroupInfo = $GrpResp.Content | ConvertFrom-Json
            foreach ($Group in $GroupInfo.'value') {
                $GroupData += New-GroupFromJson $Group
            }
            return $GroupData
        }
        else {
            Write-Error "Unable to retrieve group list from $($SessionAuth.Host)"
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