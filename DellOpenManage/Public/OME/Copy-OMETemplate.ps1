using module ..\..\Classes\Template.psm1

function Get-TemplateVlan($BaseUri, $ContentType, $Headers, $Template) {
    $TemplateVlanPayload = '{
        "TemplateId" : 0,
        "IdentityPoolId": 0,
        "BondingTechnology" : "",
        "VlanAttributes": []
    }'
    $TemplateVlanPayload = $TemplateVlanPayload | ConvertFrom-Json
    $NETWORK_HIERARCHY_VIEW = 4  # For Network hierarchy View in a Template
    $TemplateVlanUrl = $BaseUri + "/api/TemplateService/Templates($($Template.Id))/Views($($NETWORK_HIERARCHY_VIEW))/AttributeViewDetails"
    $TemplateVlanResponse = Invoke-WebRequest -Uri $TemplateVlanUrl -UseBasicParsing -Method Get -ContentType $ContentType -Headers $Headers
    if ($TemplateVlanResponse.StatusCode -eq 200) {
        $TemplateVlans = $TemplateVlanResponse.Content | ConvertFrom-Json
        $NICGroups = @()
        $NICBondingList = @()
        $NICBondingTech = ""
        $VlanAttributes = @()
        # Get NICs and Bonding
        foreach ($AttributeGroup in $TemplateVlans.AttributeGroups) {
            if ($AttributeGroup.DisplayName -eq "NICModel") {
                $NICGroups = $AttributeGroup.SubAttributeGroups
            }
            if ($AttributeGroup.DisplayName -eq "NicBondingTechnology") {
                $NICBondingList = $AttributeGroup.Attributes
                foreach ($NICBond in $NICBondingList) {
                    if ($NICBond.DisplayName.ToLower() -eq "nic bonding technology") {
                        $NICBondingTech = $NICBond.Value
                    }
                }
            }
        }
        # Loop through NICs to build VLAN mapping
        foreach ($NIC in $NICGroups) {
            $NICDisplayName = $NIC.DisplayName
            foreach ($NICPort in $NIC.SubAttributeGroups) {
                $NICPortDisplayName = "$($NICPort.DisplayName)$($NICPort.GroupNameId)"
                foreach ($NICPartition in $NICPort.SubAttributeGroups) {
                    $Untagged = 0
                    $Tagged = @()
                    $ComponentId = 0
                    $IsNicBonded = $false
                    $DisplayName = "$($NICDisplayName) $($NICPortDisplayName) $($NICPartition.DisplayName) $($NICPartition.GroupNameId)"
                    foreach ($NICPartitionAttribute in $NICPartition.Attributes) {
                        $ComponentId = $NICPartitionAttribute.CustomId
                        if ($NICPartitionAttribute.DisplayName.ToLower() -eq "vlan untagged") {
                            $Untagged = [int]$NICPartitionAttribute.Value
                        }
                        if ($NICPartitionAttribute.DisplayName.ToLower() -eq "vlan tagged") {
                            if ($NICPartitionAttribute.Value) {
                                $TaggedString = $NICPartitionAttribute.Value.Replace(" ", "")
                                $Tagged = $TaggedString.Split(",")
                            }
                        }
                        if ($NICPartitionAttribute.DisplayName.ToLower() -eq "nic bonding enabled") {
                            if ($NICPartitionAttribute.Value -eq "false") {
                                $IsNicBonded = $false
                            }
                            if ($NICPartitionAttribute.Value -eq "true") {
                                $IsNicBonded = $true
                            }
                        }
                    }
                    $VlanAttribute = [PSCustomObject]@{
                        Untagged = $Untagged
                        Tagged = $Tagged
                        ComponentId = $ComponentId
                        IsNicBonded = $IsNicBonded
                        DisplayName = $DisplayName
                    }
                    $VlanAttributes += $VlanAttribute
                }
            }
        }

        # Build payload
        $TemplateVlanPayload.TemplateId = $Template.Id
        $TemplateVlanPayload.IdentityPoolId = $Template.IdentityPoolId
        $TemplateVlanPayload.BondingTechnology = $NICBondingTech
        #$TemplateVlanPayload.PropagateVlan = $Template.PropagateVlan
        $TemplateVlanPayload.VlanAttributes = $VlanAttributes
        return $TemplateVlanPayload
    }
}

function Get-TemplateVlanPayload ($SourcePayload, $DestinationPayload) {
    # Copy attributes from cloned template to source template to be used when updating template network config
    $SourcePayload.TemplateId = $DestinationPayload.TemplateId
    foreach ($SourceVlanAttribute in $SourcePayload.VlanAttributes) {
        # Get ComponentId from the cloned destination template 
        $DestinationComponentId = $DestinationPayload.VlanAttributes | Where-Object -Property "DisplayName" -EQ $SourceVlanAttribute.DisplayName | Select-Object -ExpandProperty "ComponentId"
        $SourceVlanAttribute.ComponentId = $DestinationComponentId
        # Remove property. This is used to maintain proper mapping of NIC ports
        $SourceVlanAttribute.PSObject.Properties.Remove('DisplayName')
    }
    return $SourcePayload
}

