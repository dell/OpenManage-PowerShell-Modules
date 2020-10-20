$credentials = New-Object -TypeName System.Management.Automation.PSCredential -ArgumentList $Global:OMEUsername, $(ConvertTo-SecureString -Force -AsPlainText $Global:OMEPassword)
Connect-OMEServer -Name $Global:OMEServer -Credentials $credentials -IgnoreCertificateWarning
Describe "Device Tests" {
    BeforeEach {
        $TestDeviceHosts = @("100.79.6.22")
        $TestDeviceServiceTags = @("37KP0Q2")
        $TestDeviceModel = "PowerEdge R740"
        $TestGroup = "Dell iDRAC Servers"
        $TestiDRACUsername = $Global:iDRACUsername
        $TestiDRACPassword = $Global:iDRACPassword
    }
    Context "Checks 1" {
        It "Should return a discovery job id" {
            New-OMEDiscovery -Hosts $TestDeviceHosts -DiscoveryUserName $TestiDRACUsername -DiscoveryPassword $(ConvertTo-SecureString $TestiDRACPassword -AsPlainText -Force) -Wait -Verbose | Should -BeGreaterThan 0 
        }

        It "Should return ALL Devices" {
            Get-OMEDevice | Measure-Object | Select-Object -ExpandProperty Count | Should -BeGreaterThan 0
        }

        It "Should return Devices by Service Tag" {
            $TestDeviceServiceTags | Get-OMEDevice | Measure-Object | Select-Object -ExpandProperty Count | Should -BeGreaterThan 0
        }

        It "Should return Devices by Model" {
            $TestDeviceModel | Get-OMEDevice -FilterBy "Model" | Measure-Object | Select-Object -ExpandProperty Count | Should -BeGreaterThan 0
        }

        It "Should return Devices by Type" {
            "1000" | Get-OMEDevice -FilterBy "Type" | Measure-Object | Select-Object -ExpandProperty Count | Should -BeGreaterThan 0
        }

        It "Should return ALL Groups" {
            Get-OMEGroup | Select-Object -ExpandProperty Name | Should -BeGreaterThan 2
        }

        It "Should return a specific Group" {
            $TestGroup | Get-OMEGroup | Select-Object -ExpandProperty Name | Should -Be $TestGroup
        }

        It "Should return Devices by Group" {
            $TestGroup | Get-OMEGroup | Get-OMEDevice | Measure-Object | Select-Object -ExpandProperty Count | Should -BeGreaterThan 0
        }

        It "Should return device inventory" {
            $TestDeviceServiceTags | Get-OMEDevice | Get-OMEDeviceDetail -InventoryType "software" | Measure-Object | Select-Object -ExpandProperty Count | Should -BeGreaterThan 0
        }
    }
}