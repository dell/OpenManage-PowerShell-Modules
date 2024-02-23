$credentials = New-Object -TypeName System.Management.Automation.PSCredential -ArgumentList $Global:OMEUsername, $(ConvertTo-SecureString -Force -AsPlainText $Global:OMEPassword)
Connect-OMEServer -Name $Global:OMEServer -Credentials $credentials -IgnoreCertificateWarning
Describe "Device Tests" {
    BeforeAll {
        $Script:TestDeviceHosts = @("100.77.14.41", "100.77.14.42", "100.77.14.55")
        $Script:TestDeviceHostsNew = @("100.77.14.62")
        $Script:TestDeviceHostsSSH = @("100.77.18.47")
        $Script:TestDiscoveryJobName = "TestDiscovery_$((Get-Date).ToString('yyyyMMddHHmmss'))"
        $Script:TestDiscoveryJobNameSSH = "$($Script:TestDiscoveryJobName)_SSH"
        $Script:TestiDRACUsername = $Global:iDRACUsername
        $Script:TestiDRACPassword = $Global:iDRACPassword
        $Script:TestSSHUsername = $Global:SSHUsername
        $Script:TestSSHPassword = $Global:SSHPassword
    }
    Context "Discovery Job Checks" {
        It "NewDiscoveryJob > Should return a discovery job id" {
            New-OMEDiscovery -Name $Script:TestDiscoveryJobName -Hosts $Script:TestDeviceHosts -DiscoveryUserName $Script:TestiDRACUsername -DiscoveryPassword $(ConvertTo-SecureString $Script:TestiDRACPassword -AsPlainText -Force) -Wait | Should -BeGreaterThan 0
        }

        It "NewDiscoveryJobSSH > Should return a discovery job id" -Tag "SSH" {
            New-OMEDiscovery -Name $Script:TestDiscoveryJobNameSSH -Hosts $Script:TestDeviceHostsSSH `
                -Protocol "SSH" `
                -DiscoveryUserName $Script:TestSSHUsername `
                -DiscoveryPassword $(ConvertTo-SecureString $Script:TestSSHPassword -AsPlainText -Force) `
                -Wait | Should -BeGreaterThan 0
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