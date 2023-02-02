using module ..\..\Classes\Account.psm1

function Remove-OMEUser {
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
    Remove user
.DESCRIPTION
    Remove user
.PARAMETER Account
    Object of type Account returned from Get-OMEUser
.INPUTS
    None
.EXAMPLE
    "TestUser" | Get-OMEUser | Remove-OMEUser
    
    Remove user
#>

[CmdletBinding()]
param(
    [Parameter(Mandatory, ValueFromPipeline)]
    [Account] $User
)

Begin {}
Process {
    if (!$(Confirm-IsAuthenticated)){
        Return
    }
    Try {
        if ($SessionAuth.IgnoreCertificateWarning) { Set-CertPolicy }
        $BaseUri = "https://$($SessionAuth.Host)"
        $RemoveUrl = $BaseUri + "/api/AccountService/Accounts('$($User.Id)')"
        $Type = "application/json"
        $Headers = @{}
        $Headers."X-Auth-Token" = $SessionAuth.Token

        Write-Verbose $RemoveUrl
        $GroupResponse = Invoke-WebRequest -Uri $RemoveUrl -UseBasicParsing -Headers $Headers -ContentType $Type -Method DELETE
        Write-Verbose "Removing user..."
        if ($GroupResponse.StatusCode -eq 204) {
            Write-Verbose "Remove user successful..."
        }
        else {
            Write-Error "Remove user failed..."
        }
    }
    Catch {
        Resolve-Error $_
    }
}

End {}

}

