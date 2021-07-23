
function New-OMEIdentityPool {
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
    Create new Identity Pool in OpenManage Enterprise
.DESCRIPTION
    
.PARAMETER Name
    
.PARAMETER Description
    Description of IdentityPool
.INPUTS
    None
.EXAMPLE
    New-OMEIdentityPool -Name "Test IdentityPool 01"
    Create a new static IdentityPool
#>

[CmdletBinding()]
param(
    [Parameter(Mandatory)]
    [String]$Name,

    [Parameter(Mandatory=$false)]
    [Int]$EthernetSettings_IdentityCount,

    [Parameter(Mandatory=$false)]
    [String]$EthernetSettings_StartingMacAddress,

    [Parameter(Mandatory=$false)]
    [Int]$IscsiSettings_IdentityCount,

    [Parameter(Mandatory=$false)]
    [String]$IscsiSettings_StartingMacAddress,

    [Parameter(Mandatory=$false)]
    [String]$IscsiSettings_InitiatorConfig_IqnPrefix,

    [Parameter(Mandatory=$false)]
    [String]$IscsiSettings_InitiatorIpPoolSettings_IpRange,

    [Parameter(Mandatory=$false)]
    [String]$IscsiSettings_InitiatorIpPoolSettings_SubnetMask,

    [Parameter(Mandatory=$false)]
    [String]$IscsiSettings_InitiatorIpPoolSettings_Gateway,

    [Parameter(Mandatory=$false)]
    [String]$IscsiSettings_InitiatorIpPoolSettings_PrimaryDnsServer,

    [Parameter(Mandatory=$false)]
    [String]$IscsiSettings_InitiatorIpPoolSettings_SecondaryDnsServer,

    [Parameter(Mandatory=$false)]
    [Int]$FcoeSettings_IdentityCount,

    [Parameter(Mandatory=$false)]
    [String]$FcoeSettings_StartingMacAddress,

    [Parameter(Mandatory=$false)]
    [Int]$FcSettings_Wwnn_IdentityCount,

    [Parameter(Mandatory=$false)]
    [String]$FcSettings_Wwnn_StartingAddress
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
        $IdentityPoolURL = $BaseUri + "/api/IdentityPoolService/IdentityPools"
        $ContentType = "application/json"
        $Headers = @{}
        $Headers."X-Auth-Token" = $SessionAuth.Token

        $IdentityPoolPayload = '{
            "Name": "IdentityPool 01",
            "EthernetSettings": {"Mac": {"IdentityCount": "", "StartingMacAddress": "qrvM3eIA"}},
            "IscsiSettings": {"Mac": {"IdentityCount": "", "StartingMacAddress": "qrvM3eMA"},
                "InitiatorConfig": {"IqnPrefix": ""},
                "InitiatorIpPoolSettings": {
                    "IpRange": "",
                    "SubnetMask": "",
                    "Gateway": "",
                    "PrimaryDnsServer": "",
                    "SecondaryDnsServer": ""
                }},
            "FcoeSettings": {"Mac": {"IdentityCount": "", "StartingMacAddress": "qrvM3eQA"}},
            "FcSettings": {
                "Wwnn": {"IdentityCount": "", "StartingAddress": "IACqu8zd5QA="}, 
                "Wwpn": {"IdentityCount": "", "StartingAddress": "IAGqu8zd5QA="}
            }
        }' | ConvertFrom-Json
        $IdentityPoolPayload.Name = $Name
        if ($EthernetSettings_IdentityCount -gt 0) {
            $IdentityPoolPayload.EthernetSettings.Mac.IdentityCount = $EthernetSettings_IdentityCount
            $IdentityPoolPayload.EthernetSettings.Mac.StartingMacAddress = $EthernetSettings_StartingMacAddress | Convert-MacAddressToBase64
        } else {
            $IdentityPoolPayload.EthernetSettings = $null
        }
        if ($IscsiSettings_IdentityCount -gt 0) {
            $IdentityPoolPayload.IscsiSettings.Mac.IdentityCount = $IscsiSettings_IdentityCount
            $IdentityPoolPayload.IscsiSettings.Mac.StartingMacAddress = $IscsiSettings_StartingMacAddress | Convert-MacAddressToBase64
            $IdentityPoolPayload.IscsiSettings.InitiatorConfig.IqnPrefix = $IscsiSettings_InitiatorConfig_IqnPrefix
            $IdentityPoolPayload.IscsiSettings.InitiatorIpPoolSettings.IpRange = $IscsiSettings_InitiatorIpPoolSettings_IpRange
            $IdentityPoolPayload.IscsiSettings.InitiatorIpPoolSettings.SubnetMask = $IscsiSettings_InitiatorIpPoolSettings_SubnetMask
            $IdentityPoolPayload.IscsiSettings.InitiatorIpPoolSettings.Gateway = $IscsiSettings_InitiatorIpPoolSettings_Gateway
            $IdentityPoolPayload.IscsiSettings.InitiatorIpPoolSettings.PrimaryDnsServer = $IscsiSettings_InitiatorIpPoolSettings_PrimaryDnsServer
            $IdentityPoolPayload.IscsiSettings.InitiatorIpPoolSettings.SecondaryDnsServer = $IscsiSettings_InitiatorIpPoolSettings_SecondaryDnsServer
        } else {
            $IdentityPoolPayload.IscsiSettings = $null
        }
        if ($FcoeSettings_IdentityCount -gt 0) {
            $IdentityPoolPayload.FcoeSettings.Mac.IdentityCount = $FcoeSettings_IdentityCount
            $IdentityPoolPayload.FcoeSettings.Mac.StartingMacAddress = $FcoeSettings_StartingMacAddress | Convert-MacAddressToBase64
        } else {
            $IdentityPoolPayload.FcoeSettings = $null
        }
        if ($FcSettings_Wwnn_IdentityCount -gt 0) {
            # The Wwnn and Wwpn are set to the same value so we only need to use one parameter for this
            $IdentityPoolPayload.FcSettings.Wwnn.IdentityCount = $FcSettings_Wwnn_IdentityCount
            $IdentityPoolPayload.FcSettings.Wwnn.StartingAddress = $("20:00:" + $FcSettings_Wwnn_StartingAddress) | Convert-MacAddressToBase64
            $IdentityPoolPayload.FcSettings.Wwpn.IdentityCount = $FcSettings_Wwnn_IdentityCount
            $IdentityPoolPayload.FcSettings.Wwpn.StartingAddress = $("20:01:" + $FcSettings_Wwnn_StartingAddress) | Convert-MacAddressToBase64
        } else {
            $IdentityPoolPayload.FcSettings = $null
        }
        
        $IdentityPoolPayload = $IdentityPoolPayload | ConvertTo-Json -Depth 6
        Write-Verbose $IdentityPoolPayload

        $IdentityPoolResponse = Invoke-WebRequest -Uri $IdentityPoolURL -UseBasicParsing -Headers $Headers -ContentType $ContentType -Method POST -Body $IdentityPoolPayload
        Write-Verbose "Creating IdentityPool..."
        if ($IdentityPoolResponse.StatusCode -eq 201) {
            return $IdentityPoolResponse.Content | ConvertFrom-Json
        }
        else {
            Write-Error "IdentityPool creation failed..."
        }
    }
    Catch {
        Resolve-Error $_
    }
}

End {}

}

