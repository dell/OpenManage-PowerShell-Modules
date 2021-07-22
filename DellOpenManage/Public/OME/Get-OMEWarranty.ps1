
function Get-OMEWarranty {
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
        Get users from OpenManage Enterprise
    .DESCRIPTION
    
    .PARAMETER Value
        String containing search value. Use with -FilterBy parameter
    .PARAMETER FilterBy
        Filter the results by ("Id", Default="UserName", "RoleId")
    .INPUTS
        String[]
    .EXAMPLE
        Get-OMEUser | Format-Table
        List all users
    .EXAMPLE
        "admin" | Get-OMEUser
        Get user by name
    #>
    
    [CmdletBinding()]
    param(
        [Parameter(Mandatory=$false, ValueFromPipeline)]
        [String[]]$Value,
    
        [Parameter(Mandatory=$false)]
        [ValidateSet("Id", "UserName", "RoleId")]
        [String]$FilterBy = "UserName"
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
            $Type = "application/json"
            $Headers = @{}
            $Headers."X-Auth-Token" = $SessionAuth.Token
            $FilterMap = @{
                'Id'='Id'
                'UserName'='UserName'
                'RoleId'='RoleId'
            }
            $FilterExpr  = $FilterMap[$FilterBy]
    
            $AccountUrl = $BaseUri  + "/api/WarrantyService/Warranties"
            if ($Value) {
                if ($FilterBy -eq 'Id') {
                    $AccountUrl += "?`$filter=$($FilterExpr) eq $($Value)"
                }
                else {
                    $AccountUrl += "?`$filter=$($FilterExpr) eq '$($Value)'"
                }
            }

            $AccountData = @()
            $AccountResponse = Get-ApiDataAllPages -BaseUri $BaseUrl -Url $AccountUrl -Headers $Headers
            foreach ($Account in $AccountResponse) {
                $AccountData += New-AccountFromJson -Account $Account
            }

            $AccountData = @()
            $AccountResponse = Invoke-WebRequest -UseBasicParsing -Uri $AccountUrl -Headers $Headers -Method Get
            if ($AccountResponse.StatusCode -eq 200) {
                $AccountInfo = $AccountResponse.Content | ConvertFrom-Json
                if ($AccountInfo.value) { 
                    foreach ($AccountValue in $AccountInfo.value) {
                        $AccountData += New-AccountFromJson -Account $AccountValue
                    }
                    if ($AccountInfo.'@odata.nextLink') {
                        $NextLinkUrl = $BaseUri + $AccountInfo.'@odata.nextLink'
                    }
                    while($NextLinkUrl) {
                        $NextLinkResponse = Invoke-WebRequest -Uri $NextLinkUrl -UseBasicParsing -Method Get -Headers $Headers -ContentType $Type
                        if($NextLinkResponse.StatusCode -eq 200)
                        {
                            $NextLinkData = $NextLinkResponse.Content | ConvertFrom-Json
                            foreach ($NextLinkAccount in $NextLinkData.'value') {
                                $AccountData += New-AccountFromJson -Account $NextLinkAccount
                            }
                            if ($NextLinkData.'@odata.nextLink') {
                                $NextLinkUrl = $BaseUri + $NextLinkData.'@odata.nextLink'
                            }
                            else {
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
                return $AccountData
            }
            else {
                Write-Error "Unable to get AccountId"
            }
        }
        Catch {
            Resolve-Error $_
        }
    }
    
    End {}
    
    }
    