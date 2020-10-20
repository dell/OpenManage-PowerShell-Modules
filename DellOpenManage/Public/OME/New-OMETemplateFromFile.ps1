﻿function New-OMETemplateFromFile {
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
    Create template from XML string in OpenManage Enterprise
.DESCRIPTION
    Perform an export of the System Configuration Profile (SCP) as an example
.PARAMETER Name
    String that will be assigned the name of the template
.PARAMETER Content
    XML string containing template to import
.PARAMETER Wait
    Wait for job to complete
.PARAMETER WaitTime
    Time, in seconds, to wait for the job to complete
.INPUTS
    [String]Content
.EXAMPLE
    New-OMETemplateFromFile -Name "TestTemplate" -Content "<XML>" -Wait
.EXAMPLE
    New-OMETemplateFromFile -Name "TestTemplate" -Content $(Get-Content -Path .\Data.xml | Out-String)
#>

[CmdletBinding()]
param(
    [Parameter(Mandatory=$false)]
    [String]$Name = "Template_$((Get-Date).ToString('yyyyMMddHHmmss'))",
    
    [Parameter(Mandatory, ValueFromPipeline)]
    [String]$Content,

    [Parameter(Mandatory=$false)]
    [Switch]$Wait,

    [Parameter(Mandatory=$false)]
    [int]$WaitTime = 3600
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

        $TemplateUrl = $BaseUri + "/api/TemplateService/Actions/TemplateService.Import"
        $TemplatePayload = '{
            "Name": "Template Import",
            "Type": 2,
            "ViewTypeId": 2,
            "Content" : ""
        }'
        $TemplatePayload = $TemplatePayload | ConvertFrom-Json
        $TemplatePayload.Name = $Name
        $TemplatePayload.Content = $Content
        $TemplatePayload = $TemplatePayload | ConvertTo-Json -Depth 6
        Write-Verbose $TemplatePayload
        $TemplateId = $null
        $TemplateResponse = Invoke-WebRequest -Uri $TemplateUrl -Method Post -Body $TemplatePayload -ContentType $Type -Headers $Headers
        Write-Verbose "Creating Template..."
        if ($TemplateResponse.StatusCode -eq 200) {
            $TemplateId = $TemplateResponse.Content | ConvertFrom-Json
            if ($Wait) {
                $TemplateStatus = $($TemplateId | Wait-OnTemplate -WaitTime $WaitTime)
                return $TemplateStatus
            }
        }
        return $TemplateId
    } 
    Catch {
        Write-Error ($_.Exception | Format-List -Force | Out-String) 
        Write-Error ($_.InvocationInfo | Format-List -Force | Out-String)
    }
}

End {}

}

