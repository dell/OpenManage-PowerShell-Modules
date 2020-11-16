using module ..\..\Classes\Group.psm1

function Get-OMEDevice {
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
    Get-OMEDevice -Value 12016
    Get device by Id
.EXAMPLE
    "FVKGSWZ" | Get-OMEDevice -FilterBy "ServiceTag" | Format-Table
    Get device by Service Tag
.EXAMPLE
    10097, 10100 | Get-OMEDevice -FilterBy "Id" | Format-Table
    Get multiple devices by Id
.EXAMPLE
    "C86F0Q2", "3XMHHL2" | Get-OMEDevice | Format-Table
    Get multiple devices by Service Tag
.EXAMPLE
    "R620-FVKGSW2.example.com" | Get-OMEDevice -FilterBy "Name" | Format-Table
    Get device by name
.EXAMPLE
    "PowerEdge R640" | Get-OMEDevice -FilterBy "Model" | Format-Table
    Get device by model
.EXAMPLE
    "Servers_Win" | Get-OMEGroup | Get-OMEDevice | Format-Table
    Get devices by group
.EXAMPLE
    Get-OMEDevice -Group $(Get-OMEGroup "Servers_Win") | Format-Table
    Get devices by group inline
.EXAMPLE
    "Servers_ESXi", "Servers_Win" | Get-OMEGroup | Get-OMEDevice | Format-Table
    Get devices from multiple groups
#>

[CmdletBinding()]
param(
    [Parameter(Mandatory=$false, ValueFromPipeline)]
    [String[]]$Value,

    [Parameter(Mandatory=$false, ValueFromPipeline)]
    [Group[]]$Group,

    [Parameter(Mandatory=$false)]
    [ValidateSet("Name", "Id", "ServiceTag", "Model", "Type")]
    [String]$FilterBy = "ServiceTag"
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
        $NextLinkUrl = $null
        $Type        = "application/json"
        $Headers     = @{}
        $FilterMap = @{
            'Name'='DeviceName'
            'Id'='Id'
            'ServiceTag'='DeviceServiceTag'
            'Model'='Model'
            'Type'='Type'
        }
        #'NetworkAddress'='NetworkAddress' # Doesn't work
        $FilterExpr  = $FilterMap[$FilterBy]

        $Headers."X-Auth-Token" = $SessionAuth.Token
        $DeviceData = @()

        # 
        # ValueFromPipeline will attempt to dynamically match the data piped in to a Type. 
        # [String] is a catch-all so we want to process that last as all Types can be converted to a string.
        #
        if ($Group.Count -gt 0) { # Filter Devices by Group
            $GroupUrl = "https://$($SessionAuth.Host)/api/GroupService/Groups"
            $GroupUrl += "(" + [String]($Group.Id) + ")/Devices"
            $GroupResp = Invoke-WebRequest -Uri $GroupUrl -UseBasicParsing -Method Get -Headers $Headers -ContentType $Type
            if ($GroupResp.StatusCode -eq 200) {
                $GroupInfo = $GroupResp.Content | ConvertFrom-Json
                $GroupData = $GroupInfo.'value'
                $DeviceCount = $GroupInfo.'@odata.count'
                if ($DeviceCount -gt 0) {
                    foreach ($Device in $GroupData) {
                        $DeviceData += New-DeviceFromJson -Device $Device
                    }
                    $currDeviceCount = $GroupData.Count
                    if($DeviceCount -gt $currDeviceCount){
                        $delta = $DeviceCount-$currDeviceCount 
                        $RemainingDeviceUrl = $GroupUrl+"?`$skip=$($currDeviceCount)&`$top=$($delta)"
                        $RemainingDeviceResp = Invoke-WebRequest -Uri $RemainingDeviceUrl -UseBasicParsing -Method Get -Headers $Headers -ContentType $Type
                        if($RemainingDeviceResp.StatusCode -eq 200){
                            $RemainingDeviceInfo = $RemainingDeviceResp.Content | ConvertFrom-Json
                            foreach ($Device in $RemainingDeviceInfo.'value') {
                                $DeviceData += New-DeviceFromJson -Device $Device
                            }
                        }
                    }
                }
                else {
                    Write-Verbose "No devices found in group ($($Group.Name))"
                }
            }
            else {
                Write-Warning "Unable to retrieve devices for group ($($Group.Name))"
            }
        }
        else { # Filter Devices directly
            $DeviceCountUrl = $BaseUri + "/api/DeviceService/Devices"
            if ($Value) { # Filter By 
                if ($FilterBy -eq 'Id' -or $FilterBy -eq 'Type') {
                    $DeviceCountUrl += "?`$filter=$($FilterExpr) eq $($Value)"
                }
                else {
                    $DeviceCountUrl += "?`$filter=$($FilterExpr) eq '$($Value)'"
                }
            }
            $DeviceResponse = Invoke-WebRequest -Uri $DeviceCountUrl -UseBasicParsing -Method Get -Headers $Headers -ContentType $Type
            if ($DeviceResponse.StatusCode -eq 200)
            {
                $DeviceCountData = $DeviceResponse.Content | ConvertFrom-Json
                foreach ($Device in $DeviceCountData.'value') {
                    $DeviceData += New-DeviceFromJson -Device $Device
                }
                if($DeviceCountData.'@odata.nextLink')
                {
                    $NextLinkUrl = $BaseUri + $DeviceCountData.'@odata.nextLink'
                }
                while($NextLinkUrl)
                {
                    $NextLinkResponse = Invoke-WebRequest -Uri $NextLinkUrl -UseBasicParsing -Method Get -Headers $Headers -ContentType $Type
                    if($NextLinkResponse.StatusCode -eq 200)
                    {
                        $NextLinkData = $NextLinkResponse.Content | ConvertFrom-Json
                        foreach ($Device in $NextLinkData.'value') {
                            $DeviceData += New-DeviceFromJson -Device $Device
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

            
        }
        return $DeviceData 
    } 
    Catch {
        Write-Error ($_.ErrorDetails)
        Write-Error ($_.Exception | Format-List -Force | Out-String) 
        Write-Error ($_.InvocationInfo | Format-List -Force | Out-String)
    }
}

End {}

}

