
using module ..\..\Classes\Catalog.psm1
function Get-OMECatalog {
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
    Get firmware/driver catalog from OpenManage Enterprise
.DESCRIPTION
    Returns all catalogs if no input received
.PARAMETER Value
    String containing search value. Use with -FilterBy parameter
.PARAMETER FilterBy
    Filter the results by (Default="Name", "Id")
.INPUTS
    String[]
.EXAMPLE
    Get-OMECatalog | Format-Table

    Get all catalogs
.EXAMPLE
    "DRM" | Get-OMECatalog | Format-Table
    
    Get catalog by name
#>

[CmdletBinding()]
param(
    [Parameter(Mandatory=$false, ValueFromPipeline)]
    [String[]]$Value,

    [Parameter(Mandatory=$false)]
    [ValidateSet("Name", "Id")]
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
        $CatalogUrl   = $BaseUri + "/api/UpdateService/Catalogs"
        $Type        = "application/json"
        $Headers     = @{}
        $Headers."X-Auth-Token" = $SessionAuth.Token

        $CatalogData = @()
        $CatalogResp = Invoke-WebRequest -Uri $CatalogUrl -UseBasicParsing -Method Get -Headers $Headers -ContentType $Type
        if ($CatalogResp.StatusCode -eq 200) {
            $CatalogInfo = $CatalogResp.Content | ConvertFrom-Json
            foreach ($Catalog in $CatalogInfo.'value') {
                if ($Value.Count -gt 0 -and $FilterBy -eq "Id") {
                    if ($Catalog.Id -eq $Value){
                        $CatalogData += New-CatalogFromJson $Catalog
                    }
                }
                elseif ($Value.Count -gt 0 -and $FilterBy -eq "Name") {
                    if ($Catalog.Repository.Name -eq $Value){
                        $CatalogData += New-CatalogFromJson $Catalog
                    }
                }
                else {
                    $CatalogData += New-CatalogFromJson $Catalog
                }
            }
            return $CatalogData
        }
        else {
            Write-Error "Unable to retrieve Catalog list from $($SessionAuth.Host)"
        }
    } 
    Catch {
        Write-Error ($_.ErrorDetails)
        Write-Error ($_.Exception | Format-List -Force | Out-String) 
        Write-Error ($_.InvocationInfo | Format-List -Force | Out-String)
    }
}

End {}

}

