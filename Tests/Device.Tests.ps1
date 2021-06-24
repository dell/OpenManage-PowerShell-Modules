$credentials = New-Object -TypeName System.Management.Automation.PSCredential -ArgumentList $Global:OMEUsername, $(ConvertTo-SecureString -Force -AsPlainText $Global:OMEPassword)
Connect-OMEServer -Name $Global:OMEServer -Credentials $credentials -IgnoreCertificateWarning
Describe "Device Tests" {
    BeforeEach {
        $TestDeviceServiceTags = @("37KP0Q2")
        $TestDeviceModel = "PowerEdge R740"
    }
    Context "Device Checks" {
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

        It "Should return device inventory" {
            $TestDeviceServiceTags | Get-OMEDevice | Get-OMEDeviceDetail -InventoryType "deviceSoftware" | Measure-Object | Select-Object -ExpandProperty Count | Should -BeGreaterThan 0
        }

        It "Should refresh device inventory" {
            $TestDeviceServiceTags | Get-OMEDevice | Invoke-OMEInventoryRefresh | Should -BeOfType System.Int64
        }
    }
}