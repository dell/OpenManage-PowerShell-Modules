
function Invoke-OMEMcmGroupAddMember {
    <#
    _author_ = Vittalareddy Nanjareddy <vittalareddy_nanjare@Dell.com>
    
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
       Add all possible members to MCM Group
    
     .DESCRIPTION
       This script uses the OME REST API to create mcm group, find memebers and add the members to the group.
    
     .PARAMETER GroupName
       The Name of the MCM Group.
    
     .EXAMPLE
       Invoke-OMEMcmGroupAddMember -Wait
    
    #>
    [CmdletBinding()]
    param(
        [Parameter(Mandatory=$false)]
        [Switch]$Wait,
    
        [Parameter(Mandatory=$false)]
        [int]$WaitTime = 3600
    )
    
    function Get-DiscoveredDomain($BaseUri, $Headers, $ContentType, $Role) {
        $DiscoveredDomains = @()
        $FilteredDiscoveredDomains = @()
        $TargetArray = @()
        $URL = $BaseUri + "/api/ManagementDomainService/DiscoveredDomains"
        $Response = Invoke-WebRequest -Uri $URL -Headers $Headers -ContentType $ContentType -Method GET
        if ($Response.StatusCode -eq 200) {
            $DomainResp = $Response.Content | ConvertFrom-Json
            if ($DomainResp."value".Length -gt 0) {
                $DiscoveredDomains = $DomainResp."value"
            }
            else {
                Write-Warning "No domains discovered"
            }
        }
        else {
            Write-Warning "Unable to fetch discovered domain info...skipping"
        }
        if ($Role) {
            foreach ($Domain in $DiscoveredDomains) {
                if ($Domain.'DomainRoleTypeValue' -eq $Role) {
                    #$FilteredDiscoveredDomains += $Domain.'DomainRoleTypeValue'
                    $FilteredDiscoveredDomains += $Domain
                }
            }
        }
    
        if ($FilteredDiscoveredDomains.Length -gt 0) {
            foreach ($Domain in $FilteredDiscoveredDomains) {
                $TargetTempHash = @{}
                $TargetTempHash."GroupId" = $Domain."GroupId"
                $TargetArray += $TargetTempHash
            }
        }
        $TargetArrayList = @()
        $TargetArrayList = ConvertTo-Json $TargetArray
        return $TargetArrayList
    }
    
    
    function Add-AllMembersViaLead($BaseUri, $Headers, $ContentType) {
        # Add standalone domains to the group
        $Role = "STANDALONE"
        $StandaloneDomains = @()
        $StandaloneDomains = Get-DiscoveredDomain -BaseUri $BaseUri -Headers $Headers -ContentType $ContentType -Role $Role
        $JobId = 0
        $Payload = @()
        if ($StandaloneDomains.Length -gt 0) {
            $Payload = $StandaloneDomains
            $ManagementDomainURL = $BaseUri + "/api/ManagementDomainService/Actions/ManagementDomainService.Domains"
            $Body = $Payload 
            Write-Verbose "Adding members to the group..."
            Write-Verbose "Invoking URL $($ManagementDomainURL)"
            $Response = Invoke-WebRequest -Uri $ManagementDomainURL -Headers $Headers -ContentType $ContentType -Method POST -Body $Body 
            if ($Response.StatusCode -eq 200) {
                $ManagementData = $Response | ConvertFrom-Json
                $JobId = $ManagementData.'JobId'
                Write-Verbose "Added members to the created group...Job ID is $($JobId)"
            }
            else {
                Write-Warning "Failed to add members to the group"
            }
        }
        else {
            Write-Warning "No standalone chassis found to add as member to the created group"
        }
        return $JobId
    }
    
    ## Script that does the work
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
        $ContentType = "application/json"
    
        # Create mcm group
        $JobId = 0
        $JobId = Add-AllMembersViaLead -BaseUri $BaseUri -Headers $Headers -ContentType $ContentType
        if ($JobId) {
            Write-Verbose "Polling addition of members to group ..."
            if ($Wait) {
                $JobStatus = $($JobId | Wait-OnJob -WaitTime $WaitTime)
                return $JobStatus
            } else {
                return $JobId
            }
        }
    
    }
    catch {
        Resolve-Error $_
    }
    
    }