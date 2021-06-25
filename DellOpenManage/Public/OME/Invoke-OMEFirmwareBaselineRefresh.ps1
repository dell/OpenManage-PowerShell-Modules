using module ..\..\Classes\Device.psm1
using module ..\..\Classes\Group.psm1
using module ..\..\Classes\Template.psm1
using module ..\..\Classes\FirmwareBaseline.psm1

function Invoke-OMEFirmwareBaselineRefresh {
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
    Check or refresh compliance for a firmware baseline
.DESCRIPTION
    A baseline is used to compare firmware versions against a catalog
.PARAMETER Baseline
    Object of type FirmwareBaseline returned from Get-OMEFirmwareBaseline function
.PARAMETER Wait
    Wait for job to complete
.PARAMETER WaitTime
    Time, in seconds, to wait for the job to complete
.INPUTS
    FirmwareBaseline
.EXAMPLE
    "TestBaseline01"  | Get-OMEFirmwareBaseline | Invoke-OMEFirmwareBaselineRefresh -Wait
    Refresh compliance for firmware baseline
#>

[CmdletBinding()]
param(
    [Parameter(Mandatory, ValueFromPipeline)]
    [FirmwareBaseline]$Baseline,

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
        $Type = "application/json"
        $Headers = @{}
        $Headers."X-Auth-Token" = $SessionAuth.Token

        # Use the TaskId from the Baseline to run the job which executes "Check Compliance" on the Baseline
        $Baseline.TaskId | Invoke-OMEJobRun | Out-Null
        # Since we can't check the status for a Baseline refresh job the standard way. We have to use a specific function for this.
        if ($Wait) {
            $JobStatus = $($Baseline.Name | Wait-OnFirmwareBaseline -WaitTime $WaitTime)
            return $JobStatus
        } else {
            return "Completed"
        }
    }
    Catch {
        Resolve-Error $_
    }
}

End {}

}

