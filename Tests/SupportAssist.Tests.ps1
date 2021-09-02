$credentials = New-Object -TypeName System.Management.Automation.PSCredential -ArgumentList $Global:OMEUsername, $(ConvertTo-SecureString -Force -AsPlainText $Global:OMEPassword)
Connect-OMEServer -Name $Global:OMEServer -Credentials $credentials -IgnoreCertificateWarning
Describe "Support Assist Tests" {
    BeforeAll {
        $Script:TestSupportAssistGroup = "Support Assist Group 1"
        $Script:TestSupportAssistGroupEdit = "Support Assist Group 2"
        $Script:DeviceServiceTag = "GV6V673"
    }
    Context "Support Assist" {
        It "Should create new support assist group" {
            New-OMESupportAssistGroup -AddGroup ".\Tests\Data\SupportAssistGroup.json"
            $Script:TestSupportAssistGroup | Get-OMEGroup | Get-OMESupportAssistGroup | Select-Object -ExpandProperty Name | Should -Be $Script:TestSupportAssistGroup
        }

        It "Should add devices to support assist group" {
            $devices = $($Script:DeviceServiceTag | Get-OMEDevice -FilterBy "ServiceTag")
            $Script:TestSupportAssistGroup | Get-OMEGroup | Edit-OMESupportAssistGroup -Devices $devices
            Get-OMEDevice -Group $("Support Assist Group 1" | Get-OMEGroup) | Measure-Object | Select-Object -ExpandProperty Count | Should -BeGreaterThan 0
        }

        It "Should edit support assist group" {
            $TestEditGroup = '{
                "MyAccountId":  0,
                "Description":  "Support Assist Group 2",
                "Name":  "Support Assist Group 2",
                "DispatchOptIn":  false,
                "CustomerDetails":  null,
                "ContactOptIn":  false
            }' | ConvertFrom-Json
            $TestEditGroup.Name = $Script:TestSupportAssistGroupEdit
            $TestEditGroup.Description = $Script:TestSupportAssistGroupEdit
            $TestEditGroup = $TestEditGroup | ConvertTo-Json -Depth 6
            $Script:TestSupportAssistGroup | Get-OMEGroup | Edit-OMESupportAssistGroup -EditGroup $TestEditGroup
            $Script:TestSupportAssistGroupEdit | Get-OMEGroup | Get-OMESupportAssistGroup | Select-Object -ExpandProperty Name | Should -Be $Script:TestSupportAssistGroupEdit
        }

        It "Should remove support assist group" {
            $Script:TestSupportAssistGroupEdit | Get-OMEGroup | Remove-OMESupportAssistGroup
            $Script:TestSupportAssistGroupEdit | Get-OMEGroup | Get-OMESupportAssistGroup | Measure-Object | Select-Object -ExpandProperty Count | Should -Be 0
        }

        #It "Should return support assist cases by device" {
        #    $Script:DeviceServiceTag | Get-OMESupportAssistCases -Verbose
        #}
    }
}