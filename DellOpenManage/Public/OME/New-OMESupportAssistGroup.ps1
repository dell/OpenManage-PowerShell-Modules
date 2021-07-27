
function New-OMEMcmGroup {
<#
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
   Create an MCM group and add all possible members to the created group

 .DESCRIPTION
   This script uses the OME REST API to create mcm group, find memebers and add the members to the group.

 .PARAMETER GroupName
   The Name of the MCM Group.

 .EXAMPLE
   New-OMEMcmGroup -GroupName TestGroup -Wait

#>
[CmdletBinding()]
param(
    [Parameter(Mandatory=$false)]
    [String]$GenerateJson
)

function Read-Confirmation() {
    <#
    .SYNOPSIS
      Prompts a user with a yes or no question
  
    .DESCRIPTION
      Prompts a user with a yes or no question. The question text should include something telling the user
      to type y/Y/Yes/yes or N/n/No/no
  
    .PARAMETER QuestionText
      The text which you want to display to the user
  
    .OUTPUTS
      Returns true if the user enters yes and false if the user enters no
    #>
    [CmdletBinding()]
    param (
  
        [Parameter(Mandatory)]
        [string]
        $QuestionText
    )
    do {
        $Confirmation = (Read-Host $QuestionText).ToUpper()
    } while ($Confirmation -ne 'YES' -and $Confirmation -ne 'Y' -and $Confirmation -ne 'N' -and $Confirmation -ne 'NO')
  
    if ($Confirmation -ne 'YES' -and $Confirmation -ne 'Y') {
        return $false
    }
  
    return $true
  }
  

function Get-GroupCreationPayload {
    <#
      .SYNOPSIS
        Prompts the user for each field required to create the group
    
      .DESCRIPTION
        Prompts for each field required to create a new SupportAssist Enterprise user group and then
        generates a correctly formatted HashTable based on it.
    
      .OUTPUTS
        A HashTable containing all the data required to generate the group
      #>
      [CmdletBinding()]
      param (
    
        [Parameter(Mandatory = $false)]
        [string]
        $OutputFilePath,
    
        [Parameter(Mandatory = $false)]
        [string]
        $InputFilePath
      )
    
      $UserDataDictionary = @{
        Name = Read-Host "Group Name "
        Description = Read-Host "Description "
        ContactOptIn = Read-Confirmation "Do you want to be contacted regarding this group? This will also opt you into dispatches. (y/n)"
        MyAccountId = [int]$(Read-Host "Account ID (only numbers) ")
        CustomerDetails = $null
      }
    
      if ($UserDataDictionary.ContactOptIn) {
    
        $UserDataDictionary['DispatchOptIn'] = $true
    
        $CustomerDetails = @{}
    
        $Timezones = Get-Timezone
    
        if ($Timezones.length -lt 1) {
          return @{}
        }
    
        function _PromptForContactDetails {
          param (
            [Parameter(Mandatory = $true)]
            [string] $PromptText
          )
    
          $DataDictionary = @{
            FirstName = Read-Host "$($PromptText) Contact First Name"
            LastName = Read-Host "$($PromptText) Contact Last Name"
            Email = Read-Host "$($PromptText) Contact Email"
            Phone = Read-Host "$($PromptText) Contact Phone"
            AlternatePhone = Read-Host "$($PromptText) Contact Alternate Phone"
          }
    
          return $DataDictionary
        }
    
        # Primary Contact
        $CustomerDetails['PrimaryContact'] = _PromptForContactDetails 'Primary'
        $CustomerDetails['PrimaryContact']['ContactMethod'] = 'phone'
        $CustomerDetails['PrimaryContact']['TimeFrame'] = Read-Host "Primary Contact time frame in the format: 10:00 AM-4:00 PM.  WARNING: There is no input validation on this. You must match caps and spacing"
    
        foreach ($Timezone in $Timezones) {
          Write-Host "Name: $($Timezone.Name) Id: $($Timezone.Id)"
        }
        $CustomerDetails['PrimaryContact']['TimeZone'] = Read-Host "Primary contact timezone. Input timezone ID. (Make sure to match exactly)"
    
        # Secondary Contact
        $CustomerDetails['SecondaryContact'] = _PromptForContactDetails 'Secondary'
        $CustomerDetails['SecondaryContact']['ContactMethod'] = 'phone'
        $CustomerDetails['SecondaryContact']['TimeFrame'] = Read-Host "Secondary Contact time frame in the format: 10:00 AM-4:00 PM.  WARNING: There is no input validation on this. You must match caps and spacing"
    
        foreach ($Timezone in $Timezones) {
          Write-Host "Name: $($Timezone.Name) Id: $($Timezone.Id)"
        }
        $CustomerDetails['SecondaryContact']['TimeZone'] = Read-Host "Secondary contact timezone. Input timezone ID. (Make sure to match exactly)"
    
        # Shipping Details Primary Contact
        $CustomerDetails['ShippingDetails'] = @{
          PrimaryContact = _PromptForContactDetails 'Shipping Primary Contact'
          SecondaryContact = _PromptForContactDetails 'Shipping Secondary Contact'
          Country = "US"  # TODO - need to add support for other countries
          State = Read-Host 'State'
          City = Read-Host 'City'
          Zip = Read-Host 'Zip'
          Cnpj = $null
          Ie = $null
          AddressLine1 = Read-Host 'Address Line 1'
          AddressLine2 = Read-Host 'Address Line 2'
          AddressLine3 = Read-Host 'Address Line 3'
          AddressLine4 = Read-Host 'Address Line 4'
          PreferredContactTimeFrame = Read-Host "Shipping contact time frame in the format: 10:00 AM-4:00 PM.  WARNING: There is no input validation on this. You must match caps and spacing"
          TechnicianRequired = Read-Confirmation 'Is a technician required for dispatches? (y/n): '
          DispatchNotes = Read-Host 'Any dispatch notes you want to add to devices in this group'
        }
    
        foreach ($Timezone in $Timezones) {
          Write-Host "Name: $($Timezone.Name) Id: $($Timezone.Id)"
        }
        $CustomerDetails['ShippingDetails']['PreferredContactTimeZone'] = Read-Host "Shipping contact timezone. Input timezone ID. (Make sure to match exactly)"
    
        $UserDataDictionary.CustomerDetails = $CustomerDetails
      }
      else {
        $CustomerDetails.DispatchOptIn = $false
      }
    
      return $UserDataDictionary
    }

function Create-McmGroup($BaseUri, $Headers, $ContentType, $GroupName) {
    $CreateGroupURL = $BaseUri + "/api/ManagementDomainService"
    $payload = '{
        "GroupName": "",
        "GroupDescription": "",
        "JoinApproval": "AUTOMATIC",
        "ConfigReplication": [{
            "ConfigType": "Power",
            "Enabled": "false"
        }, {
            "ConfigType": "UserAuthentication",
            "Enabled": "false"
        }, {
            "ConfigType": "AlertDestinations",
            "Enabled": "false"
        }, {
            "ConfigType": "TimeSettings",
            "Enabled": "false"
        }, {
            "ConfigType": "ProxySettings",
            "Enabled": "false"
        }, {
            "ConfigType": "SecuritySettings",
            "Enabled": "false"
        }, {
            "ConfigType": "NetworkServices",
            "Enabled": "false"
        }, {
            "ConfigType": "LocalAccessConfiguration",
            "Enabled": "false"
        }]
    }' | ConvertFrom-Json

    $JobId = 0
    $Payload."GroupName" = $GroupName
    $Body = $payload | ConvertTo-Json -Depth 6
    $Response = Invoke-WebRequest -Uri $CreateGroupURL -Headers $Headers -ContentType $ContentType -Method PUT -Body $Body 
    if ($Response.StatusCode -eq 200) {
        $GroupData = $Response | ConvertFrom-Json
        $JobId = $GroupData.'JobId'
        Write-Host "MCM group created successfully...JobId is $($JobId)"
    }
    else {
        Write-Warning "Failed to create MCM group"
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

    if ($PSBoundParameters.ContainsKey('GenerateJson')) {
        CreateGroupCreationPayload | ConvertTo-Json -Depth 10 | Out-File $GenerateJson
    }

}
catch {
    Resolve-Error $_
}

}