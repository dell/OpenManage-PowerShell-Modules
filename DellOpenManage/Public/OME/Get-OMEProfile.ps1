using module ..\..\Classes\Group.psm1

function Get-OMEProfile {
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
    Get Profiles managed by OpenManage Enterprise
.DESCRIPTION
    Get Profiles. Returns all Profiles if no input received.
.PARAMETER Value
    String containing search value. Use with -FilterBy parameter
.PARAMETER FilterBy
    Filter the results by (Default="ServiceTag", "Name", "Id", "Model", "Type")
.INPUTS
    String[]
.EXAMPLE
    "ProfileName" | Get-OMEProfile

    Get Profile by ProfileName
.EXAMPLE
    Get-OMEProfile | Where-Object { $_.ProfileName -eq "Profile from template 'Test Template 01' 00001" }

    Get Profile by ProfileName where ProfileName includes single quotes. Use for Profiles deployed from Templates on the MX platform
.EXAMPLE
    "TemplateName" | Get-OMEProfile -FilterBy TemplateName

    Get Profile by TemplateName
#>

[CmdletBinding()]
param(
    [Parameter(Mandatory=$false, ValueFromPipeline)]
    [String[]]$Value,

    [Parameter(Mandatory=$false)]
    [ValidateSet("Name", "TemplateName", "ChassisName", "TargetName", "ProfileState")]
    [String]$FilterBy = "Name"
)

Begin {}
Process {
    if (!$(Confirm-IsAuthenticated)){
        Return
    }
    Try {
        if ($SessionAuth.IgnoreCertificateWarning) { Set-CertPolicy }
        $BaseUri = "https://$($SessionAuth.Host)"
        $NextLinkUrl = $null
        $Type        = "application/json"
        $Headers     = @{}
        $FilterMap = @{
            'Name'='ProfileName'
            'TemplateName'='TemplateName'
            'ChassisName'='ChassisName'
            'TargetName'='TargetName'
            'ProfileState'='ProfileState'
        }
        # TargetTypeId,LastRunStatus,ProfileModified
        $FilterExpr  = $FilterMap[$FilterBy]

        $Headers."X-Auth-Token" = $SessionAuth.Token
        $ProfileData = @()

        $ProfileCountUrl = $BaseUri + "/api/ProfileService/Profiles"
        $Filter = ""
        if ($Value) { # Filter By 
            if ($FilterBy -eq 'ProfileState') {
                $Filter += "`$filter=$($FilterExpr) eq $($Value)"
            }
            else {
                $Filter += "`$filter=$($FilterExpr) eq '$($Value)'"
            }
        }
        $ProfileCountUrl = $ProfileCountUrl + "?" + $Filter
        Write-Verbose $ProfileCountUrl
        $ProfileResponse = Invoke-WebRequest -Uri $ProfileCountUrl -UseBasicParsing -Method Get -Headers $Headers -ContentType $Type
        if ($ProfileResponse.StatusCode -eq 200)
        {
            $ProfileCountData = $ProfileResponse.Content | ConvertFrom-Json
            foreach ($ServerProfile in $ProfileCountData.'value') {
                $ProfileData += New-ProfileFromJson -ServerProfile $ServerProfile
            }
            if($ProfileCountData.'@odata.nextLink')
            {
                $NextLinkUrl = $BaseUri + $ProfileCountData.'@odata.nextLink' + "&" + $Filter
            }
            while($NextLinkUrl)
            {
                Write-Verbose $NextLinkUrl
                $NextLinkResponse = Invoke-WebRequest -Uri $NextLinkUrl -UseBasicParsing -Method Get -Headers $Headers -ContentType $Type
                if($NextLinkResponse.StatusCode -eq 200)
                {
                    $NextLinkData = $NextLinkResponse.Content | ConvertFrom-Json
                    foreach ($ServerProfile in $NextLinkData.'value') {
                        $ProfileData += New-ProfileFromJson -ServerProfile $ServerProfile
                    }
                    if($NextLinkData.'@odata.nextLink')
                    {
                        $NextLinkUrl = $BaseUri + $NextLinkData.'@odata.nextLink' + "&" + $Filter
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

        return $ProfileData 
    } 
    Catch {
        Resolve-Error $_
    }
}

End {}

}

