
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
.EXAMPLE
    "Configuration" | Get-OMETemplate -FilterBy "Type" | Format-Table
    
    Get template by type
#>

[CmdletBinding()]
param(
    [Parameter(Mandatory=$false, ValueFromPipeline)]
    [String[]]$Value,

    [Parameter(Mandatory=$false)]
    [ValidateSet("Name", "Id", "Type")]
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
        $TemplateUrl = $BaseUri + "/api/TemplateService/Templates"
        $Type = "application/json"
        $Headers = @{}
        $Headers."X-Auth-Token" = $SessionAuth.Token
        $FilterMap = @{
            'Name'='Name';
            'Id'='Id';
            'Type'='ViewTypeId'
        }
        $TEMPLATE_TYPE_MAP = @{
            "Configuration" = 1;
            "Deployment" = 2
        }
        $FilterExpr  = $FilterMap[$FilterBy]
        if ($Value.Count -gt 0) {
            if ($FilterBy -eq 'Id') {
                $TemplateUrl += "?`$filter=$($FilterExpr) eq $($Value)"
            }
            elseif ($FilterBy -eq 'Type') {
                Write-Verbose "Supported Template Types"
                foreach ($n in $TEMPLATE_TYPE_MAP.GetEnumerator().Name) {
                    Write-Verbose $n
                }
                if ($TEMPLATE_TYPE_MAP.GetEnumerator().Name -notcontains $Value) { throw [System.ArgumentException] "FilterBy Value must be either Deployment or Configuration", "Value" }
                $ViewTypeId = $TEMPLATE_TYPE_MAP[$Value]
                $TemplateUrl += "?`$filter=$($FilterExpr) eq $($ViewTypeId)"
            }
            else {
                # The eq filter uses an 'like' type search returning multiple matches
                $TemplateUrl += "?`$filter=$($FilterExpr) eq '$($Value)'"
            }
        }
        $TemplateData = @()
        $TemplateResp = Invoke-WebRequest -Uri $TemplateUrl -UseBasicParsing -Method Get -Headers $Headers -ContentType $Type
        if ($TemplateResp.StatusCode -in (200,201)) {
            $TemplateInfo = $TemplateResp.Content | ConvertFrom-Json
            if ($TemplateInfo.'value'.Length -gt 0) {
                foreach ($TemplateJson in $TemplateInfo.'value') {
                    $Template = New-TemplateFromJson $TemplateJson
                    $TemplateData += $Template
                }
            }

            return $TemplateData
        }
        else {
            Write-Error "Unable to retrieve Template list from $($SessionAuth.Host)"
        }
    }
    Catch {
        Resolve-Error $_
    }
}

End {}

}

