$credentials = New-Object -TypeName System.Management.Automation.PSCredential -ArgumentList $Global:OMEUsername, $(ConvertTo-SecureString -Force -AsPlainText $Global:OMEPassword)
Connect-OMEServer -Name $Global:OMEServer -Credentials $credentials -IgnoreCertificateWarning
Describe "Support Assist Tests" {
    BeforeAll {
        $Script:TestSupportAssistGroupName = "TestSAGroup_$((Get-Date).ToString('yyyyMMddHHmmss'))"
        $Script:TestSupportAssistGroupEdit = "TestSAGroup2_$((Get-Date).ToString('yyyyMMddHHmmss'))"
        $Script:DeviceServiceTag = "GV6V673"
        $Script:TestSupportAssistGroup = '{
            "MyAccountId": "",
            "Name": "Support Assist Group 1",
            "Description": "Support Assist Group",
            "DispatchOptIn": false,
            "CustomerDetails": null,
            "ContactOptIn":  false
        }' | ConvertFrom-Json
        $Script:TestSupportAssistGroup.Name = $Script:TestSupportAssistGroupName
    }
    Context "Support Assist" {
        It "Should create new support assist group" {
            $TestGroup = $Script:TestSupportAssistGroup | ConvertTo-Json -Depth 6
            New-OMESupportAssistGroup -AddGroup $TestGroup
            $Script:TestSupportAssistGroupName | Get-OMEGroup | Get-OMESupportAssistGroup | Select-Object -ExpandProperty Name | Should -Be $Script:TestSupportAssistGroupName
        }

        It "Should add devices to support assist group" {
            $devices = $($Script:DeviceServiceTag | Get-OMEDevice -FilterBy "ServiceTag")
            $Script:TestSupportAssistGroupName | Get-OMEGroup | Edit-OMESupportAssistGroup -Devices $devices
            Get-OMEDevice -Group $("Support Assist Group 1" | Get-OMEGroup) | Measure-Object | Select-Object -ExpandProperty Count | Should -BeGreaterThan 0
        }

        It "Should edit support assist group" {
            $TestEditGroup = $Script:TestSupportAssistGroup
            $TestEditGroup.Name = $Script:TestSupportAssistGroupEdit
            $TestEditGroup = $TestEditGroup | ConvertTo-Json -Depth 6
            $Script:TestSupportAssistGroupName | Get-OMEGroup | Edit-OMESupportAssistGroup -EditGroup $TestEditGroup
            $Script:TestSupportAssistGroupEdit | Get-OMEGroup | Get-OMESupportAssistGroup | Select-Object -ExpandProperty Name | Should -Be $Script:TestSupportAssistGroupEdit
        }

        It "Should return support assist cases by device" {
            $Script:DeviceServiceTag | Get-OMESupportAssistCases | Measure-Object | Select-Object -ExpandProperty Count | Should -Be 0
        }

        It "Should remove support assist group" {
            $Script:TestSupportAssistGroupEdit | Get-OMEGroup | Remove-OMESupportAssistGroup
            $Script:TestSupportAssistGroupEdit | Get-OMEGroup | Get-OMESupportAssistGroup | Measure-Object | Select-Object -ExpandProperty Count | Should -Be 0
        }
    }
}