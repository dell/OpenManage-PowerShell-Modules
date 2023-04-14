using module ..\..\Classes\Device.psm1

function Get-QuickDeployPayload($Name, [SecureString]$RootPassword, $SlotType, $DeviceId, $IPv4Enabled, $IPv4NetworkType, $IPv4SubnetMask, $IPv4Gateway, $IPv6Enabled, $IPv6NetworkType, $IPv6Gateway, $IPv6PrefixLength, $Slots) {
    $Payload = '{
        "Id": 0,
        "JobName": "Quick Deploy Task 1",
        "JobDescription": "Quick Deploy Task",
        "Schedule": "startnow",
        "State": "Enabled",
        "JobType": {
            "Id": 42,
            "Name": "QuickDeploy_Task"
        },
        "Params": [
            {
                "Key": "operationName",
                "Value": "SERVER_QUICK_DEPLOY"
            },
            {
                "Key": "deviceId",
                "Value": "1016"
            },
            {
                "Key": "rootCredential",
                "Value": "calvin"
            },
            {
                "Key": "protocolTypeV4",
                "Value": "true"
            },
            {
                "Key": "protocolTypeV6",
                "Value": "false"
            }
        ]
    }' | ConvertFrom-Json

    $Payload.JobName = $Name

    $ParamsHashValMap = @{
        "operationName" = $(if ($SlotType -eq "IOM") { "IOM_QUICK_DEPLOY" } else { "SERVER_QUICK_DEPLOY"})
        "deviceId" = $DeviceId.ToString()
        "rootCredential" = $(if ($RootPassword) {
            $PasswordText = (New-Object PSCredential "user", $RootPassword).GetNetworkCredential().Password
            $PasswordText
        })
        "protocolTypeV4" = $(if ($IPv4Enabled) { "true" } else { "false"})
        "protocolTypeV6" = $(if ($IPv6Enabled) { "true" } else { "false"})
    }

    # Update Params from ParamsHashValMap
    for ($i = 0; $i -le $Payload.'Params'.Length; $i++) {
        if ($ParamsHashValMap.Keys -Contains ($Payload.'Params'[$i].'Key')) {
            $value = $Payload.'Params'[$i].'Key'
            $Payload.'Params'[$i].'Value' = $ParamsHashValMap.$value
        }
    }

    # Add Params if IPv4 is enabled
    if ($IPv4Enabled) {
        $ParamNetworkTypeV4 = @{
            "Key" = "networkTypeV4"
            "Value" = $(if ($IPv4NetworkType -eq "STATIC") { "Static" } else { "DHCP"})
        }
        $Payload.Params += $ParamNetworkTypeV4
        $ParamSubnetMaskV4 = @{
            "Key" = "subnetMaskV4"
            "Value" = $IPv4SubnetMask
        }
        $Payload.Params += $ParamSubnetMaskV4
        $ParamGatewayV4 = @{
            "Key" = "gatewayV4"
            "Value" = $IPv4Gateway
        }
        $Payload.Params += $ParamGatewayV4
    }

    # Add Params if IPv6 is enabled
    if ($IPv6Enabled) {
        $ParamNetworkTypeV6 = @{
            "Key" = "networkTypeV6"
            "Value" = $(if ($IPv6NetworkType -eq "STATIC") { "Static" } else { "DHCP"})
        }
        $Payload.Params += $ParamNetworkTypeV6
        if ($IPv6NetworkType -eq "STATIC") {
            $ParamGatewayV6 = @{
                "Key" = "gatewayV6"
                "Value" = $IPv6Gateway
            }
            $Payload.Params += $ParamGatewayV6
            $ParamPrefixLength = @{
                "Key" = "prefixLength"
                "Value" = $IPv6PrefixLength.ToString()
            }
            $Payload.Params += $ParamPrefixLength
        }
    }

    # Add Slot params
    [int]$SlotTypeInt = 1000
    if ($SlotType -eq "IOM") { $SlotTypeInt = 4000 }
    if ($SlotType -eq "SLED") { $SlotTypeInt = 1000 }

    foreach($Slot in $Slots) {
        $SlotNumber = $Slot["Slot"];
        $SlotIPv4Address = $Slot["IPv4Address"];
        $SlotIPv6Address = $Slot["IPv6Address"];
        $SlotVlanId = $(if ($null -eq $Slot["VlanId"]) { 1 } else { $Slot["VlanId"] });
        $SlotParam = @{
            "Key" = "SlotId=${SlotNumber}"
            "Value" = "SlotSelected=true;SlotType=${SlotTypeInt};IPV4Address=${SlotIPv4Address};IPV6Address=${SlotIPv6Address};VlanId=${SlotVlanId}"
        }
        $Payload.Params += $SlotParam
    }

    return $Payload
}

