$credentials = New-Object -TypeName System.Management.Automation.PSCredential -ArgumentList $Global:OMEUsername, $(ConvertTo-SecureString -Force -AsPlainText $Global:OMEPassword)
Connect-OMEServer -Name $Global:OMEServer -Credentials $credentials -IgnoreCertificateWarning
Describe "MX7000 Tests" {
    BeforeAll {
        $Script:TesMcmGroupName = "MX-FabricP1"
        $Script:TestBackupServiceTag = "7FKN9N2"
    }
    Context "MCM Group" {
        It "Should create MCM Group" {
            New-OMEMcmGroup -GroupName $Script:TesMcmGroupName -Wait | Should -Match "Completed.*"
        }

        It "Should add a members to group" {
            Invoke-OMEMcmGroupAddMember -Wait | Should -Match "Completed.*"
        }

        It "Should assign backup lead" {
            Invoke-OMEMcmGroupAssignBackupLead -ServiceTag $Script:TestBackupServiceTag -Wait -Verbose | Should -Match "Completed.*"
        }
    }
}