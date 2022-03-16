
function New-OMECatalog {
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
    Create new driver/firmware catalog in OpenManage Enterprise
.DESCRIPTION
    A catalog is required to update and compare firmware/drivers. This is the source of the updates to compare your devices against. 
.PARAMETER Name
    Name of catalog
.PARAMETER Description
    Description of catalog
.PARAMETER Source
    Hostname or IP Address of server (Default=downloads.dell.com)
.PARAMETER SourcePath
    Directory or share path of server (Default=catalog/catalog.gz)
.PARAMETER CatalogFile
    Filename of catalog (Default=catalog.xml)
.PARAMETER RepositoryType
    Type of repository ("NFS", "CIFS", "HTTP", "HTTPS", Default="DELL_ONLINE")
.PARAMETER DomainName
    Domain name *Only used for CIFS
.PARAMETER Username
    Share Username *Only used for CIFS
.PARAMETER Password
    Share Password *Only used for CIFS
.PARAMETER CheckCertificate
    Enable certificate check *Only used for HTTPS
.PARAMETER Wait
    Wait for job to complete
.PARAMETER WaitTime
    Time, in seconds, to wait for the job to complete
.INPUTS
    None
.EXAMPLE
    New-OMECatalog -Name "DellOnline" 

    Create new catalog from a repository on downloads.dell.com
.EXAMPLE
    New-OMECatalog -Name "NFSTest" -RepositoryType "NFS" -Source "nfs01.example.com" -SourcePath "/mnt/data/drm/AllDevices" -CatalogFile "AllDevices_1.01_Catalog.xml"

    Create new catalog from a NFS repository
.EXAMPLE
    New-OMECatalog -Name "CIFSTest" -RepositoryType "CIFS" -Source "windows01.example.com" -SourcePath "/Share01/DRM/AllDevices" -CatalogFile "AllDevices_1.01_Catalog.xml" -DomainName "example.com" -Username "Administrator" -Password $("P@ssword1" | ConvertTo-SecureString -AsPlainText -Force)
    
    Create new catalog from a CIFS repository
#>

[CmdletBinding()]
param(
    [Parameter(Mandatory)]
    [String]$Name,

    [Parameter(Mandatory=$false)]
    [String]$Description,

    [Parameter(Mandatory=$false)]
    [String]$Source = "downloads.dell.com",

    [Parameter(Mandatory=$false)]
    [String]$SourcePath = "catalog/catalog.gz",

    [Parameter(Mandatory=$false)]
    [String]$CatalogFile = "catalog.xml",

    [Parameter(Mandatory=$false)]
    [ValidateSet("NFS", "CIFS", "HTTP", "HTTPS", "DELL_ONLINE")]
    [String]$RepositoryType = "DELL_ONLINE",

    [Parameter(Mandatory=$false)]
    [String]$DomainName,

    [Parameter(Mandatory=$false)]
    [String]$Username,

    [Parameter(Mandatory=$false)]
    [SecureString]$Password,    

    [Parameter(Mandatory=$false)]
    [Switch]$CheckCertificate,

    [Parameter(Mandatory=$false)]
    [Switch]$Wait,

    [Parameter(Mandatory=$false)]
    [int]$WaitTime = 80
)

Begin {}
Process {
    if (!$(Confirm-IsAuthenticated)){
        Return
    }
    Try {
        if ($SessionAuth.IgnoreCertificateWarning) { Set-CertPolicy }
        $BaseUri = "https://$($SessionAuth.Host)"
        $CatalogURL = $BaseUri + "/api/UpdateService/Catalogs"
        $Type = "application/json"
        $Headers = @{}
        $Headers."X-Auth-Token" = $SessionAuth.Token

        $CatalogPayload = '{
            "Filename":"",
            "SourcePath":"",
            "Repository":{
                "Name":"Dell Online Catalog",
                "Description":"catalog created from downloads dell",
                "RepositoryType":"DELL_ONLINE",
                "Source":"downloads.dell.com",
                "DomainName":"",
                "Username":"",
                "Password":"",
                "CheckCertificate":false
            }
        }' | ConvertFrom-Json
        $CatalogPayload.Filename = $CatalogFile
        $CatalogPayload.SourcePath = $SourcePath
        $CatalogPayload.Repository.Source = $Source
        $CatalogPayload.Repository.Name = $Name
        $CatalogPayload.Repository.Description = $Description
        $CatalogPayload.Repository.RepositoryType = $RepositoryType
        $CatalogPayload.Repository.DomainName = $DomainName
        $CatalogPayload.Repository.Username = $Username
        if ($Password) {
            $CatalogPayload.Repository.Password = (New-Object PSCredential "user", $Password).GetNetworkCredential().Password
        }
        $CatalogPayload.Repository.CheckCertificate = $CheckCertificate.IsPresent
        $CatalogPayload = $CatalogPayload | ConvertTo-Json -Depth 6
        # Do not output the payload with the plain text password
        # Write-Verbose $CatalogPayload

        $CatalogResponse = Invoke-WebRequest -Uri $CatalogURL -UseBasicParsing -Headers $Headers -ContentType $Type -Method POST -Body $CatalogPayload
        Write-Verbose "Creating Catalog..."
        if ($CatalogResponse.StatusCode -eq 201) {
            #$CatalogData = $CatalogResponse.Content | ConvertFrom-Json
            if ($Wait) {
                Start-Sleep -s $WaitTime
                $CatalogResponse = Invoke-WebRequest -Uri $CatalogURL -UseBasicParsing -Headers $Headers -ContentType $Type -Method GET
                $CatalogInfo = $CatalogResponse | ConvertFrom-Json
                foreach ($catalog in $CatalogInfo.'value') {
                    if ($catalog.'Repository'.'Source' -eq $Source -and $catalog.'SourcePath' -eq $SourcePath) {
                        #$repoId = [uint64]$catalog.'Repository'.'Id'
                        #$catalog_id = [uint64]$catalog.'Id'
                        return $catalog
                    }
                }
            }
        }
        else {
            Write-Error "Catalog creation failed..."
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

