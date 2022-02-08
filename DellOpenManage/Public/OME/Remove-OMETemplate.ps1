using module ..\..\Classes\Template.psm1
function Remove-OMETemplate {
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
    Remove template in OpenManage Enterprise
.DESCRIPTION
    Remove a configuration or deployment template from OpenManage Enterprise
.PARAMETER Template
    Object of type Template returned from Get-OMETemplate function
.INPUTS
    [Template]Template
.EXAMPLE
    "TestTemplate01" | Get-OMETemplate | Remove-OMETemplate
#>

[CmdletBinding()]
param(
    [Parameter(Mandatory=$true, ValueFromPipeline)]
    [Template]$Template
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
        $Type        = "application/json"
        $Headers     = @{}
        $Headers."X-Auth-Token" = $SessionAuth.Token

        $TemplateUrl = $BaseUri + "/api/TemplateService/Templates($($Template.Id))"

        Write-Verbose "Removing template $($Template.Id)..."
        $TemplateResponse = Invoke-WebRequest -Uri $TemplateUrl -Method Delete -ContentType $Type -Headers $Headers
        if ($TemplateResponse.StatusCode -eq 204) {
            Write-Verbose "Remove template successful..."
        }
        else {
            Write-Error "Remove template failed..."
        }
    }
    Catch {
        Resolve-Error $_
    }
}

End {}

}

