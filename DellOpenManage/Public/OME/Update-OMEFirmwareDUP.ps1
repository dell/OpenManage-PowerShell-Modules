using module ..\..\Classes\Group.psm1
using module ..\..\Classes\Device.psm1

function Get-ApplicableComponents($BaseUri, $Headers, $ContentType, $DupReportPayload, $JobName, $UpdateSchedule, $UpdateScheduleCron, $ResetiDRAC, $ClearJobQueue) {
    $componentMap = @{"ComponentCurrentVersion" = "Current Ver";
        "ComponentUpdateAction"                 = "Action";
        "ComponentVersion"                      = "Avail Ver";
        "ComponentCriticality"                  = "Criticality";
        "ComponentRebootRequired"               = "Reboot Req";
        "ComponentName"                         = "Name"
    }

    $RetDupPayload = $null

    $DupUpdatePayload = '{
        "Id": 0,
        "JobName": "Firmware Update Task",
        "JobDescription": "Update firmware using DUP file",
        "Schedule": "startnow",
        "State": "Enabled",
        "CreatedBy": "admin",
        "JobType": {
            "Id": 5,
            "Name": "Update_Task"
        },
        "Targets" : [],
        "Params": [
            {
                "Key": "operationName",
                "Value": "INSTALL_FIRMWARE"
            },
            {
                "Key": "complianceUpdate",
                "Value": "false"
            },
            {
                "Key": "stagingValue",
                "Value": "false"
            },
            {
                "Key": "signVerify",
                "Value": "true"
            },
            {
                "Key": "clearJobQueue",
                "Value": "false"
            },
            {
                "Key": "firmwareReset",
                "Value": "false"
            }
        ]
    }' | ConvertFrom-Json

    $FileToken = ($DupReportPayload | ConvertFrom-Json).SingleUpdateReportFileToken

    $StageUpdate = $true
    $Schedule = "startNow"
    if ($UpdateSchedule -eq "RebootNow") {
        $StageUpdate = $false
    } elseif ($UpdateSchedule -eq "ScheduleLater") {
        $StageUpdate = $false
        $Schedule = $UpdateScheduleCron
    } elseif ($UpdateSchedule -eq "StageForNextReboot") {
        $StageUpdate = $true
    }
    $ParamsHashValMap = @{
        "stagingValue" = if ($StageUpdate) { "true" } else { "false"}
        "clearJobQueue" = if ($ClearJobQueue) { "true" } else { "false"}
        "firmwareReset" = if ($ResetiDRAC) { "true" } else { "false"}
    }

    for ($i = 0; $i -le $DupUpdatePayload.'Params'.Length; $i++) {
        if ($ParamsHashValMap.Keys -Contains ($DupUpdatePayload.'Params'[$i].'Key')) {
            $value = $DupUpdatePayload.'Params'[$i].'Key'
            $DupUpdatePayload.'Params'[$i].'Value' = $ParamsHashValMap.$value
        }
    }

    $DupReportUrl = $BaseUri + "/api/UpdateService/Actions/UpdateService.GetSingleDupReport"
    try {
        $DupResponse = Invoke-WebRequest -Uri $DupReportUrl -Headers $Headers -ContentType $ContentType -Body $DupReportPayload -Method Post -ErrorAction SilentlyContinue       
        if ($DupResponse.StatusCode -eq 200) {
            $DupResponseInfo = $DupResponse.Content | ConvertFrom-Json
            if ($DupResponse.Length -gt 0) {
                $RetVal = $true
                if ($DupResponseInfo.Length -gt 0) {
                    $TargetArray = @()                    
                    $OutputArray = @()
                    foreach ($Device in $DupResponseInfo) {
                        foreach ($Component in $Device.DeviceReport.Components) {
                            $tempHash = @{}
                            $tempHash."Device" = $Device.DeviceReport.DeviceServiceTag
                            $tempHash."IpAddress" = $Device.DeviceReport.DeviceIpAddress
                            ## This is a custom object - convert to a hash
                            $dupHash = @{}
                            $Component | Get-Member -MemberType NoteProperty | ForEach-Object { $dupHash.Add($_.Name, $Component.($_.Name)) }
                            foreach ($key in $dupHash.keys) {
                                if ($componentMap.Keys -Contains $key) {
                                    $tempHash[$ComponentMap.$key] = $dupHash.$key                            
                                }
                            }

                            ## For the current component if the available version is > current version
                            ## then add it to the list of targets
                            if ($tempHash."Avail Ver" -gt $tempHash."Current Ver") {
                                $TargetTempHash = @{}
                                $TargetTempHash."Id" = $Device.DeviceId
                                $TargetTempHash."Data" = [string]($Component.ComponentSourceName) + "=" + [string]($FileToken)
                                $TargetTempHash."TargetType" = @{}
                                $TargetTempHash."TargetType"."Id" = [uint64]$Device.DeviceReport.DeviceTypeId
                                $TargetTempHash."TargetType"."Name" = $Device.DeviceReport.DeviceTypeName
                                $OutputArray += , $tempHash
                                $TargetArray += , $TargetTempHash
                            }
                            else {
                                Write-Verbose "Skipping component $($tempHash."Name") - No upgrade available"
                            }
                        }
                    }
                    $DupUpdatePayload."Targets" = $TargetArray                   
                    $RetDupPayload = $DupUpdatePayload 
                }
                else {
                    Write-Warning "No applicable devices found for updating...Exiting"
                }
            }
            else {
                Write-Warning "No applicable devices or components found"
            }
        }
    }
    catch {
        Write-Warning "DUP file may not apply to device/group id. Please validate parameters and retry"
        #Write-Verbose $_.Exception.Response.StatusCode.Value__
    }
    if ($UpdateSchedule -eq "Preview") {
        return $OutputArray.Foreach( { [PSCustomObject]$_ })
    } else {
        return $RetDupPayload
    }
}

