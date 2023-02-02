using module ..\..\Classes\AccountProvider.psm1

function Remove-OMEDirectoryService {
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
    Remove network
.DESCRIPTION
    Remove network
.PARAMETER AccountProvider
    Object of type AccountProvider returned from Get-OMEDirectoryService
.INPUTS
    None
.EXAMPLE
    "LAB.LOCAL" | Get-OMEDirectoryService | Remove-OMEDirectoryService
    
    Remove directory service
#>

[CmdletBinding()]
param(
    [Parameter(Mandatory, ValueFromPipeline)]
    [AccountProvider] $AccountProvider
)

Begin {}
Process {
    if (!$(Confirm-IsAuthenticated)){
        Return
    }
    Try {
        if ($SessionAuth.IgnoreCertificateWarning) { Set-CertPolicy }
        $BaseUri = "https://$($SessionAuth.Host)"
        $RemoveUrl = $BaseUri + "/api/AccountService/ExternalAccountProvider/Actions/ExternalAccountProvider.DeleteExternalAccountProvider"
        $Type = "application/json"
        $Headers = @{}
        $Headers."X-Auth-Token" = $SessionAuth.Token

        $Payload ='{
            "AccountProviderIds": []
        }' | ConvertFrom-Json

        $Payload.AccountProviderIds = @($AccountProvider.Id)
        $Payload = $Payload | ConvertTo-Json -Depth 6
        Write-Verbose $Payload

        Write-Verbose $RemoveUrl
        $GroupResponse = Invoke-WebRequest -Uri $RemoveUrl -UseBasicParsing -Headers $Headers -ContentType $Type -Method POST -Body $Payload
        Write-Verbose "Removing directory service..."
        if ($GroupResponse.StatusCode -eq 204) {
            Write-Verbose "Remove directory service successful..."
        }
        else {
            Write-Error "Remove directory service failed..."
        }
    }
    Catch {
        Resolve-Error $_
    }
}

End {}

}

