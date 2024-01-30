using module ..\..\Classes\Group.psm1

function Get-OMEAlertPolicy {
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
    Get alert policy
.DESCRIPTION
.PARAMETER Value
    String containing search value. Use with -FilterBy parameter
.PARAMETER FilterBy
    Filter the results by (Default="Id")
.INPUTS
    String[]
.EXAMPLE
    12016 | Get-OMEAlertPolicy

    Get by Id
.EXAMPLE
    Get-OMEAlertPolicy | Where-Object { $_.Name -eq "Group A Alert" }

    Get by Name (OME API does not currently support filtering by Name natively)
#>

[CmdletBinding()]
param(
    [Parameter(Mandatory=$false, ValueFromPipeline)]
    [String[]]$Value,

    [Parameter(Mandatory=$false)]
    [ValidateSet("Id")]
    [String]$FilterBy = "Id"
)

Begin {}
Process {
    if (!$(Confirm-IsAuthenticated)){
        Return
    }
    Try {
        if ($SessionAuth.IgnoreCertificateWarning) { Set-CertPolicy }
        $BaseUri = "https://$($SessionAuth.Host)"
        $NextLinkUrl = $null
        $Type        = "application/json"
        $Headers     = @{}
        $FilterMap = @{
            'Id'='Id'
        }
        $FilterExpr  = $FilterMap[$FilterBy]

        $Headers."X-Auth-Token" = $SessionAuth.Token
        $AlertPolicyData = @()

        $AlertPolicyUrl = $BaseUri + "/api/AlertService/AlertPolicies"
        $Filter = ""
        if ($Value) { # Filter By 
            if ($FilterBy -eq 'Id' -or $FilterBy -eq 'Type') {
                $Filter += "`$filter=$($FilterExpr) eq $($Value)"
            }
            else {
                $Filter += "`$filter=$($FilterExpr) eq '$($Value)'"
            }
            $AlertPolicyUrl = $AlertPolicyUrl + "?" + $Filter
        }
        Write-Verbose $AlertPolicyUrl
        $AlertPolicyResponse = Invoke-WebRequest -Uri $AlertPolicyUrl -UseBasicParsing -Method Get -Headers $Headers -ContentType $Type
        if ($AlertPolicyResponse.StatusCode -in (200,201))
        {
            $AlertPolicyCountData = $AlertPolicyResponse.Content | ConvertFrom-Json
            foreach ($AlertPolicy in $AlertPolicyCountData.'value') {
                Write-Verbose $AlertPolicy
                $AlertPolicyData += New-AlertPolicyFromJson -AlertPolicy $AlertPolicy
            }
            if($AlertPolicyCountData.'@odata.nextLink')
            {
                $NextLinkUrl = $BaseUri + $AlertPolicyCountData.'@odata.nextLink' + "&" + $Filter
            }
            while($NextLinkUrl)
            {
                Write-Verbose $NextLinkUrl
                $NextLinkResponse = Invoke-WebRequest -Uri $NextLinkUrl -UseBasicParsing -Method Get -Headers $Headers -ContentType $Type
                if($NextLinkResponse.StatusCode -in (200,201))
                {
                    $NextLinkData = $NextLinkResponse.Content | ConvertFrom-Json
                    foreach ($AlertPolicy in $NextLinkData.'value') {
                        $AlertPolicyData += New-AlertPolicyFromJson -AlertPolicy $AlertPolicy
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

            
        }
        return $AlertPolicyData 
    } 
    Catch {
        Resolve-Error $_
    }
}

End {}

}

