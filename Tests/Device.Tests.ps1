$credentials = New-Object -TypeName System.Management.Automation.PSCredential -ArgumentList $Global:OMEUsername, $(ConvertTo-SecureString -Force -AsPlainText $Global:OMEPassword)
Connect-OMEServer -Name $Global:OMEServer -Credentials $credentials -IgnoreCertificateWarning
Describe "Device Tests" {
    BeforeEach {
        $TestDeviceHosts = @("100.79.6.22")
        $TestDeviceHostsNew = @("100.79.6.64")
        $TestDeviceServiceTags = @("37KP0Q2")
        $TestDiscoveryJobName = "TestDiscovery01"
        $TestDeviceModel = "PowerEdge R740"
        $TestGroup = "Dell iDRAC Servers"
        $TestiDRACUsername = $Global:iDRACUsername
        $TestiDRACPassword = $Global:iDRACPassword
    }
    Context "Discovery Job Checks" {
        It "NewDiscoveryJob > Should return a discovery job id" {
            New-OMEDiscovery -Name $TestDiscoveryJobName -Hosts $TestDeviceHosts -DiscoveryUserName $TestiDRACUsername -DiscoveryPassword $(ConvertTo-SecureString $TestiDRACPassword -AsPlainText -Force) -Wait | Should -BeGreaterThan 0
        }

        It "GetDiscoveryJob > Should return 1 discovery job" {
            $TestDiscoveryJobName | Get-OMEDiscovery | Measure-Object | Select-Object -ExpandProperty Count | Should -Be 1
        }

        It "EditDiscoveryJobAppend > Should return 2 targets hosts" {
            $TestDiscoveryJobName | Get-OMEDiscovery | Edit-OMEDiscovery -Hosts $TestDeviceHostsNew -Mode "Append" -DiscoveryUserName $TestiDRACUsername -DiscoveryPassword $(ConvertTo-SecureString $TestiDRACPassword -AsPlainText -Force)
            $TestDiscoveryJobName | Get-OMEDiscovery | Select-Object -ExpandProperty Hosts | Measure-Object | Select-Object -ExpandProperty Count | Should -Be 2
        }

        It "EditDiscoveryJobRemove > Should return 1 target hosts" {
            $TestDiscoveryJobName | Get-OMEDiscovery | Edit-OMEDiscovery -Hosts $TestDeviceHostsNew -Mode "Remove" -DiscoveryUserName $TestiDRACUsername -DiscoveryPassword $(ConvertTo-SecureString $TestiDRACPassword -AsPlainText -Force)
            $TestDiscoveryJobName | Get-OMEDiscovery | Select-Object -ExpandProperty Hosts | Measure-Object | Select-Object -ExpandProperty Count | Should -Be 1
        }

        It "EditDiscoveryJobKeepHosts > Should return 1 target hosts" {
            $TestDiscoveryJobName | Get-OMEDiscovery | Edit-OMEDiscovery -DiscoveryUserName $TestiDRACUsername -DiscoveryPassword $(ConvertTo-SecureString $TestiDRACPassword -AsPlainText -Force)
            $TestDiscoveryJobName | Get-OMEDiscovery | Select-Object -ExpandProperty Hosts | Measure-Object | Select-Object -ExpandProperty Count | Should -Be 1
        }

        It "EditDiscoveryJobRunLater > Should return matching cron string" {
            $TestCron = "0 0 0 ? * sun *"
            $TestDiscoveryJobName | Get-OMEDiscovery | Edit-OMEDiscovery -Schedule "RunLater" -ScheduleCron $TestCron -DiscoveryUserName $TestiDRACUsername -DiscoveryPassword $(ConvertTo-SecureString $TestiDRACPassword -AsPlainText -Force)
            $TestDiscoveryJobName | Get-OMEDiscovery | Select-Object -ExpandProperty Schedule | Select-Object -ExpandProperty Cron | Should -Be $TestCron
        }
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
    }
}