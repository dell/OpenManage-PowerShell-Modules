$credentials = New-Object -TypeName System.Management.Automation.PSCredential -ArgumentList $Global:OMEUsername, $(ConvertTo-SecureString -Force -AsPlainText $Global:OMEPassword)
Connect-OMEServer -Name $Global:OMEServer -Credentials $credentials -IgnoreCertificateWarning
Describe "Compliance Tests" {
    BeforeEach {
        $BaselineName = "TestBaseline01"
        $TemplateNameFromString = "TestComplianceTemplate01"
        $DeviceServiceTags = @("37KP0Q2", "JCWXH63")
    }
    Context "Checks 1" {
        It ("Should create a new configuration template from XML string") {
            $xml = '
            <SystemConfiguration>
                <Component FQDD="iDRAC.Embedded.1">
                    <Attribute Name="Users.12#UserName">testuser</Attribute>
                </Component>
            </SystemConfiguration>
            '
            New-OMETemplateFromFile -Name $TemplateNameFromString -TemplateType "Compliance" -Content $xml -Wait -Verbose
            $TemplateNameFromString | Get-OMETemplate -FilterBy "Name" | Select-Object -ExpandProperty Name | Should -Be $TemplateNameFromString
            $TemplateNameFromString | Get-OMETemplate -FilterBy "Name" | Select-Object -ExpandProperty ViewTypeId | Should -Be 1
        }

        It ("Should create and return new Baseline object") {
            $template = $($TemplateNameFromString | Get-OMETemplate -FilterBy "Name")
            $devices = $($DeviceServiceTags | Get-OMEDevice -FilterBy "ServiceTag")
            New-OMEConfigurationBaseline -Name $BaselineName -Template $template -Devices $devices -Wait -Verbose
            $BaselineName | Get-OMEConfigurationBaseline | Measure-Object | Select-Object -ExpandProperty Count | Should -Be 1
        }

        It ("Should update configuration on all devices") {
            $baseline = $($BaselineName | Get-OMEConfigurationBaseline)
            $JobName = "MakeCompliant_AllDevices_$((Get-Date).ToString('yyyyMMddHHmmss'))"
            $JobId = Update-OMEConfiguration -Name $JobName -Baseline $baseline -Verbose
            $JobId | Get-OMEJob -FilterBy "Id" | Select-Object -ExpandProperty Targets | Measure-Object | Select-Object -ExpandProperty Count | Should -Be 2
        }

        It ("Should update configuration on devices by filter") {
            $devices = $($DeviceServiceTags[0] | Get-OMEDevice -FilterBy "ServiceTag")
            $baseline = $($BaselineName | Get-OMEConfigurationBaseline)
            $JobName = "MakeCompliant_SingleDevice_$((Get-Date).ToString('yyyyMMddHHmmss'))"
            $JobId = Update-OMEConfiguration -Name $JobName -Baseline $baseline -DeviceFilter $devices -Verbose
            $JobId | Get-OMEJob -FilterBy "Id" | Select-Object -ExpandProperty Targets | Measure-Object | Select-Object -ExpandProperty Count | Should -Be 1
        }
    }
}