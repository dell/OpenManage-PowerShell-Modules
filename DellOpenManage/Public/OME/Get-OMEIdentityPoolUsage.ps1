using module ..\..\Classes\IdentityPool.psm1
function Get-OMEIdentityPoolUsage {
<#
_author_ = Trevor Squillario <Trevor.Squillario@Dell.com>

Copyright (c) 2021 Dell EMC Corporation

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
   Script to get the list of virtual addresses in an Identity Pool
 .DESCRIPTION

   This script uses the OME REST API to get a list of virtual addresses in an Identity Pool.
   Will export to a CSV file called Get-IdentityPoolUsage.csv in the current directory
   For authentication X-Auth is used over Basic Authentication
   Note that the credentials entered are not stored to disk.

 .PARAMETER IpAddress
   This is the IP address of the OME Appliance
 .PARAMETER Id
   This is the Identity Pool Id
 .PARAMETER OutFile
   This is the full path to output the CSV file

 .EXAMPLE
   11 | Get-OMEIdentityPool -FilterBy "Id" | Get-OMEIdentityPoolUsage -Verbose

   Get identity pool by Id
 .EXAMPLE
   "Pool01" | Get-OMEIdentityPool | Get-OMEIdentityPoolUsage -Verbose

   Get identity pool by name
#>
    [CmdletBinding()]
    param(
        [Parameter(Mandatory, ValueFromPipeline)]
        [IdentityPool] $IdentityPool
    )

    if(!$SessionAuth.Token){
        Write-Error "Please use Connect-OMEServer first"
        Break
        Return
    }

    Try {
        if ($SessionAuth.IgnoreCertificateWarning) { Set-CertPolicy }
        $BaseUri = "https://$($SessionAuth.Host)"
        $Headers = @{}
        $Headers."X-Auth-Token" = $SessionAuth.Token

        $Id = $IdentityPool.Id

        # Get Identity Pool Usage Sets
        $IdentityPoolUsageSetUrl = $BaseUri + "/api/IdentityPoolService/IdentityPools($($Id))/UsageIdentitySets"
        $IdentityPoolUsageSetResp = Invoke-WebRequest -Uri $IdentityPoolUsageSetUrl -Method Get -Headers $Headers -ContentType $Type
        if ($IdentityPoolUsageSetResp.StatusCode -eq 200) {
            $IdentityPoolUsageSetRespData = $IdentityPoolUsageSetResp.Content | ConvertFrom-Json
            $IdentityPoolUsageSetRespData = $IdentityPoolUsageSetRespData.'value'

            $DeviceData = @()
            # Loop through Usage Sets using Id to get Details
            foreach ($IdentitySet in $IdentityPoolUsageSetRespData) {    
                $IdentitySetId = $IdentitySet.IdentitySetId
                $IdentitySetName = $IdentitySet.Name

                $IdentityPoolUsageDetailUrl = $BaseUri + "/api/IdentityPoolService/IdentityPools($($Id))/UsageIdentitySets($($IdentitySetId))/Details"
                $IdentityPoolUsageDetailResp = Invoke-WebRequest -Uri $IdentityPoolUsageDetailUrl -Method Get -Headers $Headers -ContentType $Type
                if ($IdentityPoolUsageDetailResp.StatusCode -eq 200) {
                    $IdentityPoolUsageDetailData = $IdentityPoolUsageDetailResp.Content | ConvertFrom-Json
                    # Loop through Details appending to object array
                    foreach ($DeviceEntry in $IdentityPoolUsageDetailData.'value') {
                        $DeviceDetails = @{
                            IdentityType  = $IdentitySetName
                            ChassisName   = $DeviceEntry.DeviceInfo.ChassisName
                            ServerName    = $DeviceEntry.DeviceInfo.ServerName
                            ManagementIp  = $DeviceEntry.DeviceInfo.ManagementIp
                            NicIdentifier = $DeviceEntry.NicIdentifier
                            MacAddress    = $DeviceEntry.MacAddress
                        }
                        $DeviceData += New-Object PSObject -Property $DeviceDetails 
                    }

                    # Check if there are multiple pages in response
                    if ($IdentityPoolUsageDetailData.'@odata.nextLink') {
                        $NextLinkUrl = $BaseUri + $IdentityPoolUsageDetailData.'@odata.nextLink'
                    }
                    # Loop through pages until end
                    while ($NextLinkUrl) {
                        $IdentityPoolUsageDetailNextLinkResp = Invoke-WebRequest -Uri $NextLinkUrl -Method Get -Headers $Headers -ContentType $Type
                        if ($IdentityPoolUsageDetailNextLinkResp.StatusCode -eq 200) {
                            $IdentityPoolUsageDetailNextLinkData = $IdentityPoolUsageDetailNextLinkResp.Content | ConvertFrom-Json
                            # Loop through Details appending to object array
                            foreach ($DeviceEntry in $IdentityPoolUsageDetailNextLinkData.'value') {
                                $DeviceDetails = @{
                                    IdentityType  = $IdentitySetName
                                    ChassisName   = $DeviceEntry.DeviceInfo.ChassisName
                                    ServerName    = $DeviceEntry.DeviceInfo.ServerName
                                    ManagementIp  = $DeviceEntry.DeviceInfo.ManagementIp
                                    NicIdentifier = $DeviceEntry.NicIdentifier
                                    MacAddress    = $DeviceEntry.MacAddress
                                }
                                $DeviceData += New-Object PSObject -Property $DeviceDetails 
                            }
                            # Set for nextLink for next iteration
                            if ($IdentityPoolUsageDetailNextLinkData.'@odata.nextLink') {
                                $NextLinkUrl = $BaseUri + $IdentityPoolUsageDetailNextLinkData.'@odata.nextLink'
                            }
                            else { 
                                $NextLinkUrl = $null
                            }
                        }
                        else {
                            $NextLinkUrl = $null
                            Write-Error "Unable to retrieve items from nextLink... Exiting"
                        }
                    }
                }
                else {
                    Write-Error "Unable to get identity pools... Exiting"
                }
            }

            # Return table
            return $DeviceData
        }
        
        else {
            Write-Error "Unable to create a session with appliance $($BaseUri)"
        }
    }
    Catch {
        Resolve-Error $_
    }

}