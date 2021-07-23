$credentials = New-Object -TypeName System.Management.Automation.PSCredential -ArgumentList $Global:OMEUsername, $(ConvertTo-SecureString -Force -AsPlainText $Global:OMEPassword)
Connect-OMEServer -Name $Global:OMEServer -Credentials $credentials -IgnoreCertificateWarning
Describe "Misc Tests" {
    BeforeEach {
    }
    Context "Alert Checks" {
        It "Should return ALL Alerts" {
            Get-OMEAlerts | Measure-Object | Select-Object -ExpandProperty Count | Should -BeGreaterThan 1
        }

        It "Should return Alerts by Severity" {
            Get-OMEAlerts -SeverityType "CRITICAL" -Top 50 | Measure-Object | Select-Object -ExpandProperty Count | Should -BeGreaterThan 1
        }
    }
    Context "Audit Checks" {
        It "Should return ALL Audit Logs" {
            Get-OMEAuditLogs | Measure-Object | Select-Object -ExpandProperty Count | Should -BeGreaterThan 1
        }
    }
    Context "Warranty Checks" {
        It "Should return ALL Warranties" {
            Get-OMEWarranty | Measure-Object | Select-Object -ExpandProperty Count | Should -BeGreaterThan 1
        }
    }
    Context "Report Checks" {
        It "Should return ALL Reports" {
            Get-OMEReport | Measure-Object | Select-Object -ExpandProperty Count | Should -BeGreaterThan 1
        }
    }
    Context "Network Checks" {
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
    Context "Identity Pool Checks" {
        It "Should create an Identity Pool" {
            
            11 | Get-OMEIdentityPool -FilterBy "Id" | Get-OMEIdentityPoolUsage -Verbose # | Export-Csv -Path "C:\Users\Trevor_Squillario\Downloads\Get-OMEIdentityPoolUsage.csv" -NoTypeInformation
        }
        It "Should return Identity Pool Usage" {
            Get-OMEIdentityPoolUsage | Measure-Object | Select-Object -ExpandProperty Count | Should -BeGreaterThan 0
        }
    }
}