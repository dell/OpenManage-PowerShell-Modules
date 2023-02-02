$credentials = New-Object -TypeName System.Management.Automation.PSCredential -ArgumentList $Global:OMEUsername, $(ConvertTo-SecureString -Force -AsPlainText $Global:OMEPassword)
Connect-OMEServer -Name $Global:OMEServer -Credentials $credentials -IgnoreCertificateWarning
Describe "MX7000 Tests" {
    BeforeAll {
        $Script:TesMcmGroupName = "MXTest01"
        $Script:TestBackupServiceTag = "7FKN9N2"
        $Script:TestSwitchAServiceTag = "C38S9T2"
        $Script:TestSwitchBServiceTag = "CMWSV43"
        $Script:TestFabricName = "SmartFabric01"
        $Script:TestFabricUplinkName = "EthernetUplink01"
        $Script:TestFabricUplinkNameEdit = "EthernetUplink01Edit"
        $Script:TestNetwork1 = @{
            "Name"        = "TestNetwork01"
            "Description" = "Test Network"
            "VlanMaximum" = 4001
            "VlanMinimum" = 4001
            "Type"        = 1
        }
        $Script:TestNetwork2 = @{
            "Name"        = "TestNetwork02"
            "Description" = "Test Network 2"
            "VlanMaximum" = 4002
            "VlanMinimum" = 4002
            "Type"        = 1
        }
    }
    <#
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
    #>
    Context "Network" -Tag "Network" {
        It "Should create Networks" {
            New-OMENetwork -Name $Script:TestNetwork1.Name -Description $Script:TestNetwork1.Description -VlanMaximum $Script:TestNetwork1.VlanMaximum -VlanMinimum $Script:TestNetwork1.VlanMinimum -Type $Script:TestNetwork1.Type
            $Script:TestNetwork1.Name | Get-OMENetwork | Select-Object -ExpandProperty Name | Should -Be $Script:TestNetwork1.Name
            New-OMENetwork -Name $Script:TestNetwork2.Name -Description $Script:TestNetwork2.Description -VlanMaximum $Script:TestNetwork2.VlanMaximum -VlanMinimum $Script:TestNetwork2.VlanMinimum -Type $Script:TestNetwork2.Type
            $Script:TestNetwork2.Name | Get-OMENetwork | Select-Object -ExpandProperty Name | Should -Be $Script:TestNetwork2.Name
        }
    }
    Context "Fabric" -Tag "Fabric" {
        It "Should return a Fabric" {
            $Script:TestFabricName | Get-OMEFabric | Measure-Object | Select-Object -ExpandProperty Count | Should -BeGreaterThan 0
        }
    }
    Context "PortBreakout" -Tag "PortBreakout" {
        It "Should set Port Breakout" {
            $SwitchA = $($Script:TestSwitchAServiceTag | Get-OMEDevice)
            $SwitchB = $($Script:TestSwitchBServiceTag | Get-OMEDevice)
            Set-OMEIOMPortBreakout -Device $SwitchA -BreakoutType "4X10GE" -PortGroups "port-group1/1/13" -Wait | Should -Be "Completed"
            Set-OMEIOMPortBreakout -Device $SwitchB -BreakoutType "4X10GE" -PortGroups "port-group1/1/13" -Wait | Should -Be "Completed"
        }
    }
    Context "Uplink" -Tag "Uplink" {
        It "Should create an Uplink" {
            $TestNetwork1 = $Script:TestNetwork1.Name | Get-OMENetwork
            $TestFabric = $($Script:TestFabricName | Get-OMEFabric)
            New-OMEFabricUplink -Name $Script:TestFabricUplinkName -Fabric $TestFabric -UplinkType "Ethernet - No Spanning Tree" `
                -TaggedNetworks $TestNetwork1 -Ports "C38S9T2:ethernet1/1/41:1,CMWSV43:ethernet1/1/41:1" 
            $Script:TestFabricUplinkName | Get-OMEFabricUplink -Fabric $TestFabric | Select-Object -ExpandProperty Name | Should -Be $Script:TestFabricUplinkName
            $Script:TestFabricUplinkName | Get-OMEFabricUplink -Fabric $TestFabric | Select-Object -ExpandProperty Ports | Measure-Object | Select-Object -ExpandProperty Count | Should -Be 2
            $Script:TestFabricUplinkName | Get-OMEFabricUplink -Fabric $TestFabric | Select-Object -ExpandProperty Networks | Measure-Object | Select-Object -ExpandProperty Count | Should -Be 1
        }
        It "Should edit an Uplink and add a Network" -Tag "EditUplink" {
            $TestFabric = $($Script:TestFabricName | Get-OMEFabric)
            $TestUplink = $($Script:TestFabricUplinkName | Get-OMEFabricUplink -Fabric $TestFabric)
            $TestNetwork2 = $($Script:TestNetwork2.Name | Get-OMENetwork)
            Edit-OMEFabricUplink -Fabric $TestFabric -Uplink $TestUplink -Mode "Append" -TaggedNetworks $TestNetwork2 
            $Script:TestFabricUplinkName | Get-OMEFabricUplink -Fabric $TestFabric | Select-Object -ExpandProperty Ports | Measure-Object | Select-Object -ExpandProperty Count | Should -Be 2
            $Script:TestFabricUplinkName | Get-OMEFabricUplink -Fabric $TestFabric | Select-Object -ExpandProperty Networks | Measure-Object | Select-Object -ExpandProperty Count | Should -Be 2
        }
        It "Should edit an Uplink and remove a Network" -Tag "EditUplink" {
            $TestFabric = $($Script:TestFabricName | Get-OMEFabric)
            $TestUplink = $($Script:TestFabricUplinkName | Get-OMEFabricUplink -Fabric $TestFabric)
            $TestNetwork2 = $($Script:TestNetwork2.Name | Get-OMENetwork)
            Edit-OMEFabricUplink -Fabric $TestFabric -Uplink $TestUplink -Mode "Remove" -TaggedNetworks $TestNetwork2 
            $Script:TestFabricUplinkName | Get-OMEFabricUplink -Fabric $TestFabric | Select-Object -ExpandProperty Ports | Measure-Object | Select-Object -ExpandProperty Count | Should -Be 2
            $Script:TestFabricUplinkName | Get-OMEFabricUplink -Fabric $TestFabric | Select-Object -ExpandProperty Networks | Measure-Object | Select-Object -ExpandProperty Count | Should -Be 1
        }
        It "Should edit an Uplink and add Ports" -Tag "EditUplink" {
            $TestFabric = $($Script:TestFabricName | Get-OMEFabric)
            $TestUplink = $($Script:TestFabricUplinkName | Get-OMEFabricUplink -Fabric $TestFabric)
            $TestNetwork2 = $($Script:TestNetwork2.Name | Get-OMENetwork)
            Edit-OMEFabricUplink -Fabric $TestFabric -Uplink $TestUplink -Mode "Append" -Ports "C38S9T2:ethernet1/1/41:2,CMWSV43:ethernet1/1/41:2,C38S9T2:ethernet1/1/41:3,CMWSV43:ethernet1/1/41:3"
            $Script:TestFabricUplinkName | Get-OMEFabricUplink -Fabric $TestFabric | Select-Object -ExpandProperty Ports | Measure-Object | Select-Object -ExpandProperty Count | Should -Be 6
            $Script:TestFabricUplinkName | Get-OMEFabricUplink -Fabric $TestFabric | Select-Object -ExpandProperty Networks | Measure-Object | Select-Object -ExpandProperty Count | Should -Be 1
        }
        It "Should edit an Uplink and remove Ports" -Tag "EditUplink" {
            $TestFabric = $($Script:TestFabricName | Get-OMEFabric)
            $TestUplink = $($Script:TestFabricUplinkName | Get-OMEFabricUplink -Fabric $TestFabric)
            $TestNetwork2 = $($Script:TestNetwork2.Name | Get-OMENetwork)
            Edit-OMEFabricUplink -Fabric $TestFabric -Uplink $TestUplink -Mode "Remove" -Ports "C38S9T2:ethernet1/1/41:2,CMWSV43:ethernet1/1/41:2"
            $Script:TestFabricUplinkName | Get-OMEFabricUplink -Fabric $TestFabric | Select-Object -ExpandProperty Ports | Measure-Object | Select-Object -ExpandProperty Count | Should -Be 4
            $Script:TestFabricUplinkName | Get-OMEFabricUplink -Fabric $TestFabric | Select-Object -ExpandProperty Networks | Measure-Object | Select-Object -ExpandProperty Count | Should -Be 1
        }
        It "Should edit an Uplink and replace Ports" -Tag "EditUplink" {
            $TestFabric = $($Script:TestFabricName | Get-OMEFabric)
            $TestUplink = $($Script:TestFabricUplinkName | Get-OMEFabricUplink -Fabric $TestFabric)
            $TestNetwork2 = $($Script:TestNetwork2.Name | Get-OMENetwork)
            Edit-OMEFabricUplink -Fabric $TestFabric -Uplink $TestUplink -Mode "Replace" -Ports "C38S9T2:ethernet1/1/41:1,CMWSV43:ethernet1/1/41:1"
            $Script:TestFabricUplinkName | Get-OMEFabricUplink -Fabric $TestFabric | Select-Object -ExpandProperty Ports | Measure-Object | Select-Object -ExpandProperty Count | Should -Be 2
            $Script:TestFabricUplinkName | Get-OMEFabricUplink -Fabric $TestFabric | Select-Object -ExpandProperty Networks | Measure-Object | Select-Object -ExpandProperty Count | Should -Be 1
        }
        It "Should edit an Uplink and set NativeVLAN" -Tag "EditUplink" {
            $TestFabric = $($Script:TestFabricName | Get-OMEFabric)
            $TestUplink = $($Script:TestFabricUplinkName | Get-OMEFabricUplink -Fabric $TestFabric)
            $TestNetwork2 = $($Script:TestNetwork2.Name | Get-OMENetwork)
            Edit-OMEFabricUplink -Fabric $TestFabric -Uplink $TestUplink -UnTaggedNetwork $TestNetwork2 
            $Script:TestFabricUplinkName | Get-OMEFabricUplink -Fabric $TestFabric | Select-Object -ExpandProperty NativeVLAN | Should -Be $Script:TestNetwork2.VlanMaximum
            $Script:TestFabricUplinkName | Get-OMEFabricUplink -Fabric $TestFabric | Select-Object -ExpandProperty Ports | Measure-Object | Select-Object -ExpandProperty Count | Should -Be 2
            $Script:TestFabricUplinkName | Get-OMEFabricUplink -Fabric $TestFabric | Select-Object -ExpandProperty Networks | Measure-Object | Select-Object -ExpandProperty Count | Should -Be 1
        }
        It "Should edit an Uplink and change name" -Tag "EditUplink" {
            $TestFabric = $($Script:TestFabricName | Get-OMEFabric)
            $TestUplink = $($Script:TestFabricUplinkName | Get-OMEFabricUplink -Fabric $TestFabric)
            Edit-OMEFabricUplink -Fabric $TestFabric -Uplink $TestUplink -Name $Script:TestFabricUplinkNameEdit
            $Script:TestFabricUplinkNameEdit | Get-OMEFabricUplink -Fabric $TestFabric | Select-Object -ExpandProperty Name | Should -Be $Script:TestFabricUplinkNameEdit
            $Script:TestFabricUplinkName | Get-OMEFabricUplink -Fabric $TestFabric | Select-Object -ExpandProperty Ports | Measure-Object | Select-Object -ExpandProperty Count | Should -Be 2
            $Script:TestFabricUplinkName | Get-OMEFabricUplink -Fabric $TestFabric | Select-Object -ExpandProperty Networks | Measure-Object | Select-Object -ExpandProperty Count | Should -Be 1
        }
    }

    Context "Cleanup" -Tag "Cleanup" {
        It "Should remove Uplink" {
            $TestFabric = $($Script:TestFabricName | Get-OMEFabric)
            $TestUplink = $($Script:TestFabricUplinkName | Get-OMEFabricUplink -Fabric $TestFabric)
            Remove-OMEFabricUplink -Fabric $TestFabric -Uplink $TestUplink
            $Script:TestFabricUplinkName | Get-OMEFabricUplink -Fabric $TestFabric | Measure-Object | Select-Object -ExpandProperty Count | Should -Be 0
        }
        It "Should remove Networks" {
            $TestNetwork1 = $($Script:TestNetwork1.Name | Get-OMENetwork)
            $TestNetwork2 = $($Script:TestNetwork2.Name | Get-OMENetwork)
            $TestNetwork1, $TestNetwork2 | Remove-OMENetwork
            $Script:TestNetwork1.Name | Get-OMENetwork | Measure-Object | Select-Object -ExpandProperty Count | Should -Be 0
            $Script:TestNetwork2.Name | Get-OMENetwork | Measure-Object | Select-Object -ExpandProperty Count | Should -Be 0
        }
    }

}