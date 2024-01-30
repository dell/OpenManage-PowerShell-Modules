using module ..\..\Classes\Template.psm1
using module ..\..\Classes\TemplateNetwork.psm1

function Get-OMETemplateNetwork {
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
    Get template networks
.DESCRIPTION
    This script uses the OME REST API.
    Note that the credentials entered are not stored to disk.
.PARAMETER Template
    Object of type Template returned from Get-OMETemplate
.EXAMPLE
    "TestTemplate01" | Get-OMETemplate | Get-OMETemplateNetwork

    Get networks from template
#>   
    
    [CmdletBinding()]
    param(
        [Parameter(Mandatory, ValueFromPipeline)]
        [Template[]] $Template
    )
    
    Begin {}
    Process {
        if (!$(Confirm-IsAuthenticated)) {
            Return
        }
        Try {
            if ($SessionAuth.IgnoreCertificateWarning) { Set-CertPolicy }
            $BaseUri = "https://$($SessionAuth.Host)"
            $Headers = @{}
            $ContentType = "application/json"
            $Headers."X-Auth-Token" = $SessionAuth.Token
    
            $TemplateVlanUrl = $BaseUri + "/api/TemplateService/Templates($($Template.Id))/Views(4)/AttributeViewDetails"
            Write-Verbose $TemplateVlanUrl
            $TemplateVlanResponse = Invoke-WebRequest -UseBasicParsing -Uri $TemplateVlanUrl -Headers $Headers -Method Get -ContentType $ContentType
            if ($TemplateVlanResponse.StatusCode -in (200,201)) {
                $TemplateVlanInfo = $TemplateVlanResponse.Content | ConvertFrom-Json
                $AttributeGroups = $TemplateVlanInfo.AttributeGroups
                $PortVlanInfo = @()
                foreach ($AttributeGroup in $AttributeGroups) {
                    if ($AttributeGroup.DisplayName -eq "NICModel") {
                        foreach ($NIC in $AttributeGroup.SubAttributeGroups) {
                            # Loop through NICs
                            $NICDisplayName = $NIC.DisplayName
                            foreach ($Port in $NIC.SubAttributeGroups) {
                                # Loop through Ports
                                $PortNumber = $Port.GroupNameId
                                foreach ($Partition in $Port.SubAttributeGroups) {
                                    # Loop through Partitions
                                    if ($Partition.GroupNameId -eq 1) {
                                        # We are only concerned with Partition 1
                                        foreach ($Attribute in $Partition.Attributes) {
                                            # Loop through Partition Attributes
                                            if ($Attribute.DisplayName -eq "Vlan Tagged") {
                                                $CustomId = $Attribute.CustomId
                                                if ($null -eq $Attribute.Value) {
                                                    $PortVlanTagged = @()
                                                } else {
                                                    $PortVlanTagged = $($Attribute.Value.Split(",") | ForEach-Object { $_.Trim() } | ForEach-Object { [Int]$_ })
                                                }
                                            }

                                            if ($Attribute.DisplayName -eq "Vlan UnTagged") {
                                                $PortVlanUnTagged = [Int]$Attribute.Value
                                            }
                                        }

                                        $PortInfo = [TemplateNetwork]@{
                                            NICIdentifier = $NICDisplayName
                                            Port          = $PortNumber
                                            CustomId      = $CustomId
                                            VlanTagged    = $PortVlanTagged
                                            VlanUnTagged  = $PortVlanUnTagged
                                        }
                                        $PortVlanInfo += $PortInfo
                                    }
                                }
                            }
                        }
                    }
                }
                return $PortVlanInfo
            }
            else {
                Write-Error "Unable to get Template Networks for $($Template.Id)"
            }
            return $null
        }
        Catch {
            Resolve-Error $_
        }
    
    }
    
    End {}
    
}