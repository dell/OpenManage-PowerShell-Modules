$credentials = New-Object -TypeName System.Management.Automation.PSCredential -ArgumentList $Global:OMEUsername, $(ConvertTo-SecureString -Force -AsPlainText $Global:OMEPassword)
Connect-OMEServer -Name $Global:OMEServer -Credentials $credentials # -IgnoreCertificateWarning
Describe "Firmware Tests" {
    BeforeEach {
        $TemplateNameFromString = "TestTemplate_FromString_$((Get-Date).ToString('yyyyMMddHHmmss'))"
        $TemplateNameFromFile = "TestTemplate_FromFile_$((Get-Date).ToString('yyyyMMddHHmmss'))"
        $DeviceServiceTag = "37KP0Q2"
    }
    Context "Checks 1" {     
        It "Should return ALL Templates" {
            Get-OMETemplate | Measure-Object | Select-Object -ExpandProperty Count | Should -BeGreaterThan 2
        }
        
        It ("Should create template from source device and return JobId"){
            $TemplateName = "TestTemplate_FromDevice_$((Get-Date).ToString('yyyyMMddHHmmss'))"
            New-OMETemplateFromDevice -Name $TemplateName -Device $($DeviceServiceTag | Get-OMEDevice -FilterBy "ServiceTag") -Component "All" -Verbose | Should -BeGreaterThan 0
        }

        It ("Should create a new template from XML string located in a file") {
            $xml = Get-Content -Path .\Tests\Data\Test01.xml | Out-String
            New-OMETemplateFromFile -Name $TemplateNameFromFile -Content $xml -Wait -Verbose
            $TemplateNameFromFile | Get-OMETemplate -FilterBy "Name" | Select-Object -ExpandProperty Name | Should -Be $TemplateNameFromFile
        }

        It ("Should create a new template from XML string") {
            $xml = '
            <SystemConfiguration>
                <Component FQDD="iDRAC.Embedded.1">
                    <Attribute Name="Users.12#UserName">testuser</Attribute>
                </Component>
            </SystemConfiguration>
            '
            New-OMETemplateFromFile -Name $TemplateNameFromString -Content $xml -Wait -Verbose
            $TemplateNameFromString | Get-OMETemplate -FilterBy "Name" | Select-Object -ExpandProperty Name | Should -Be $TemplateNameFromString
        }
       
    }
}