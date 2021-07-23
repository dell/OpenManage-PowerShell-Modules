
function Invoke-OMEMcmGroupAssignBackupLead {
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
    
     .PARAMETER ServiceTag
       Service Tag of chassis to assign as backup lead
    
     .EXAMPLE
       Invoke-OMEMcmGroupAssignBackupLead -Wait
    
    #>
    [CmdletBinding()]
    param(
        [Parameter(Mandatory=$false)]
        [String] $ServiceTag,
    
        [Parameter(Mandatory=$false)]
        [Switch]$Wait,
    
        [Parameter(Mandatory=$false)]
        [int]$WaitTime = 3600
    )
       
    function Invoke-AssignBackupLead($BaseUri, $Headers, $ContentType, $ServiceTag) {
        $URL = $BaseUri + "/api/ManagementDomainService/Actions/ManagementDomainService.AssignBackupLead"
        $ListOfMembers = @()
        $ListOfMembers = Get-MXDomains -BaseUri $BaseUri -Headers $Headers -RoleType "MEMBER"
        $JobId = 0
        if ($ListOfMembers.Length -gt 0) {
            if ($ServiceTag -ne "") {
                $Member = $ListOfMembers | Where-Object {$_.Identifier -eq $ServiceTag}
            } else {
                $Member = Get-Random -InputObject $ListOfMembers -Count 1
            }
            $MemberId = $Member."Id"
            $TargetArray = @()
            $TargetTempHash = @{}
            $TargetTempHash."Id" = $MemberId
            $TargetArray += $TargetTempHash
            $Body = ConvertTo-Json $TargetArray
            Write-Host "Assigning backup lead..."
            Write-Host "Invoking URL $($URL)"
            Write-Host "Payload $($Body)"
            $Response = Invoke-WebRequest -Uri $URL -Headers $Headers -ContentType $ContentType -Method POST -Body $Body 
            if ($Response.StatusCode -eq 200) {
                $BackupLeadData = $Response | ConvertFrom-Json
                $JobId = $BackupLeadData.'JobId'
                Write-Host "Successfully assigned backup lead"
            }
            else {
                Write-Warning "Failed to assign backup lead"
            }
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
    
        ## Sending in non-existent targets throws an exception with a "bad request"
        ## error. Doing some pre-req error checking as a result to validate input
        ## This is a Powershell quirk on Invoke-WebRequest failing with an error
        # Create mcm group
        $JobId = 0
        $JobId = Invoke-AssignBackupLead -BaseUri $BaseUri -Headers $Headers -ContentType $ContentType -ServiceTag $ServiceTag
        if ($JobId) {
            Write-Host "Polling backup lead assignment ..."
            if ($Wait) {
                $JobId | Wait-OnJob -WaitTime $WaitTime
            }
        }
        else {
            Write-Warning "Unable to track backup lead assignment ..."
        }
    
    }
    catch {
        Resolve-Error $_
    }
    
}