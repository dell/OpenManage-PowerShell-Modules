using module ..\..\Classes\SessionAuth.psm1
function Connect-OMEServer {
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
    Connect to OpenManage Enterprise Server using REST API
.DESCRIPTION
    Connect to OpenManage Enterprise Server using REST API. For authentication session-based X-Auth
    Token is used.

    Note that the credentials entered are not stored to disk.
.PARAMETER Name
    OpenManage Enterprise Server Hostname or IP Address. If not specified will attempt to use Environment Variable OMEHost
.PARAMETER Credentials
    PSCredential object containing username and password to authenticate. If not specified will attempt to use Environment Variables OMEUserName and OMEPassword.
.PARAMETER IgnoreCertificateWarning
    Ignore certificate warnings from server. Used for the default self-signed certificate. (Default=False)
.INPUTS
    None
.EXAMPLE
    Connect-OMEServer -Name "ome.example.com" -Credentials $(New-Object -TypeName System.Management.Automation.PSCredential -ArgumentList "admin", $(ConvertTo-SecureString -Force -AsPlainText "password")) -IgnoreCertificateWarning
.EXAMPLE
    Connect-OMEServer -Name "ome.example.com" -Credentials $(Get-Credential) -IgnoreCertificateWarning

    Prompt for credentials
.EXAMPLE
    $env:OMEHost = '192.168.1.100'; $env:OMEUserName = 'admin'; $env:OMEPassword = 'calvin'; Connect-OMEServer -IgnoreCertificateWarning
    
    Credentials can be stored in Environment Variables
#>
[CmdletBinding()]
param(
    [Parameter(Mandatory=$false)]
    [String]$Name,

    [Parameter(Mandatory=$false)]
    [PSCredential]$Credentials,

    [Parameter(Mandatory=$false)]
    [Switch]$IgnoreCertificateWarning
)

    if ($IgnoreCertificateWarning) { Set-CertPolicy }
    $Type = "application/json"
    # Allow for use of Environment Variables
    if ($Name) {
        $OMEHost = $Name
    } else {
        $OMEHost = $env:OMEHost
    }
    if ($Credentials) {
        $OMEUserName = $Credentials.username
        $OMEPassword = $Credentials.GetNetworkCredential().password
    } else {
        $OMEUserName = $env:OMEUserName
        $OMEPassword = $env:OMEPassword
    }

    # Input Validation
    if ($null -eq $OMEHost) { throw [System.ArgumentNullException] "OMEHost" }
    if ($null -eq $OMEUserName) { throw [System.ArgumentNullException] "OMEUserName" }
    if ($null -eq $OMEPassword) { throw [System.ArgumentNullException] "OMEPassword" }

    $SessionUrl  = "https://$($OMEHost)/api/SessionService/Sessions"
    $UserDetails = @{"UserName"=$OMEUserName;"Password"=$OMEPassword;"SessionType"="API"} | ConvertTo-Json

    $SessResponse = Invoke-WebRequest -Uri $SessionUrl -UseBasicParsing -Method Post -Body $UserDetails -ContentType $Type 
    if ($SessResponse.StatusCode -in 200, 201) {
        $SessResponseData = $SessResponse.Content | ConvertFrom-Json
        
        $Token = [String]$SessResponse.Headers["X-Auth-Token"]
        $Headers = @{}
        $Headers."X-Auth-Token" = $Token

        # Get Appliance Version
        $AppInfoUrl = "https://$($OMEHost)/api/ApplicationService/Info"
        $AppInfoResponse = Invoke-WebRequest -Uri $AppInfoUrl -UseBasicParsing -Method Get -Headers $Headers -ContentType $Type 
        $AppVersion = [System.Version]"1.0.0"
        if ($AppInfoResponse.StatusCode -eq 200, 201) {
            $AppInfoResponseData = $AppInfoResponse.Content | ConvertFrom-Json
            Write-Verbose $($AppInfoResponseData)
            $AppVersion = [System.Version]$AppInfoResponseData.Version
        }

        $Script:SessionAuth = [SessionAuth]@{
            Host = $OMEHost
            Token = $Token
            Id = $SessResponseData.Id
            Version = $AppVersion
            IgnoreCertificateWarning = $IgnoreCertificateWarning
        }
        
    } else {
        Write-Error "Unable to create a session with appliance $($OMEHost)"
    }
}
