
function Edit-OMESecurityBanner {
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
    Edit Security Banner on Login Screen in OpenManage Enterprise
.DESCRIPTION

.PARAMETER Banner
    Banner text
.INPUTS
    None
.EXAMPLE
    "This is the new banner text" | Edit-OMESecurityBanner
    
    Edit Security Banner
#>

[CmdletBinding()]
param(
    [Parameter(Mandatory, ValueFromPipeline)]
    [String]$Banner
)

Begin {}
Process {
    if (!$(Confirm-IsAuthenticated)){
        Return
    }
    Try {
        if ($SessionAuth.IgnoreCertificateWarning) { Set-CertPolicy }
        $BaseUri = "https://$($SessionAuth.Host)"
        $BannerURL = $BaseUri + "/api/ApplicationService/Actions/ApplicationService.SetSecurityPolicyMessage"
        $Type = "application/json"
        $Headers = @{}
        $Headers."X-Auth-Token" = $SessionAuth.Token

        $BannerPayload ='{
            "SecurityPolicyMessage": "Example banner text"
        }' | ConvertFrom-Json
        $BannerPayload.SecurityPolicyMessage = $Banner
        $BannerPayload = $BannerPayload | ConvertTo-Json -Depth 6
        Write-Verbose $BannerPayload
        $BannerResponse = Invoke-WebRequest -Uri $BannerURL -UseBasicParsing -Headers $Headers -ContentType $Type -Method POST -Body $BannerPayload
        Write-Verbose "Updating banner text..."
        if ($BannerResponse.StatusCode -in (200,201)) {
            Write-Verbose "Banner update successfull!"
            return $true
        }
        else {
            Write-Error "Banner update failed..."
            return $false
        }

    }
    Catch {
        Resolve-Error $_
    }
}

End {}

}

