function Get-OMEAuditLogs {

<#
_author_ = Grant Curell <grant_curell@dell.com>

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
    Retrieves the audit logs from a target OME instance and can either save them in an CSV on a fileshare or 
    print them to screen.

  .DESCRIPTION
    It performs X-Auth with basic authentication. Note: Credentials are not stored on disk.

  .EXAMPLE
    Get-OMEAuditLogs | Format-Table
#>
[CmdletBinding()]
param(
)

if(!$SessionAuth.Token){
    Write-Error "Please use Connect-OMEServer first"
    Break
    Return
}

function Get-Data {
  <#
  .SYNOPSIS
    Used to interact with API resources

  .DESCRIPTION
    This function retrieves data from a specified URL. Get requests from OME return paginated data. The code below
    handles pagination. This is the equivalent in the UI of a list of results that require you to go to different
    pages to get a complete listing.

  .PARAMETER Url
    The API url against which you would like to make a request

  .PARAMETER OdataFilter
    An optional parameter for providing an odata filter to run against the API endpoint.

  .PARAMETER MaxPages
    The maximum number of pages you would like to return

  .INPUTS
    None. You cannot pipe objects to Get-Data.

  .OUTPUTS
    dict. A dictionary containing the results of the API call or an empty dictionary in the case of a failure

  #>

  [CmdletBinding()]
  param (
    [Parameter(Mandatory)]
    [string]
    $Url,

    [Parameter(Mandatory)]
    [PSCustomObject]
    $Headers,

    [Parameter(Mandatory = $false)]
    [string]
    $OdataFilter,

    [Parameter(Mandatory = $false)]
    [int]
    $MaxPages = $null
  )

  $Data = @()
  $NextLinkUrl = $null
  try {

    if ($PSBoundParameters.ContainsKey('OdataFilter')) {
      $CountData = Invoke-RestMethod -Uri $Url"?`$filter=$($OdataFilter)" -Method Get -Headers $Headers -ContentType $ContentType

      if ($CountData.'@odata.count' -lt 1) {
        Write-Error "No results were found for filter $($OdataFilter)."
        return @{}
      } 
    }
    else {
      $CountData = Invoke-RestMethod -Uri $Url -Method Get -Headers $Headers -ContentType $ContentType
    }

    if ($null -ne $CountData.'value') {
      $Data += $CountData.'value'
    }
    else {
      $Data += $CountData
    }
    
    if ($CountData.'@odata.nextLink') {
      $NextLinkUrl = $BaseUri + "$($CountData.'@odata.nextLink')"
    }

    $i = 1
    while ($NextLinkUrl) {
      if ($MaxPages) {
        if ($i -ge $MaxPages) {
          break
        }
        $i = $i + 1
      }
      
      $NextLinkData = Invoke-RestMethod -Uri "$($NextLinkUrl)" -Method Get -Headers $Headers -ContentType $ContentType
          
      if ($null -ne $NextLinkData.'value') {
        $Data += $NextLinkData.'value'
      }
      else {
        $Data += $NextLinkData
      }    
      
      if ($NextLinkData.'@odata.nextLink') {
        $NextLinkUrl = $BaseUri + "$($NextLinkData.'@odata.nextLink')"
      }
      else {
        $NextLinkUrl = $null
      }
    }

    return $Data

  }
  catch [System.Net.Http.HttpRequestException] {
    Write-Error "There was a problem connecting to OME or the URL supplied is invalid. Did it become unavailable?"
    return @{}
  }

}

### Main commandlet start
$BaseUri = "https://$($SessionAuth.Host)"
$Headers = @{}
$Headers."X-Auth-Token" = $SessionAuth.Token

try {
    $AuditLogs = Get-Data -Url $($BaseUri + "/api/ApplicationService/AuditLogs") -Headers $Headers
    
    if ($null -eq $AuditLogs) {
        Write-Output "Error: We were unable to fetch the audit logs... exiting."
        Exit
    } else {
        Write-Output $AuditLogs
    }
}
catch {
    Resolve-Error $_
}


}