$credentials = New-Object -TypeName System.Management.Automation.PSCredential -ArgumentList $Global:OMEUsername, $(ConvertTo-SecureString -Force -AsPlainText $Global:OMEPassword)
Connect-OMEServer -Name $Global:OMEServer -Credentials $credentials -IgnoreCertificateWarning
Describe "Template Tests" {
    BeforeAll {
        $Script:DeviceServiceTag1 = "9Z39MH3"
        $Script:DeviceServiceTag2 = "9Z38MH3"
        $Script:DeviceServiceTag3 = "6VQS5X3"
        $Script:ConfigurationBaselineName = "TestConfigurationBaseline_$((Get-Date).ToString('yyyyMMddHHmmss'))"
        $Script:DeploymentTemplateNameFromDevice = "TestDeploymentTemplate_FromDevice_$((Get-Date).ToString('yyyyMMddHHmmss'))"
        $Script:DeploymentTemplateNameFromFile = "TestDeploymentTemplate_FromFile_$((Get-Date).ToString('yyyyMMddHHmmss'))"
        $Script:DeploymentTemplateNameFromString = "TestDeploymentTemplate_FromString_$((Get-Date).ToString('yyyyMMddHHmmss'))"
        $Script:DeploymentTemplateNameFromStringClone = "$($Script:DeploymentTemplateNameFromString) - Clone"
        $Script:ConfigurationTemplateNameFromDevice = "TestComplianceTemplate_FromDevice_$((Get-Date).ToString('yyyyMMddHHmmss'))"
        $Script:ConfigurationTemplateNameFromFile = "TestComplianceTemplate_FromFile_$((Get-Date).ToString('yyyyMMddHHmmss'))"
        $Script:ConfigurationTemplateNameFromString = "TestConfigurationTemplate_FromString_$((Get-Date).ToString('yyyyMMddHHmmss'))"
    }
    Context "General" {
        It "Should return ALL templates" {
            Get-OMETemplate | Measure-Object | Select-Object -ExpandProperty Count | Should -BeGreaterThan 2
        }
    }
    Context "Deployment" -Tag "Deployment" {
        It ("Should create a deployment template from source device and return JobId"){
            $TemplateName = $Script:DeploymentTemplateNameFromDevice
            New-OMETemplateFromDevice -Name $TemplateName -Device $($Script:DeviceServiceTag1 | Get-OMEDevice -FilterBy "ServiceTag") -Component "All" | Should -BeGreaterThan 0
        }

        It ("Should create a new deployment template from XML string located in a file") {
            $xml = Get-Content -Path .\Tests\Data\Test01.xml | Out-String
            $TemplateNameFromFile = $Script:DeploymentTemplateNameFromFile
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
            New-OMETemplateFromFile -Name $Script:DeploymentTemplateNameFromString -Content $xml -Wait
            $Script:DeploymentTemplateNameFromString | Get-OMETemplate -FilterBy "Name" | Select-Object -ExpandProperty Name | Should -Be $Script:DeploymentTemplateNameFromString
            $Script:DeploymentTemplateNameFromString | Get-OMETemplate -FilterBy "Name" | Select-Object -ExpandProperty ViewTypeId | Should -Be 2
        }

        It "Should return all deployment templates" {
            "Deployment" | Get-OMETemplate -FilterBy "Type" | Measure-Object | Select-Object -ExpandProperty Count | Should -BeGreaterThan 1
        }

        It "Should return multiple deployment templates with a similar name" {
            "TestDeploymentTemplate" | Get-OMETemplate -FilterBy "Name" | Measure-Object | Select-Object -ExpandProperty Count | Should -BeGreaterThan 1
        }

        It "Should deploy template to device" {
            $template = $($Script:DeploymentTemplateNameFromString | Get-OMETemplate)
            $devices = $Script:DeviceServiceTag1, $Script:DeviceServiceTag2, $Script:DeviceServiceTag3 | Get-OMEDevice
            Invoke-OMETemplateDeploy -Template $template -Devices $devices -Wait | Should -BeIn @("Completed", "Warning")
        }

        It "Should clone template" {
            $template = $($Script:DeploymentTemplateNameFromString | Get-OMETemplate)
            $template | Copy-OMETemplate -Name $Script:DeploymentTemplateNameFromStringClone
            $Script:DeploymentTemplateNameFromStringClone | Get-OMETemplate -FilterBy "Name" | Select-Object -ExpandProperty Name | Should -Be $Script:DeploymentTemplateNameFromStringClone
        }

        It "Should remove deploy templates" {
            Get-OMETemplate | Where-Object -Property "Name" -EQ $Script:DeploymentTemplateNameFromDevice | Remove-OMETemplate
            $Script:DeploymentTemplateNameFromDevice | Get-OMETemplate | Measure-Object | Select-Object -ExpandProperty Count | Should -Be 0
            Get-OMETemplate | Where-Object -Property "Name" -EQ $Script:DeploymentTemplateNameFromFile | Remove-OMETemplate
            $Script:DeploymentTemplateNameFromFile | Get-OMETemplate | Measure-Object | Select-Object -ExpandProperty Count | Should -Be 0
            Get-OMETemplate | Where-Object -Property "Name" -EQ $Script:DeploymentTemplateNameFromString | Remove-OMETemplate
            Get-OMETemplate | Where-Object -Property "Name" -EQ $Script:DeploymentTemplateNameFromStringClone | Remove-OMETemplate
            $Script:DeploymentTemplateNameFromString | Get-OMETemplate | Measure-Object | Select-Object -ExpandProperty Count | Should -Be 0
        }
    }
    Context "Configuration" -Tag "Configuration" {
        It ("Should create a compliance template from source device and return JobId"){
            $TemplateName = $Script:ConfigurationTemplateNameFromDevice
            New-OMETemplateFromDevice -Name $TemplateName -TemplateType "Configuration" -Device $($Script:DeviceServiceTag2 | Get-OMEDevice -FilterBy "ServiceTag") -Component "All" | Should -BeGreaterThan 0
        }

        It ("Should create a new compliance template from XML string located in a file") {
            $xml = Get-Content -Path .\Tests\Data\Test01.xml | Out-String
            $TemplateNameFromFile = $Script:ConfigurationTemplateNameFromFile
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
            New-OMETemplateFromFile -Name $Script:ConfigurationTemplateNameFromString -TemplateType "Configuration" -Content $xml -Wait
            $Script:ConfigurationTemplateNameFromString | Get-OMETemplate -FilterBy "Name" | Select-Object -ExpandProperty Name | Should -Be $Script:ConfigurationTemplateNameFromString
            $Script:ConfigurationTemplateNameFromString | Get-OMETemplate -FilterBy "Name" | Select-Object -ExpandProperty ViewTypeId | Should -Be 1
        }

        It "Should return all compliance templates" {
            "Configuration" | Get-OMETemplate -FilterBy "Type" | Measure-Object | Select-Object -ExpandProperty Count | Should -BeGreaterThan 1
        }

        It "Should create configuration compliance baseline" {
            $devices = $Script:DeviceServiceTag3 | Get-OMEDevice -FilterBy "ServiceTag"
            $template = $Script:ConfigurationTemplateNameFromString | Get-OMETemplate
            New-OMEConfigurationBaseline -Name $Script:ConfigurationBaselineName -Template $template -Devices $devices -Wait | Should -BeIn @("Completed", "Warning")
        }

        It "Should return configuration compliance baseline" {
            $Script:ConfigurationBaselineName | Get-OMEConfigurationBaseline | Measure-Object | Select-Object -ExpandProperty Count | Should -BeGreaterThan 0
        }

        It "Should update configuration compliance on device" {
            $baseline = $Script:ConfigurationBaselineName | Get-OMEConfigurationBaseline
            $devices = $Script:DeviceServiceTag3 | Get-OMEDevice -FilterBy "ServiceTag"
            Update-OMEConfiguration -Name "Make Compliant $((Get-Date).ToString('yyyyMMddHHmmss'))" -Baseline $baseline -DeviceFilter $devices -Wait | Should -BeIn @("Completed", "Warning")
        }

        It "Should check configuration compliance for baseline" -Tag "CheckConfigurationCompliance" {
            $baseline = $Script:ConfigurationBaselineName | Get-OMEConfigurationBaseline
            $baseline  | Invoke-OMEConfigurationBaselineRefresh | Should -BeGreaterThan 0
        }
        It "Should remove configuration template from device" {
            $template = $($Script:ConfigurationTemplateNameFromDevice | Get-OMETemplate)
            $template | Remove-OMETemplate
            $Script:ConfigurationTemplateNameFromDevice | Get-OMETemplate | Measure-Object | Select-Object -ExpandProperty Count | Should -Be 0
        }
        It "Should remove configuration template from file" {
            $template = $($Script:ConfigurationTemplateNameFromFile | Get-OMETemplate)
            $template | Remove-OMETemplate
            $Script:ConfigurationTemplateNameFromFile | Get-OMETemplate | Measure-Object | Select-Object -ExpandProperty Count | Should -Be 0
        }
        It "Should remove configuration template" {
            $template = $($Script:ConfigurationTemplateNameFromString | Get-OMETemplate)
            $template | Remove-OMETemplate
            $Script:ConfigurationTemplateNameFromString | Get-OMETemplate | Measure-Object | Select-Object -ExpandProperty Count | Should -Be 0
        }
    }
    Context "Profile" -Tag "Profile" {
        It "Should unassign profile by device" {
            $devices = $Script:DeviceServiceTag1 | Get-OMEDevice
            Invoke-OMEProfileUnassign -Device $devices | Should -BeGreaterThan 0
        }

        It "Should unassign profile by profile name" {
            Invoke-OMEProfileUnassign -ProfileName "00002" | Should -BeGreaterThan 0
        }

        It "Should unassign profile by template" {
            $template = $Script:DeploymentTemplateNameFromString | Get-OMETemplate
            Invoke-OMEProfileUnassign -Template $template | Should -BeGreaterThan 0
        }
    }
}