function Copy-OMETemplate {
<#
Copyright (c) 2022 Dell EMC Corporation

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
    Clone template in OpenManage Enterprise. ***Only supports Deployment templates
.DESCRIPTION
.PARAMETER Name
    String that will be assigned the name of the template
.PARAMETER Template
    Single Template object returned from Get-OMEDevice function. Only supports Deployment templates
.PARAMETER All
    Clone all template attributes including Identity Pool, VLANs and Teaming
.INPUTS
    [Template]Template
.OUTPUTS
    [int]TemplateId
.EXAMPLE
    "TestTemplate01" | Get-OMETemplate | Copy-OMETemplate

    Clone template using default name "TestTemplate01 - Clone"
.EXAMPLE
    $(Get-OMETemplate | Where-Object -Property "Name" -EQ "TestTemplate") | Copy-OMETemplate

    Clone template using default name "TestTemplate01 - Clone" when multiple templates with similar names exist
.EXAMPLE
    "TestTemplate01" | Get-OMETemplate | Copy-OMETemplate -Name "TestTemplate02"

    Clone template and specify new name
.EXAMPLE
    "TestTemplate01" | Get-OMETemplate | Copy-OMETemplate -All

    Clone template including Identity Pool, VLANs and Teaming
#>

[CmdletBinding()]
param(
    [Parameter(Mandatory,ValueFromPipeline)]
    [Template]$Template,

    [Parameter(Mandatory=$false)]
    [String]$Name = "",

    [Parameter(Mandatory=$false)]
    [Switch]$All
)

Begin {}
Process {
    if (!$(Confirm-IsAuthenticated)){
        Return
    }
    Try {
        if ($SessionAuth.IgnoreCertificateWarning) { Set-CertPolicy }
        $BaseUri = "https://$($SessionAuth.Host)"
        $ContentType        = "application/json"
        $Headers     = @{}
        $Headers."X-Auth-Token" = $SessionAuth.Token
        $TemplateUrl = $BaseUri + "/api/TemplateService/Actions/TemplateService.Clone"
        $TemplatePayload = '{
            "SourceTemplateId" : 0,
            "ViewTypeId": 0,
            "NewTemplateName" : "Clone Template"
        }'
        $TemplatePayload = $TemplatePayload | ConvertFrom-Json
        if ($Name -eq "") {
            $TemplatePayload.NewTemplateName = "$($Template.Name) - Copy"
        } else {
            $TemplatePayload.NewTemplateName = $Name
        }
        $TemplatePayload.SourceTemplateId = $Template.Id
        $TemplatePayload.ViewTypeId = $Template.ViewTypeId
        $TemplatePayload = $TemplatePayload | ConvertTo-Json -Depth 6
        Write-Verbose $TemplatePayload
        $NewTemplateId = $null
        Write-Verbose "Clone Template..."
        $TemplateResponse = Invoke-WebRequest -Uri $TemplateUrl -UseBasicParsing -Method Post -Body $TemplatePayload -ContentType $ContentType -Headers $Headers
        if ($TemplateResponse.StatusCode -eq 200) {
            $NewTemplateId = [int]$TemplateResponse.Content
            Write-Verbose "Clone Template Success - Id $($NewTemplateId)"
        }
        if ($All) {
            $SourceTemplateVlanPayload = $(Get-TemplateVlan -BaseUri $BaseUri -ContentType $ContentType -Headers $Headers -Template $Template)
            $NewTemplate = $NewTemplateId | Get-OMETemplate -FilterBy "Id"
            $DestinationTemplateVlanPayload = $(Get-TemplateVlan -BaseUri $BaseUri -ContentType $ContentType -Headers $Headers -Template $NewTemplate)
            #Write-Verbose $($SourceTemplateVlanPayload | ConvertTo-Json -Depth 6)
            #Write-Verbose $($DestinationTemplateVlanPayload | ConvertTo-Json -Depth 6)
            $CloneTemplateVlanPayload = $(Get-TemplateVlanPayload -SourcePayload $SourceTemplateVlanPayload -DestinationPayload $DestinationTemplateVlanPayload)
            $CloneTemplateVlanPayload = $($CloneTemplateVlanPayload | ConvertTo-Json -Depth 6)
            Write-Verbose $CloneTemplateVlanPayload
            $TemplateUpdateNetworkUrl = $BaseUri + "/api/TemplateService/Actions/TemplateService.UpdateNetworkConfig"
            $TemplateVlanResponse = Invoke-WebRequest -Uri $TemplateUpdateNetworkUrl -UseBasicParsing -Method Post -Body $CloneTemplateVlanPayload -ContentType $ContentType -Headers $Headers
            if ($TemplateVlanResponse.StatusCode -eq 200) {
                Write-Verbose "Clone Template Success - VLANs"
            }
        }
        return $NewTemplateId
    }
    Catch {
        Resolve-Error $_
    }
}

End {}

}