function Invoke-OMEQuickDeploy {
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
    Invoke quick deploy job on chassis slots
.DESCRIPTION
.PARAMETER Name
    Name of the quick deploy job
.PARAMETER Chassis
    Object of type Device returned from Get-OMEDevice function. Must be a Chassis device type.
.PARAMETER RootPassword
    SecureString containing the root password
.PARAMETER SlotType
    String to represent the slot type (Default="SLED", "IOM")
.PARAMETER IPv4Enabled
    Switch to enable IPv4
.PARAMETER IPv4NetworkType
    String to determine the network type (Default="DHCP", "STATIC")
.PARAMETER IPv4SubnetMask
    String representing the IPv4 subnet mask
.PARAMETER IPv4Gateway
    String representing the IPv4 gateway
.PARAMETER IPv6Enabled
    Switch to enable IPv6
.PARAMETER IPv6NetworkType
    String to determine the network type (Default="DHCP", "STATIC")
.PARAMETER IPv6Gateway
    String representing the IPv6 gateway
.PARAMETER IPv6PrefixLength
    String representing the IPv6 prefix length
.PARAMETER Slots
    Array of PSCustomObject (Hashtable) containing slot quick deploy settings. Example: $Settings = @(@{Slot=1; IPv4Address="192.169.1.100"; IPv6Address="2001:0db8:85a3:0000:0000:8a2e:0370:7334"; VlanId=1})
.PARAMETER Wait
    Wait for job to complete
.PARAMETER WaitTime
    Time, in seconds, to wait for the job to complete
.INPUTS
    Device
.EXAMPLE
    Invoke-OMEQuickDeploy -RootPassword $(ConvertTo-SecureString 'calvin' -AsPlainText -Force) -SlotType "SLED" -Chassis $("C38V9ZZ" | Get-OMEDevice) -IPv4Enabled -IPv4NetworkType "DHCP" -Slots @(@{Slot=1;},@{Slot=2;}) -Wait -Verbose
    Quick Deploy sleds in slot 1 and 2 using DHCP. See README for more examples.
#>

[CmdletBinding()]
param(
    [Parameter(Mandatory=$false)]
    [String]$Name = "Quick Deploy Task Device $((Get-Date).ToString('yyyyMMddHHmmss'))",

    [Parameter(Mandatory=$false, ValueFromPipeline)]
    [Device]$Chassis,

    [Parameter(Mandatory)]
    [SecureString]$RootPassword,

    [Parameter(Mandatory)]
    [ValidateSet("SLED", "IOM")]
    [String]$SlotType = "SLED",

    [Parameter(Mandatory=$false)]
    [Switch]$IPv4Enabled,

    [Parameter(Mandatory=$false)]
    [ValidateSet("STATIC", "DHCP")]
    [String]$IPv4NetworkType = "DHCP",

    [Parameter(Mandatory=$false)]
    [String]$IPv4SubnetMask,

    [Parameter(Mandatory=$false)]
    [String]$IPv4Gateway,

    [Parameter(Mandatory=$false)]
    [Switch]$IPv6Enabled,

    [Parameter(Mandatory=$false)]
    [ValidateSet("STATIC", "DHCP")]
    [String]$IPv6NetworkType = "DHCP",

    [Parameter(Mandatory=$false)]
    [String]$IPv6Gateway,

    [Parameter(Mandatory=$false)]
    [int]$IPv6PrefixLength,

    [Parameter(Mandatory)]
    [PSCustomObject[]]$Slots,

    [Parameter(Mandatory=$false)]
    [Switch]$Wait,

    [Parameter(Mandatory=$false)]
    [int]$WaitTime = 3600
)


Begin {}
Process {
    if (!$(Confirm-IsAuthenticated)){
        Return
    }
    Try {
        if ($SessionAuth.IgnoreCertificateWarning) { Set-CertPolicy }
        $BaseUri = "https://$($SessionAuth.Host)"
        $Type  = "application/json"
        $Headers = @{}
        $Headers."X-Auth-Token" = $SessionAuth.Token

        $DeviceId = $Chassis.Id
        if ($Chassis.Type -eq 2000) {
            $JobPayload = Get-QuickDeployPayload -Name $Name -RootPassword $RootPassword -SlotType $SlotType -DeviceId $DeviceId `
                -IPv4Enabled $IPv4Enabled -IPv4NetworkType $IPv4NetworkType -IPv4SubnetMask $IPv4SubnetMask -IPv4Gateway $IPv4Gateway `
                -IPv6Enabled $IPv6Enabled -IPv6NetworkType $IPv6NetworkType -IPv6Gateway $IPv6Gateway -IPv6PrefixLength $IPv6PrefixLength `
                -Slots $Slots
            
            # Submit job
            $JobURL = $BaseUri + "/api/JobService/Jobs"
            $JobPayload = $JobPayload | ConvertTo-Json -Depth 6
            #Write-Verbose $JobPayload
            $JobResp = Invoke-WebRequest -Uri $JobURL -UseBasicParsing -Headers $Headers -ContentType $Type -Method POST -Body $JobPayload
            if ($JobResp.StatusCode -eq 201) {
                Write-Verbose "Job creation successful..."
                $JobInfo = $JobResp.Content | ConvertFrom-Json
                $JobId = $JobInfo.Id
                Write-Verbose "Created job $($JobId) for quick deploy..."
                if ($Wait) {
                    $JobStatus = $($JobId | Wait-OnJob -WaitTime $WaitTime)
                    return $JobStatus
                } else {
                    return $JobId
                }
            }
            else {
                Write-Error "Job creation failed"
            }
        } else {
            throw [System.Exception]::new("DeviceException", "Device must be of type Chassis")
        }
    }
    Catch {
        Resolve-Error $_
    }
}

End {}

}