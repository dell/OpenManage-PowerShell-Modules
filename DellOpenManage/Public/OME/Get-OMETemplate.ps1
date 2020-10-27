
using module ..\..\Classes\Template.psm1
function Get-OMETemplate {
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
    Get template from OpenManage Enterprise
.DESCRIPTION
    Returns all templates if no input received
.PARAMETER Value
    String containing search value. Use with -FilterBy parameter
.PARAMETER FilterBy
    Filter the results by (Default="Name", "Id")
.INPUTS
    String[]
.EXAMPLE
    Get-OMETemplate | Format-Table
    Get all templates
.EXAMPLE
    "DRM" | Get-OMETemplate | Format-Table
    Get template by name
#>

[CmdletBinding()]
param(
    [Parameter(Mandatory=$false, ValueFromPipeline)]
    [String[]]$Value,

    [Parameter(Mandatory=$false)]
    [ValidateSet("Name", "Id")]
    [String]$FilterBy = "Name"
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
        $TemplateUrl = $BaseUri + "/api/TemplateService/Templates"
        $Type = "application/json"
        $Headers = @{}
        $Headers."X-Auth-Token" = $SessionAuth.Token
        $FilterMap = @{'Name'='Name'; 'Id'='Id'}
        $FilterExpr  = $FilterMap[$FilterBy]
        if ($Value.Count -gt 0) { 
            if ($FilterBy -eq 'Id') {
                $TemplateUrl += "?`$filter=$($FilterExpr) eq $($Value)"
            }
            else {
                $TemplateUrl += "?`$filter=$($FilterExpr) eq '$($Value)'"
            }
        }
        $TemplateData = @()
        $TemplateResp = Invoke-WebRequest -Uri $TemplateUrl -UseBasicParsing -Method Get -Headers $Headers -ContentType $Type
        if ($TemplateResp.StatusCode -eq 200) {
            $TemplateInfo = $TemplateResp.Content | ConvertFrom-Json
            if ($TemplateInfo.'value') {
                # The eq filter uses an 'like' type search returning multiple matches
                foreach ($TemplateJson in $TemplateInfo.'value') {
                    $Template = New-TemplateFromJson $TemplateJson
                    if ($Value.Count -gt 0) { # Filter By
                        if ($FilterBy -eq 'Id') {
                            $TemplateData += $Template
                        } elseif ($FilterBy -eq 'Name') {
                            if ($Template.Name -eq $Value) {
                                $TemplateData += $Template
                            }
                        }
                    } else { # Show all
                        $TemplateData += $Template
                    }
                }
            } else {
                $TemplateData += New-TemplateFromJson $TemplateInfo
            }

            return $TemplateData
        }
        else {
            Write-Error "Unable to retrieve Template list from $($SessionAuth.Host)"
        }
        # Add ability to list all templates
        # Add ability to list and search attributes
    }
    Catch {
        Write-Error ($_.ErrorDetails)
        Write-Error ($_.Exception | Format-List -Force | Out-String) 
        Write-Error ($_.InvocationInfo | Format-List -Force | Out-String)
    }
}

End {}

}

