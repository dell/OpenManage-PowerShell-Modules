$credentials = New-Object -TypeName System.Management.Automation.PSCredential -ArgumentList $Global:OMEUsername, $(ConvertTo-SecureString -Force -AsPlainText $Global:OMEPassword)
Connect-OMEServer -Name $Global:OMEServer -Credentials $credentials -IgnoreCertificateWarning
Describe "Misc Tests" {
    BeforeAll {
        $Script:TestIdentityPoolName = "TestPool01"
    }
    Context "Alert" -Tag "Alert" {
        It "Should return ALL Alerts" {
            Get-OMEAlert | Measure-Object | Select-Object -ExpandProperty Count | Should -BeGreaterThan 1
        }

        It "Should return Alerts by Severity" {
            Get-OMEAlert -SeverityType "CRITICAL" -Top 50 | Measure-Object | Select-Object -ExpandProperty Count | Should -BeGreaterThan 1
        }
    }
    Context "Audit" -Tag "Audit" {
        It "Should return ALL Audit Logs" {
            Get-OMEAuditLog | Measure-Object | Select-Object -ExpandProperty Count | Should -BeGreaterThan 1
        }
    }
    Context "Warranty" -Tag "Warranty" {
        It "Should return ALL Warranties" {
            Get-OMEWarranty | Measure-Object | Select-Object -ExpandProperty Count | Should -BeGreaterThan 1
        }
    }
    Context "Report" -Tag "Report" {
        It "Should return ALL Reports" {
            Get-OMEReport | Measure-Object | Select-Object -ExpandProperty Count | Should -BeGreaterThan 1
        }
        It "Should return report rows" {
            $ReportId = Get-OMEReport | Where-Object 'Name' -EQ "Physical Disk Report" | Select-Object -ExpandProperty Id
            Invoke-OMEReport -ReportId $ReportId | Measure-Object | Select-Object -ExpandProperty Count | Should -BeGreaterThan 1
        }
    }
    Context "Network" -Tag "Network" {
        It "Should create new Network" {
            $TestNetwork = @{
                Name = "TestNetwork1"
                Description = "Test Network 1 Description"
                VlanMaximum = 1000
                VlanMinimum = 1000
                Type = 1
            }
            New-OMENetwork -Name $TestNetwork.Name -Description $TestNetwork.Description -VlanMaximum $TestNetwork.VlanMaximum -VlanMinimum $TestNetwork.VlanMinimum -Type $TestNetwork.Type 
            $TestNetwork.Name | Get-OMENetwork | Select-Object -Property Name | Should -Be $TestNetwork.Name
        }
        It "Should return ALL Networks" {
            Get-OMENetwork | Measure-Object | Select-Object -ExpandProperty Count | Should -BeGreaterThan 0
        }
    }
    Context "Identity Pool" -Tag "IdentityPool" {
        It "Should create an Identity Pool" {
            New-OMEIdentityPool `
                -Name $Script:TestIdentityPoolName `
                -Description "Test Identity Pool" `
                -EthernetSettings_IdentityCount 5 `
                -EthernetSettings_StartingMacAddress "AA:BB:CC:DD:F5:00" `
                -IscsiSettings_IdentityCount 5 `
                -IscsiSettings_StartingMacAddress "AA:BB:CC:DD:F6:00" `
                -IscsiSettings_InitiatorConfig_IqnPrefix "iqn.2009-05.com.test:test" `
                -IscsiSettings_InitiatorIpPoolSettings_IpRange "192.168.1.200-192.168.1.220" `
                -IscsiSettings_InitiatorIpPoolSettings_SubnetMask "255.255.255.0" `
                -IscsiSettings_InitiatorIpPoolSettings_Gateway "192.168.1.1" `
                -IscsiSettings_InitiatorIpPoolSettings_PrimaryDnsServer "192.168.1.10" `
                -IscsiSettings_InitiatorIpPoolSettings_SecondaryDnsServer "192.168.1.11" `
                -FcoeSettings_IdentityCount 5 `
                -FcoeSettings_StartingMacAddress "AA:BB:CC:DD:F7:00" `
                -FcSettings_Wwnn_IdentityCount 5 `
                -FcSettings_Wwnn_StartingAddress "AA:BB:CC:DD:F8:00" `

            $Script:TestIdentityPoolName | Get-OMEIdentityPool | Select-Object -ExpandProperty Name | Should -Be $Script:TestIdentityPoolName
            }
        It "Should return Identity Pool Usage" {
            # Not implemented yet. Need to deploy a template with identity pool assigned
            #$Script:TestIdentityPoolName | Get-OMEIdentityPool | Get-OMEIdentityPoolUsage | Measure-Object | Select-Object -ExpandProperty Count | Should -BeGreaterThan 0
        }
    }
}