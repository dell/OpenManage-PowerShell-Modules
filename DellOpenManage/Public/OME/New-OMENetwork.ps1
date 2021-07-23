
function New-OMENetwork {
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
    Create new network (VLAN) in OpenManage Enterprise
.DESCRIPTION
    
.PARAMETER Name
    
.PARAMETER Description
    Description of Network
.INPUTS
    None
.EXAMPLE
    New-OMENetwork -Name "Test Network 01"
    Create a new static Network
#>

[CmdletBinding()]
param(
    [Parameter(Mandatory)]
    [String]$Name,

    [Parameter(Mandatory=$false)]
    [String]$Description,

    [Parameter(Mandatory=$false)]
    [Int]$VlanMaximum,

    [Parameter(Mandatory=$false)]
    [Int]$VlanMinimum,

    [Parameter(Mandatory=$false)]
    [Int]$Type
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
        $NetworkURL = $BaseUri + "/api/NetworkConfigurationService/Networks"
        $ContentType = "application/json"
        $Headers = @{}
        $Headers."X-Auth-Token" = $SessionAuth.Token

        $NetworkPayload = '{
            "Name": "Network1",
            "Description": "Network 1",
            "VlanMaximum": 1000,
            "VlanMinimum": 1000,
            "Type": 1
        }' | ConvertFrom-Json
        $NetworkPayload.Name = $Name
        $NetworkPayload.Description = $Description
        $NetworkPayload.VlanMaximum = $VlanMaximum 
        $NetworkPayload.VlanMinimum = $VlanMinimum
        $NetworkPayload.Type = $Type

        $NetworkPayload = $NetworkPayload | ConvertTo-Json -Depth 6
        Write-Verbose $NetworkPayload

        $NetworkResponse = Invoke-WebRequest -Uri $NetworkURL -UseBasicParsing -Headers $Headers -ContentType $ContentType -Method POST -Body $NetworkPayload
        Write-Verbose "Creating Network..."
        if ($NetworkResponse.StatusCode -eq 201) {
            return $NetworkResponse.Content | ConvertFrom-Json
        }
        else {
            Write-Error "Network creation failed..."
        }
    }
    Catch {
        Resolve-Error $_
    }
}

End {}

}

