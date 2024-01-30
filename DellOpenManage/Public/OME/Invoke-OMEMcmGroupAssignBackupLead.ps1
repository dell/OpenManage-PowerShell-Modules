
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
       This script uses the OME REST API to add a backup lead chassis
    
     .PARAMETER ServiceTag
       Service Tag of chassis to assign as backup lead
    
     .EXAMPLE
       Invoke-OMEMcmGroupAssignBackupLead -Wait

       Assign backup lead to random chassis
    
     .EXAMPLE
       Invoke-OMEMcmGroupAssignBackupLead -ServiceTag "XYZ1234" -Wait

       Assign backup lead to specific chassis
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
        $ListOfMembers = "MEMBER" | Get-OMEMXDomain
        $JobId = 0
        if ($ListOfMembers.Count -gt 0) {
            Write-Verbose "Management domains found..."
            Write-Verbose $($ListOfMembers | Format-Table | Out-String)
            if ($ServiceTag -ne "") {
                $Member = $ListOfMembers | Where-Object {$_.Identifier -eq $ServiceTag}
            } else {
                $Member = Get-Random -InputObject $ListOfMembers -Count 1
            }
            Write-Verbose "Assigning backup lead..."
            Write-Verbose $($Member | Format-Table | Out-String)
            $MemberId = $Member."Id"
            $TargetArray = @()
            $TargetTempHash = @{}
            $TargetTempHash."Id" = $MemberId
            $TargetArray += $TargetTempHash
            $Body = ConvertTo-Json $TargetArray
            Write-Verbose "Invoking URL $($URL)"
            Write-Verbose "Payload $($Body)"
            $Response = Invoke-WebRequest -Uri $URL -UseBasicParsing -Headers $Headers -ContentType $ContentType -Method POST -Body $Body 
            if ($Response.StatusCode -in (200,201)) {
                $BackupLeadData = $Response | ConvertFrom-Json
                $JobId = $BackupLeadData.'JobId'
                Write-Verbose "Successfully assigned backup lead"
            }
            else {
                Write-Warning "Failed to assign backup lead"
            }
        }
    
        return $JobId
    }
    
    ## Script that does the work
    if (!$(Confirm-IsAuthenticated)){
        Return
    }
    
    Try {
        if ($SessionAuth.IgnoreCertificateWarning) { Set-CertPolicy }
        $BaseUri = "https://$($SessionAuth.Host)"
        $Headers = @{}
        $Headers."X-Auth-Token" = $SessionAuth.Token
        $ContentType = "application/json"
    
        # Create mcm group
        $JobId = Invoke-AssignBackupLead -BaseUri $BaseUri -Headers $Headers -ContentType $ContentType -ServiceTag $ServiceTag
        if ($JobId -ne 0) {
            Write-Verbose "Polling backup lead assignment ..."
            if ($Wait) {
                $JobStatus = $($JobId | Wait-OnJob -WaitTime $WaitTime)
                return $JobStatus
            } else {
                return $JobId
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