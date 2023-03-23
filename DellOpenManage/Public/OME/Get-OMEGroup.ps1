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
    Filter the results by ("Name", "Type")
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
    [ValidateSet("Name", "Type")]
    [String]$FilterBy = "Name"
)

Begin {}
Process {
    if (!$(Confirm-IsAuthenticated)){
        Return
    }
    Try {
        if ($SessionAuth.IgnoreCertificateWarning) { Set-CertPolicy }
        $BaseUri = "https://$($SessionAuth.Host)"
        $GroupUrl   =  $BaseUri + "/api/GroupService/Groups"
        $Type        = "application/json"
        $Headers     = @{}
        $FilterMap = @{'Name'='Name'; 'Id'='Id'; 'Type'='TypeId'}
        $FilterExpr  = $FilterMap[$FilterBy]
        $GroupData = @()

        $Headers."X-Auth-Token" = $SessionAuth.Token
        $Filter = ""
        if ($Value.Count -gt 0) { 
            if ($FilterBy -eq 'Id' -or $FilterBy -eq 'Type') {
                $Filter += "`$filter=$($FilterExpr) eq $($Value)"
            }
            else {
                $Filter += "`$filter=$($FilterExpr) eq '$($Value)'"
            }
        }
        $GroupUrl = $GroupUrl + "?" + $Filter
        Write-Verbose $GroupUrl
        $GrpResp = Invoke-WebRequest -Uri $GroupUrl -UseBasicParsing -Method Get -Headers $Headers -ContentType $Type
        if ($GrpResp.StatusCode -eq 200) {
            $GroupInfo = $GrpResp.Content | ConvertFrom-Json
            foreach ($Group in $GroupInfo.'value') {
                $GroupData += New-GroupFromJson $Group
            }
            if($GroupInfo.'@odata.nextLink')
            {
                $NextLinkUrl = $BaseUri + $GroupInfo.'@odata.nextLink' + "&" + $Filter
            }
            while($NextLinkUrl)
            {
                Write-Verbose $NextLinkUrl
                $NextLinkResponse = Invoke-WebRequest -Uri $NextLinkUrl -UseBasicParsing -Method Get -Headers $Headers -ContentType $Type
                if($NextLinkResponse.StatusCode -eq 200)
                {
                    $NextLinkData = $NextLinkResponse.Content | ConvertFrom-Json
                    foreach ($Group in $NextLinkData.'value') {
                        $GroupData += New-GroupFromJson $Group
                    }
                    if($NextLinkData.'@odata.nextLink')
                    {
                        $NextLinkUrl = $BaseUri + $NextLinkData.'@odata.nextLink' + "&" + $Filter
                    }
                    else
                    {
                        $NextLinkUrl = $null
                    }
                }
                else
                {
                    Write-Warning "Unable to get nextlink response for $($NextLinkUrl)"
                    $NextLinkUrl = $null
                }
            }
            return $GroupData
        }
        else {
            Write-Error "Unable to retrieve group list from $($SessionAuth.Host)"
        }
    } 
    Catch {
        Resolve-Error $_
    }
}

End {}

}