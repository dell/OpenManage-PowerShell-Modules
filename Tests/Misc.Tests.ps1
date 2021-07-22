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
}