$credentials = New-Object -TypeName System.Management.Automation.PSCredential -ArgumentList $Global:OMEUsername, $(ConvertTo-SecureString -Force -AsPlainText $Global:OMEPassword)
Connect-OMEServer -Name $Global:OMEServer -Credentials $credentials -IgnoreCertificateWarning
Describe "Group Tests" {
    BeforeEach {
        $TestDeviceModel = "PowerEdge R640"
        $TestGroup = "Dell iDRAC Servers"
        $TestNewGroup = "TestGroup01"
        $TestNewGroupEdit = "TestGroup02"
    }
    Context "Group Checks" {
        It "Should return ALL Groups" {
            Get-OMEGroup | Measure-Object | Select-Object -ExpandProperty Count | Should -BeGreaterThan 2
        }

        It "Should return a specific Group" {
            $TestGroup | Get-OMEGroup | Select-Object -ExpandProperty Name | Should -Be $TestGroup
        }

        It "Should return Devices by Group" {
            $TestGroup | Get-OMEGroup | Get-OMEDevice | Measure-Object | Select-Object -ExpandProperty Count | Should -BeGreaterThan 0
        }

        It "Should create new Group" {
            New-OMEGroup -Name $TestNewGroup -Verbose
            $TestNewGroup | Get-OMEGroup -Verbose | Select-Object -ExpandProperty Name | Should -Be $TestNewGroup
        }

        It "Should edit Group name" {
            $TestNewGroup | Get-OMEGroup | Edit-OMEGroup -Name $TestNewGroupEdit -Description "This is a test" -Verbose
            $TestNewGroupEdit | Get-OMEGroup -Verbose | Select-Object -ExpandProperty Name | Should -Be $TestNewGroupEdit
        }

        It "Should added Devices to Group" {
            $TestNewGroupEdit | Get-OMEGroup | Edit-OMEGroup -Devices $($TestDeviceModel | Get-OMEDevice -FilterBy "Model")
            $TestNewGroupEdit | Get-OMEGroup | Get-OMEDevice | Measure-Object | Select-Object -ExpandProperty Count | Should -BeGreaterThan 0
        }

        It "Should remove Devices from Group" {
            $TestNewGroupEdit | Get-OMEGroup | Edit-OMEGroup -Mode "Remove" -Devices $($TestNewGroupEdit | Get-OMEGroup | Get-OMEDevice)
            $TestNewGroupEdit | Get-OMEGroup | Get-OMEDevice | Measure-Object | Select-Object -ExpandProperty Count | Should -Be 0
        }

        It "Should remove Group" {
            $TestNewGroupEdit | Get-OMEGroup | Remove-OMEGroup
            $TestNewGroupEdit | Get-OMEGroup | Measure-Object | Select-Object -ExpandProperty Count | Should -Be 0
        }
    }
}