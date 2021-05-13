$credentials = New-Object -TypeName System.Management.Automation.PSCredential -ArgumentList $Global:OMEUsername, $(ConvertTo-SecureString -Force -AsPlainText $Global:OMEPassword)
Connect-OMEServer -Name $Global:OMEServer -Credentials $credentials -IgnoreCertificateWarning
Describe "Template" {
    BeforeAll {
        $Script:DeviceServiceTag1 = "37KP0Q2"
        $Script:DeviceServiceTag2 = "C86F0Q2"
        $Script:DeviceServiceTag3 = "GV6V673"
        $Script:ConfigurationBaselineName = "TestConfigurationBaseline_$((Get-Date).ToString('yyyyMMddHHmmss'))"
    }
    Context "General" {
        It "Should return ALL templates" {
            Get-OMETemplate | Measure-Object | Select-Object -ExpandProperty Count | Should -BeGreaterThan 2
        }
    }
    Context "Deployment" {
        It ("Should create a deployment template from source device and return JobId"){
            $TemplateName = "TestDeploymentTemplate_FromDevice_$((Get-Date).ToString('yyyyMMddHHmmss'))"
            New-OMETemplateFromDevice -Name $TemplateName -Device $($Script:DeviceServiceTag1 | Get-OMEDevice -FilterBy "ServiceTag") -Component "All" | Should -BeGreaterThan 0
        }

        It ("Should create a new deployment template from XML string located in a file") {
            $xml = Get-Content -Path .\Tests\Data\Test01.xml | Out-String
            $TemplateNameFromFile = "TestDeploymentTemplate_FromFile_$((Get-Date).ToString('yyyyMMddHHmmss'))"
            New-OMETemplateFromFile -Name $TemplateNameFromFile -Content $xml -Wait
            $TemplateNameFromFile | Get-OMETemplate -FilterBy "Name" | Select-Object -ExpandProperty Name | Should -Be $TemplateNameFromFile
            $TemplateNameFromFile | Get-OMETemplate -FilterBy "Name" | Select-Object -ExpandProperty ViewTypeId | Should -Be 2
        }

        It ("Should create a new deployment template from XML string") {
            $xml = '
            <SystemConfiguration>
                <Component FQDD="iDRAC.Embedded.1">
                    <Attribute Name="Users.12#UserName">testuser</Attribute>
                </Component>
            </SystemConfiguration>
            '
            $TemplateNameFromString = "TestDeploymentTemplate_FromString_$((Get-Date).ToString('yyyyMMddHHmmss'))"
            New-OMETemplateFromFile -Name $TemplateNameFromString -Content $xml -Wait
            $TemplateNameFromString | Get-OMETemplate -FilterBy "Name" | Select-Object -ExpandProperty Name | Should -Be $TemplateNameFromString
            $TemplateNameFromString | Get-OMETemplate -FilterBy "Name" | Select-Object -ExpandProperty ViewTypeId | Should -Be 2
        }

        It "Should return all deployment templates" {
            "Deployment" | Get-OMETemplate -FilterBy "Type" | Measure-Object | Select-Object -ExpandProperty Count | Should -BeGreaterThan 1
        }

        It "Should return multiple deployment templates with a similar name" {
            "TestDeploymentTemplate" | Get-OMETemplate -FilterBy "Name" | Measure-Object | Select-Object -ExpandProperty Count | Should -BeGreaterThan 1
        }

        It "Should deploy template to device" {
            $template = $("TestDeploymentTemplate_FromString" | Get-OMETemplate | Select-Object -first 1)
            $devices = $Script:DeviceServiceTag1, $Script:DeviceServiceTag2, $Script:DeviceServiceTag3 | Get-OMEDevice
            Invoke-OMETemplateDeploy -Template $template -Devices $devices -Wait | Should -Be "Completed"
        }
    }
    Context "Configuration" {
        It ("Should create a compliance template from source device and return JobId"){
            $TemplateName = "TestComplianceTemplate_FromDevice_$((Get-Date).ToString('yyyyMMddHHmmss'))"
            New-OMETemplateFromDevice -Name $TemplateName -TemplateType "Configuration" -Device $($Script:DeviceServiceTag1 | Get-OMEDevice -FilterBy "ServiceTag") -Component "All" | Should -BeGreaterThan 0
        }

        It ("Should create a new compliance template from XML string located in a file") {
            $xml = Get-Content -Path .\Tests\Data\Test01.xml | Out-String
            $TemplateNameFromFile = "TestComplianceTemplate_FromFile_$((Get-Date).ToString('yyyyMMddHHmmss'))"
            New-OMETemplateFromFile -Name $TemplateNameFromFile -TemplateType "Configuration" -Content $xml -Wait
            $TemplateNameFromFile | Get-OMETemplate -FilterBy "Name" | Select-Object -ExpandProperty Name | Should -Be $TemplateNameFromFile
            $TemplateNameFromFile | Get-OMETemplate -FilterBy "Name" | Select-Object -ExpandProperty ViewTypeId | Should -Be 1
        }

        It ("Should create a new compliance template from XML string") {
            $xml = '
            <SystemConfiguration>
                <Component FQDD="iDRAC.Embedded.1">
                    <Attribute Name="Users.12#UserName">testuser</Attribute>
                </Component>
            </SystemConfiguration>
            '
            $TemplateNameFromString = "TestComplianceTemplate_FromString_$((Get-Date).ToString('yyyyMMddHHmmss'))"
            New-OMETemplateFromFile -Name $TemplateNameFromString -TemplateType "Configuration" -Content $xml -Wait
            $TemplateNameFromString | Get-OMETemplate -FilterBy "Name" | Select-Object -ExpandProperty Name | Should -Be $TemplateNameFromString
            $TemplateNameFromString | Get-OMETemplate -FilterBy "Name" | Select-Object -ExpandProperty ViewTypeId | Should -Be 1
        }

        It "Should return all compliance templates" {
            "Configuration" | Get-OMETemplate -FilterBy "Type" | Measure-Object | Select-Object -ExpandProperty Count | Should -BeGreaterThan 1
        }

        It "Should create configuration compliance baseline" {
            $devices = $Script:DeviceServiceTag1 | Get-OMEDevice -FilterBy "ServiceTag"
            $template = "TestComplianceTemplate_FromString" | Get-OMETemplate | Select-Object -first 1
            New-OMEConfigurationBaseline -Name $Script:ConfigurationBaselineName -Template $template -Devices $devices -Wait | Should -Be "Completed"
        }

        It "Should return configuration compliance baseline" {
            $Script:ConfigurationBaselineName | Get-OMEConfigurationBaseline | Measure-Object | Select-Object -ExpandProperty Count | Should -BeGreaterThan 0
        }

        It "Should update configuration compliance on device" {
            $baseline = $Script:ConfigurationBaselineName | Get-OMEConfigurationBaseline
            $devices = $Script:DeviceServiceTag1 | Get-OMEDevice -FilterBy "ServiceTag"
            Update-OMEConfiguration -Name "Make Compliant $((Get-Date).ToString('yyyyMMddHHmmss'))" -Baseline $baseline -DeviceFilter $devices -Wait | Should -Be "Completed"
        }

        It "Should check configuration compliance for baseline" {
            $baseline = $Script:ConfigurationBaselineName | Get-OMEConfigurationBaseline
            $baseline  | Invoke-OMEConfigurationCheck -Wait | Should -Be "Completed"
        }
    }
    Context "Profile" {
        It "Should unassign profile by device" {
            $devices = $Script:DeviceServiceTag1 | Get-OMEDevice
            Invoke-OMEProfileUnassign -Device $devices -Wait | Should -Be "Completed"
        }

        It "Should unassign profile by profile name" {
            Invoke-OMEProfileUnassign -ProfileName "00002" -Wait | Should -Be "Completed"
        }

        It "Should unassign profile by template" {
            $template = "TestDeploymentTemplate_FromString" | Get-OMETemplate | Select-Object -first 1
            Invoke-OMEProfileUnassign -Template $template -Wait | Should -Be "Completed"
        }
    }
}