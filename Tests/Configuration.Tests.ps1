$credentials = New-Object -TypeName System.Management.Automation.PSCredential -ArgumentList $Global:OMEUsername, $(ConvertTo-SecureString -Force -AsPlainText $Global:OMEPassword)
Connect-OMEServer -Name $Global:OMEServer -Credentials $credentials # -IgnoreCertificateWarning
Describe "Compliance Tests" {
    BeforeEach {
        $CatalogName = "Test01"
        #$BaselineName = "TestBaseline01"
        $DeviceServiceTag = "37KP0Q2"
    }
    Context "Checks 1" {
        $xml = '
        <SystemConfiguration>
            <Component FQDD="iDRAC.Embedded.1">
                <Attribute Name="Users.12#UserName">testuser</Attribute>
            </Component>
        </SystemConfiguration>
        '
        $TemplateNameFromString = "TestComplianceTemplate_FromString_$((Get-Date).ToString('yyyyMMddHHmmss'))"
        New-OMETemplateFromFile -Name $TemplateNameFromString -TemplateType "Compliance" -Content $xml -Wait -Verbose

        It ("Should create and return new Baseline object") {
            # Need to implement Delete-ConfigurationBaseline
            $template = $($TemplateNameFromString | Get-OMETemplate -FilterBy "Name")
            $devices = $($DeviceServiceTag | Get-OMEDevice -FilterBy "ServiceTag")
            $BaselineName = "TestBaseline_$((Get-Date).ToString('yyyyMMddHHmmss'))"
            New-OMEConfigurationBaseline -Name $BaselineName -Template $template -Devices $devices -Wait -Verbose
            $BaselineName | Get-OMEConfigurationBaseline | Measure-Object | Select-Object -ExpandProperty Count | Should -Be 1
        }

        It ("Should return data from firmware compliance report"){
            $devices = $($DeviceServiceTag | Get-OMEDevice -FilterBy "ServiceTag")
            $BaselineName | Get-OMEConfigurationBaseline | Get-OMEComplianceCompliance -DeviceFilter $devices -UpdateAction "All" | Measure-Object | Select-Object -ExpandProperty Count | Should -BeGreaterThan 0
        }

        It ("Should update firmware but show preview only") {
            $devices = $($DeviceServiceTag | Get-OMEDevice -FilterBy "ServiceTag")
            $baseline = $($BaselineName | Get-OMEConfigurationBaseline)
            Update-OMECompliance -Baseline $baseline -DeviceFilter $devices -UpdateAction "All" -UpdateSchedule "Preview" -ComponentFilter "PERC" -Verbose | Measure-Object | Select-Object -ExpandProperty Count | Should -BeGreaterThan 0
        }

        #It ("Should try to update firmware") {
        #    $devices = $($DeviceServiceTag | Get-OMEDevice -FilterBy "ServiceTag")
        #    $baseline = $($BaselineName | Get-OMEConfigurationBaseline)
        #    Update-OMECompliance -Baseline $baseline -DeviceFilter $devices -UpdateAction "All" -UpdateSchedule "StageForNextReboot" -ComponentFilter "PERC" -Wait -Verbose | Should -Be "Completed"
        #}

    }
}