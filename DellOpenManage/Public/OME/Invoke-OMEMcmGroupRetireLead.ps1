function Invoke-RetireLead($BaseUri, $Headers, $ContentType, $PostRetirementRoleType) {
    $BackupLead = $null
    Write-Verbose "Checking for Backup Lead"
    $BackupLead = Get-BackupLead -BaseUri $BaseUri -Headers $Headers -ContentType $ContentType
    $JobId = 0
    # Need to implemented -Force 
    if ($null -eq $BackupLead) {
        Write-Error "No backup lead found. Exiting. Use the -Force parameter"
        Break
        Return
    } else {
        Write-Verbose "Checking Backup lead health"
        $BackupLeadHealth = $BackupLead.'BackupLeadHealth'
        if ($BackupLeadHealth -ne 1000) {
            Write-Verbose "Backup lead health is CRITICAL or WARNING."
            Write-Verbose "Please ensure backup lead is healty before retiring the lead"
            Break
            Return
        }
    }

    $URL = $BaseUri + "/api/ManagementDomainService/Actions/ManagementDomainService.RetireLead"
    $Payload = '{
        "PostRetirementRoleType" : "Member"
    }' | ConvertFrom-Json

    $Payload.PostRetirementRoleType = $PostRetirementRoleType
    $Body = $Payload | ConvertTo-Json -Depth 6
    $Response = Invoke-WebRequest -Uri $URL -Headers $Headers -ContentType $ContentType -Method POST -Body $Body 
    if ($Response.StatusCode -eq 200) {
        $RetireLeadResp = $Response | ConvertFrom-Json
        $JobId = $RetireLeadResp.'JobId'
        if ($JobId) {
            Write-Verbose "Created job to retire lead with job id $($JobId)"
        }
    }
    else {
        Write-Warning "Failed to retire lead"
    }

    return $JobId
}
function Get-BackupLead($BaseUri, $Headers, $ContentType) {
    $Domains = Get-MXDomain -BaseUri $BaseUri -Headers $Headers -RoleType "BACKUPLEAD"
    return $Domains
}

function Invoke-OMEMcmGroupRetireLead {
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
       Assign backup lead chassis to MCM Group
    
     .DESCRIPTION
       This script uses the OME REST API to create mcm group, find memebers and add the members to the group.
    
     .PARAMETER Force
       Not implemented
    
     .PARAMETER PostRetirementRoleType
       Role to assign to retired chassis (Default="Member", "Standalone")
    
     .EXAMPLE
       Invoke-OMEMcmGroupRetireLead -Wait
    
    #>
    [CmdletBinding()]
    param(
        [Parameter(Mandatory=$false)]
        [ValidateSet("Standalone", "Member")]
        [String] $PostRetirementRoleType = "Member",

        [Parameter(Mandatory=$false)]
        [Switch]$Wait,
    
        [Parameter(Mandatory=$false)]
        [int]$WaitTime = 3600
    )

    if(!$SessionAuth.Token){
        Write-Error "Please use Connect-OMEServer first"
        Break
        Return
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
    
        $JobId = 0
        $JobId = Invoke-RetireLead -BaseUri $BaseUri -Headers $Headers -ContentType $ContentType -PostRetirementRoleType $PostRetirementRoleType
        if ($JobId) {
            Write-Verbose "Polling for retire lead job status ..."
            if ($Wait) {
                $JobStatus = $($JobId | Wait-OnJob -WaitTime $WaitTime)
                return $JobStatus
            } else {
                return $JobId
            }
        } else {
            Write-Warning "Unable to track backup lead assignment ..."
        }
    
    }
    catch {
        Resolve-Error $_
    }
    
}