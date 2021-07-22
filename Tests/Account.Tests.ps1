$credentials = New-Object -TypeName System.Management.Automation.PSCredential -ArgumentList $Global:OMEUsername, $(ConvertTo-SecureString -Force -AsPlainText $Global:OMEPassword)
Connect-OMEServer -Name $Global:OMEServer -Credentials $credentials -IgnoreCertificateWarning
Describe "Account Tests" {
    BeforeEach {
        $TestAccount = "admin"
        $Script:TestNewAccount = "testaccount_$((Get-Date).ToString('yyyyMMddHHmmss'))"
    }
    Context "Accont Checks" {
        It "Should return ALL Accounts" {
            Get-OMEUser | Measure-Object | Select-Object -ExpandProperty Count | Should -BeGreaterThan 1
        }

        It "Should return a specific Account" {
            $TestAccount | Get-OMEUser | Select-Object -ExpandProperty UserName | Should -Be $TestAccount
        }

        It "Should create new Account" {
            $Password = $(ConvertTo-SecureString 'P@ssword1!' -AsPlainText -Force)
            New-OMEUser -Name $Script:TestNewAccount -Description "Test user 1" -Password $Password -Role "ADMINISTRATOR"
            $Script:TestNewAccount | Get-OMEUser | Select-Object -ExpandProperty UserName | Should -Be $Script:TestNewAccount
        }


    }
}