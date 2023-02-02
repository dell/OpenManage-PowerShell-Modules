$credentials = New-Object -TypeName System.Management.Automation.PSCredential -ArgumentList $Global:OMEUsername, $(ConvertTo-SecureString -Force -AsPlainText $Global:OMEPassword)
Connect-OMEServer -Name $Global:OMEServer -Credentials $credentials -IgnoreCertificateWarning
Describe "Directory Service Tests" {
    BeforeAll {
        $TestADDomain = "ose.local"
        $TestADGroup = "Administrators"
        $TestUserName = "${ADUsername}@${TestADDomain}"
        $TestPassword = $(ConvertTo-SecureString $ADPassword -AsPlainText -Force)
    }
    Context "ActiveDirectory" -Tag "ActiveDirectory"{
        It "Should create an AD Directory Service" {
            New-OMEDirectoryService -Name $TestADDomain.ToUpper() -DirectoryType "AD" -DirectoryServerLookup "DNS" -DirectoryServers @($TestADDomain) -ADGroupDomain $TestADDomain
            Get-OMEDirectoryService -DirectoryType "AD" -Name $TestADDomain | Select-Object -ExpandProperty Name | Should -Be $TestADDomain.ToUpper()
        }
        It "Should search an AD Directory Service" {
            $AD = $(Get-OMEDirectoryService -DirectoryType "AD" -Name $TestADDomain)
            Get-OMEDirectoryServiceSearch -Name $TestADGroup -DirectoryService $AD -DirectoryType "AD" -UserName $TestUserName -Password $TestPassword | Measure-Object | Select-Object -ExpandProperty Count | Should -Be 1
        }
        It "Should return an Application Role" {
            Get-OMERole -Name "^ADMINISTRATOR" | Measure-Object | Select-Object -ExpandProperty Count | Should -Be 1
        }
        It "Should import a Directory Group" {
            $AD = $(Get-OMEDirectoryService -DirectoryType "AD" -Name $TestADDomain)
            $ADGroups = $(Get-OMEDirectoryServiceSearch -Name $TestADGroup -DirectoryService $AD -DirectoryType "AD" -UserName $TestUserName  -Password $TestPassword)
            $Role = $(Get-OMERole -Name "^ADMINISTRATOR")
            Invoke-OMEDirectoryServiceImportGroup -DirectoryService $AD -DirectoryGroups $ADGroups -Role $Role | Measure-Object | Select-Object -ExpandProperty Count | Should -Be 1
        }
    }

    Context "Cleanup" -Tag "Cleanup" {
        It "Should remove Directory Service Group" {
            $TestADGroup | Get-OMEUser | Remove-OMEUser
            $TestADGroup | Get-OMEUser | Measure-Object | Select-Object -ExpandProperty Count | Should -Be 0
        }
        It "Should remove Directory Service" {
            $AD = $(Get-OMEDirectoryService -DirectoryType "AD" -Name $TestADDomain)
            $AD | Remove-OMEDirectoryService
            Get-OMEDirectoryService -DirectoryType "AD" -Name $TestADDomain | Measure-Object | Select-Object -ExpandProperty Count | Should -Be 0
        }
    }
}