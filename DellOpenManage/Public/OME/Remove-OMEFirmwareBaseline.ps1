using module ..\..\Classes\FirmwareBaseline.psm1

function Remove-OMEFirmwareBaseline {
<#
Copyright (c) 2023 Dell EMC Corporation

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
    Remove firmware baseline from OpenManage Enterprise
.DESCRIPTION
    Remove firmware baseline from OpenManage Enterprise
.PARAMETER FirmwareBaseline
    Object of type FirmwareBaseline returned from Get-OMEFirmwareBaseline
.INPUTS
    None
.EXAMPLE
    "AllLatest" | Get-OMEFirmwareBaseline | Remove-OMEFirmwareBaseline
    
    Remove firmware baseline
#>

[CmdletBinding()]
param(
    [Parameter(Mandatory, ValueFromPipeline)]
    [FirmwareBaseline]$FirmwareBaseline
)

Begin {}
Process {
    if (!$(Confirm-IsAuthenticated)){
        Return
    }
    Try {
        if ($SessionAuth.IgnoreCertificateWarning) { Set-CertPolicy }
        $BaseUri = "https://$($SessionAuth.Host)"
        $RemoveBaselineUrl = $BaseUri + "/api/UpdateService/Actions/UpdateService.RemoveBaselines"
        $Type = "application/json"
        $Headers = @{}
        $Headers."X-Auth-Token" = $SessionAuth.Token

        $Payload ='{
            "BaselineIds":[0]
        }' | ConvertFrom-Json
        
        $Payload.BaselineIds = @($FirmwareBaseline.Id)
        $Payload = $Payload | ConvertTo-Json -Depth 6
        Write-Verbose $Payload
        Write-Verbose $RemoveBaselineUrl

        $GroupResponse = Invoke-WebRequest -Uri $RemoveBaselineUrl -UseBasicParsing -Headers $Headers -ContentType $Type -Method POST -Body $Payload
        Write-Verbose "Removing firmware baseline..."
        if ($GroupResponse.StatusCode -eq 204) {
            Write-Verbose "Remove firmware baseline successful..."
        }
        else {
            Write-Error "Remove firmware baseline failed..."
        }
    }
    Catch {
        Resolve-Error $_
    }
}

End {}

}