function Push-DupToOME($BaseUri, $Headers, $DupFile) {
    if ($SessionAuth.IgnoreCertificateWarning) { Set-CertPolicy }
    $FileToken = $null
    $UploadActionUri = $BaseUri + "/api/UpdateService/Actions/UpdateService.UploadFile"
    Write-Verbose "Uploading $($DupFile) to $($BaseUri). This action may take some time to complete."
    
    $UploadResponse = Invoke-WebRequest -Uri $UploadActionUri -Method Post -InFile $DupFile -ContentType "application/octet-stream" -Headers $Headers
    if ($UploadResponse.StatusCode -eq 200) {
        ## Successfully uploaded the DUP file . Get the file token
        ## returned by OME on upload of the DUP file
        ## The file token is returned as an array of decimals that maps to ascii text values
        $FileToken = [System.Text.Encoding]::ASCII.GetString($UploadResponse.Content)
        Write-Verbose "Successfully uploaded $($DupFile)"
    }
    else {
        Write-Warning "Unable to upload $($DupFile) to $($BaseUri)..."
    }
    return $FileToken
}

function Set-DupApplicabilityPayload($FileTokenInfo, $ParamHash) {
    $BlankArray = @()
    $DupReportPayload = @{"SingleUpdateReportBaseline" = $BlankArray;
        "SingleUpdateReportGroup"                      = $BlankArray;
        "SingleUpdateReportTargets"                    = $BlankArray;
        "SingleUpdateReportFileToken"                  = "";
    }
    $DupReportPayload.SingleUpdateReportFileToken = $FileTokenInfo
    if ($ParamHash.GroupId) {
        $DupReportPayload.SingleUpdateReportGroup += $ParamHash.GroupId
        $DupReportPayload.SingleUpdateReportTargets = $BlankArray
    }
    else {
        $DupReportPayload.SingleUpdateReportGroup = $BlankArray
        $DupReportPayload.SingleUpdateReportTargets += $ParamHash.DeviceId
    }
    return $DupReportPayload | ConvertTo-Json
}


