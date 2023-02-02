$credentials = New-Object -TypeName System.Management.Automation.PSCredential -ArgumentList $Global:OMEUsername, $(ConvertTo-SecureString -Force -AsPlainText $Global:OMEPassword)
Connect-OMEServer -Name $Global:OMEServer -Credentials $credentials -IgnoreCertificateWarning
Describe "Device Tests" {
    BeforeAll {
        $Script:TestDeviceHosts = @("100.77.14.129", "100.77.14.34", "100.77.14.172")
        $Script:TestDeviceHostsNew = @("100.77.14.13")
        $Script:TestDiscoveryJobName = "TestDiscovery_$((Get-Date).ToString('yyyyMMddHHmmss'))"
        $Script:TestiDRACUsername = $Global:iDRACUsername
        $Script:TestiDRACPassword = $Global:iDRACPassword
    }
    Context "Discovery Job Checks" {
        It "NewDiscoveryJob > Should return a discovery job id" {
            New-OMEDiscovery -Name $Script:TestDiscoveryJobName -Hosts $Script:TestDeviceHosts -DiscoveryUserName $Script:TestiDRACUsername -DiscoveryPassword $(ConvertTo-SecureString $Script:TestiDRACPassword -AsPlainText -Force) -Wait | Should -BeGreaterThan 0
        }

        It "GetDiscoveryJob > Should return 1 discovery job" {
            $Script:TestDiscoveryJobName | Get-OMEDiscovery | Measure-Object | Select-Object -ExpandProperty Count | Should -Be 1
        }

        It "EditDiscoveryJobAppend > Should return 4 targets hosts" {
            $Script:TestDiscoveryJobName | Get-OMEDiscovery | Edit-OMEDiscovery -Hosts $Script:TestDeviceHostsNew -Mode "Append" -DiscoveryUserName $Script:TestiDRACUsername -DiscoveryPassword $(ConvertTo-SecureString $Script:TestiDRACPassword -AsPlainText -Force)
            $Script:TestDiscoveryJobName | Get-OMEDiscovery | Select-Object -ExpandProperty Hosts | Measure-Object | Select-Object -ExpandProperty Count | Should -Be 4
        }

        It "EditDiscoveryJobRemove > Should return 3 target hosts" {
            $Script:TestDiscoveryJobName | Get-OMEDiscovery | Edit-OMEDiscovery -Hosts $Script:TestDeviceHostsNew -Mode "Remove" -DiscoveryUserName $Script:TestiDRACUsername -DiscoveryPassword $(ConvertTo-SecureString $Script:TestiDRACPassword -AsPlainText -Force)
            $Script:TestDiscoveryJobName | Get-OMEDiscovery | Select-Object -ExpandProperty Hosts | Measure-Object | Select-Object -ExpandProperty Count | Should -Be 3
        }

        It "EditDiscoveryJobKeepHosts > Should return 3 target hosts" {
            $Script:TestDiscoveryJobName | Get-OMEDiscovery | Edit-OMEDiscovery -DiscoveryUserName $Script:TestiDRACUsername -DiscoveryPassword $(ConvertTo-SecureString $Script:TestiDRACPassword -AsPlainText -Force)
            $Script:TestDiscoveryJobName | Get-OMEDiscovery | Select-Object -ExpandProperty Hosts | Measure-Object | Select-Object -ExpandProperty Count | Should -Be 3
        }

        It "EditDiscoveryJobRunLater > Should return matching cron string" {
            $TestCron = "0 0 0 ? * sun *"
            $Script:TestDiscoveryJobName | Get-OMEDiscovery | Edit-OMEDiscovery -Schedule "RunLater" -ScheduleCron $TestCron -DiscoveryUserName $Script:TestiDRACUsername -DiscoveryPassword $(ConvertTo-SecureString $Script:TestiDRACPassword -AsPlainText -Force)
            $Script:TestDiscoveryJobName | Get-OMEDiscovery | Select-Object -ExpandProperty Schedule | Select-Object -ExpandProperty Cron | Should -Be $TestCron
        }
    }
}