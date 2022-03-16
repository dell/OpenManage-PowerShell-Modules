using module ..\..\Classes\Group.psm1

function Get-OMEAlertDefinition {
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
    Get devices managed by OpenManage Enterprise
.DESCRIPTION
    Get devices and filter by Id or ServiceTag. Returns all devices if no input received.
.PARAMETER Value
    String containing search value. Use with -FilterBy parameter
.PARAMETER FilterBy
    Filter the results by (Default="ServiceTag", "Name", "Id", "Model", "Type")
.PARAMETER Group
    Array of type Group returned from Get-OMEGroup function
.INPUTS
    Group[]
    String[]
.EXAMPLE
    Get-OMEAlertDefinition
#>

[CmdletBinding()]
param(
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

        $Headers."X-Auth-Token" = $SessionAuth.Token
        $DefinitionData = @()

        $DefinitionCountUrl = $BaseUri + "/api/AlertService/AlertMessageDefinitions"
        $DeviceResponse = Invoke-WebRequest -Uri $DefinitionCountUrl -UseBasicParsing -Method Get -Headers $Headers -ContentType $Type
        if ($DeviceResponse.StatusCode -eq 200)
        {
            $DefinitionCountData = $DeviceResponse.Content | ConvertFrom-Json
            foreach ($Definition in $DefinitionCountData.'value') {
                $DefinitionData += $Definition
            }
            if($DefinitionCountData.'@odata.nextLink')
            {
                $NextLinkUrl = $BaseUri + $DefinitionCountData.'@odata.nextLink'
            }
            while($NextLinkUrl)
            {
                $NextLinkResponse = Invoke-WebRequest -Uri $NextLinkUrl -UseBasicParsing -Method Get -Headers $Headers -ContentType $Type
                if($NextLinkResponse.StatusCode -eq 200)
                {
                    $NextLinkData = $NextLinkResponse.Content | ConvertFrom-Json
                    foreach ($Definition in $NextLinkData.'value') {
                        $DefinitionData +=$Definition
                    }
                    if($NextLinkData.'@odata.nextLink')
                    {
                        $NextLinkUrl = $BaseUri + $NextLinkData.'@odata.nextLink'
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

            
        return $DefinitionData 
    } 
    Catch {
        Write-Error ($_.ErrorDetails)
        Write-Error ($_.Exception | Format-List -Force | Out-String) 
        Write-Error ($_.InvocationInfo | Format-List -Force | Out-String)
    }
}

End {}

}

