$credentials = New-Object -TypeName System.Management.Automation.PSCredential -ArgumentList $Global:OMEUsername, $(ConvertTo-SecureString -Force -AsPlainText $Global:OMEPassword)
Connect-OMEServer -Name $Global:OMEServer -Credentials $credentials -IgnoreCertificateWarning
Describe "User Tests" {
    BeforeAll {
        $Script:TestUserName = "test01"
    }
    Context "User" {
        It "Should create new user" {
            $password = $(ConvertTo-SecureString -Force -AsPlainText "P@ssword1!")
            New-OMEUser -Name $Script:TestUserName -Description "Test user 1" -Password $password -Role "ADMINISTRATOR"
            $Script:TestUserName | Get-OMEUser | Select-Object -ExpandProperty Name | Should -Be $Script:TestUserName
        }

        It "Should return all users" {
            Get-OMEUser | Measure-Object | Select-Object -ExpandProperty Count | Should -BeGreaterThan 1
        }
    }
}