function Update-OMEFirmwareDUP {
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
    Update firmware via DUP (EXE) on devices in OpenManage Enterprise
.DESCRIPTION
    This will upload a DUP (EXE) file and submit a Job that updates firmware on a set of devices.
    If you encounter the error "An existing connection was forcibly closed by the remote host" close and reopen the PowerShell console. Not sure what is causing this.
.PARAMETER Name
    Name of the firmware update job
.PARAMETER Device
    Array of type Device returned from Get-OMEDevice function. Used to determine what devices to update.
.PARAMETER Group
    Array of type Group returned from Get-OMEGroup function. Used to determine what groups to update.
.PARAMETER ResetiDRAC
    This option will restart the iDRAC. Occurs immediately, regardless if StageForNextReboot is set
.PARAMETER ClearJobQueue
    This option clears any active or pending jobs. Occurs immediately, regardless if StageForNextReboot is set
.PARAMETER UpdateSchedule
    Determines when the updates will be performed. (Default="Preview", "RebootNow", "ScheduleLater", "StageForNextReboot")
.PARAMETER UpdateScheduleCron
    Cron string to schedule updates at a later time. Uses UTC time. Used with -UpdateSchedule "ScheduleLater"
.PARAMETER Wait
    Wait for job to complete
.PARAMETER WaitTime
    Time, in seconds, to wait for the job to complete
.INPUTS
    None
.EXAMPLE
    "C86C0ZZ" | Get-OMEDevice | Update-OMEFirmwareDUP -UpdateSchedule "Preview" -DupFile "C:\Temp\Network_Firmware_DK4G2_WN64_20.0.17_A00.EXE"
    Display device compliance report for device. No updates are installed by default.
.EXAMPLE
    "C86C0ZZ" | Get-OMEDevice | Update-OMEFirmwareDUP -UpdateSchedule "RebootNow" -DupFile "C:\Temp\Network_Firmware_DK4G2_WN64_20.0.17_A00.EXE" -Wait
    Update firmware immediately and wait to job to complete ***Warning: This will force a reboot of all servers
.EXAMPLE
    "C86C0ZZ" | Get-OMEDevice | Update-OMEFirmwareDUP -UpdateSchedule "StageForNextReboot" -DupFile "C:\Temp\Network_Firmware_DK4G2_WN64_20.0.17_A00.EXE"
    Update firmware on next reboot
.EXAMPLE
    "C86C0ZZ" | Get-OMEDevice | Update-OMEFirmwareDUP -UpdateSchedule "ScheduleLater" -UpdateScheduleCron "0 0 0 1 11 ?" -DupFile "C:\Temp\Network_Firmware_DK4G2_WN64_20.0.17_A00.EXE"
    Update firmware on 11/1/2020 12:00AM UTC
.EXAMPLE
    "C86C0ZZ" | Get-OMEDevice | Update-OMEFirmwareDUP -UpdateSchedule "StageForNextReboot" -ClearJobQueue -DupFile "C:\Temp\Network_Firmware_DK4G2_WN64_20.0.17_A00.EXE"
    Update firmware on next reboot and clear job queue before update
.EXAMPLE
    "TestGroup" | Get-OMEGroup | Update-OMEFirmwareDUP -UpdateSchedule "RebootNow" -DupFile "C:\Temp\Network_Firmware_DK4G2_WN64_20.0.17_A00.EXE"
    Update firmware on all devices in group immediately ***Warning: This will force a reboot of all servers
#>

[CmdletBinding()]
param(
    [Parameter(Mandatory=$false)]
    [String]$Name = "Update Firmware With DUP $((Get-Date).ToString('yyyyMMddHHmmss'))",

    [Parameter(Mandatory)]
    [ValidateScript( {
            if (-Not ($_ | Test-Path) ) {
                throw "File or folder does not exist" 
            }
            if (-Not ($_ | Test-Path -PathType Leaf) ) {
                throw "The Path argument must be a file. Folder paths are not allowed."
            }
            return $true
        })]
    [System.IO.FileInfo]$DupFile,

    [Parameter(Mandatory=$false, ValueFromPipeline)]
    [Group]$Group,

    [Parameter(Mandatory=$false, ValueFromPipeline)]
    [Device]$Device,

    [Parameter(Mandatory=$false)]
    [ValidateSet("Preview", "RebootNow", "ScheduleLater", "StageForNextReboot")]
    [String]$UpdateSchedule = "Preview",

    [Parameter(Mandatory=$false)]
    [String]$UpdateScheduleCron,

    [Parameter(Mandatory=$false)]
    [Switch]$ResetiDRAC,

    [Parameter(Mandatory=$false)]
    [Switch]$ClearJobQueue,

    [Parameter(Mandatory=$false)]
    [Switch]$Wait,

    [Parameter(Mandatory=$false)]
    [int]$WaitTime = 3600
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
        $ContentType  = "application/json"
        $Headers = @{}
        $Headers."X-Auth-Token" = $SessionAuth.Token

        ## Validate that the DUP is non empty and upload to OME
        $DupFileLength = (Get-Item $DupFile).Length 
        Write-Verbose "Successfully parsed $($DupFile) - Size: $($DupFileLength) bytes"
        if ($DupFileLength -gt 0) {
            ## Upload the DUP file and get the file token for it from OME
            $FileTokenInfo = Push-DupToOME -BaseUri $BaseUri -Headers $Headers -DupFile $DupFile
            if ($FileTokenInfo) {
                if ($Group) {
                    $DupReportPayload = Set-DupApplicabilityPayload -FileTokenInfo $FileTokenInfo -ParamHash @{"GroupId" = $Group.Id }
                }
                else {
                    $DupReportPayload = Set-DupApplicabilityPayload -FileTokenInfo $FileTokenInfo -ParamHash @{"DeviceId" = $Device.Id }
                }
                Write-Verbose "Determining if any devices and components are applicable for $($DupFile)"
                $DupUpdatePayload = Get-ApplicableComponents -BaseUri $BaseUri -Headers $Headers -ContentType $ContentType -DupReportPayload $DupReportPayload -JobName $Name -UpdateSchedule $UpdateSchedule -UpdateScheduleCron $UpdateScheduleCron -ResetiDRAC $ResetiDRAC.IsPresent -ClearJobQueue $ClearJobQueue.IsPresent 
                if ($UpdateSchedule -eq "Preview") { # Only show report, do not perform any updates
                    return $DupUpdatePayload
                } else { # Submit update job
                    if ($DupUpdatePayload -and ($DupUpdatePayload."Targets".Length -gt 0)) {
                        $JobBody = $DupUpdatePayload | ConvertTo-Json -Depth 6
                        $JobSvcUrl = $BaseUri + "/api/JobService/Jobs"
                        Write-Verbose $JobBody
                        $JobResp = Invoke-WebRequest -Uri $JobSvcUrl -Method Post -Body $JobBody -Headers $Headers -ContentType $ContentType
                        if ($JobResp.StatusCode -eq 201) {
                            $JobInfo = $JobResp.Content | ConvertFrom-Json
                            $JobId = $JobInfo.Id
                            Write-Verbose "Created job $($JobId) to update firmware..."
                            if ($Wait) {
                                $JobStatus = $($JobId | Wait-OnJob -WaitTime $WaitTime)
                                return $JobStatus
                            } else {
                                return $JobId
                            }
                        }
                        else {
                            Write-Warning "Unable to create job for firmware update .. Exiting"
                        }
                    }
                }
                else {
                    Write-Warning "No updateable components found ... Skipping update"
                }
            }
            else {
                Write-Warning "No file token returned ... "
            }
        }
        else {
            Write-Warning "Dup file $($DupFile) is an empty file ... "
        }
    }
    Catch {
        Resolve-Error $_
    }
}

End {}

}

