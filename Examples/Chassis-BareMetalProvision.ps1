
#Requires -Modules DellOpenManage

# Import Module
Import-Module DellOpenManage

. ".\Examples\ExampleCredentials.ps1" 

# Connect to OME
$credentials = New-Object -TypeName System.Management.Automation.PSCredential -ArgumentList $OMEUsername, $(ConvertTo-SecureString -Force -AsPlainText $OMEPassword)
Connect-OMEServer -Name $OMEServer -Credentials $credentials -IgnoreCertificateWarning

$ChassisSettings = @{
    GroupName                        = "TestLabMX"
    GroupVIP                         = "192.168.1.111"
    GroupVIPSubnetMask               = "255.255.255.0"
    GroupVIPGateway                  = "192.168.1.1"
    Networks                         = @(
        { Name = "VLAN 1001", Id = 1001, Type = 1 },
        { Name = "VLAN 1002", Id = 1002, Type = 1 }
    )
    Chassis                          = @(
        { 
            Name = "TESTMX7000-1", ServiceTag = "C38V9T2", 
            SledSlots = @(
                @{Slot = 1; Name = "Slot-1"; IPv4Address = "192.168.1.200"; VlanId = 1 },
                @{Slot = 2; Name = "Slot-2"; IPv4Address = "192.168.1.201"; VlanId = 1 },
                @{Slot = 3; Name = "Slot-3"; IPv4Address = "192.168.1.202"; VlanId = 1 },
                @{Slot = 4; Name = "Slot-4"; IPv4Address = "192.168.1.203"; VlanId = 1 },
                @{Slot = 5; Name = "Slot-5"; IPv4Address = "192.168.1.204"; VlanId = 1 },
                @{Slot = 6; Name = "Slot-6"; IPv4Address = "192.168.1.205"; VlanId = 1 },
                @{Slot = 7; Name = "Slot-7"; IPv4Address = "192.168.1.206"; VlanId = 1 },
                @{Slot = 8; Name = "Slot-8"; IPv4Address = "192.168.1.207"; VlanId = 1 }
            ),
            IOMSlots = @(
                @{Slot = 1; Name = "IOM-A1"; IPv4Address = "192.168.1.10"; VlanId = 1 },
                @{Slot = 2; Name = "IOM-A2"; IPv4Address = "192.168.1.11"; VlanId = 1 }
            )  
        }
    )
    RootPassword                     = $(ConvertTo-SecureString 'calvin' -AsPlainText -Force)
    NetworkStorageFabricA            = { Name = "Storage Fabric A", Id = 30, Type = 8 }
    NetworkStorageFabricB            = { Name = "Storage Fabric B", Id = 40, Type = 8 }
    FabricName                       = "SmartFabric01"
    FabricDesignType                 = "2xMX9116n_Fabric_Switching_Engines_in_same_chassis"
    FabricSwitchAServiceTag          = "C38S9T2"
    FabricSwitchBServiceTag          = "CMWSV43"
    FabricUplinkEthernetBreakoutType = "4X10GE"
    FabricUplinkEthernetPortGroups   = "port-group1/1/13"
    FabricUplinkEthernetName         = "EthernetUplink01"
    FabricUplinkEthernetType         = "Ethernet - No Spanning Tree"
    FabricUplinkEthernetPorts        = "C38S9T2:ethernet1/1/41:1,CMWSV43:ethernet1/1/41:1"
    FabricUplinkStorageBreakoutType  = "4X8GFC"
    FabricUplinkStoragePortGroups    = "port-group1/1/15"
    FabricUplinkStorageType          = "FC Gateway"
    FabricUplinkStorageFabricAName   = "StorageFabricAUplink"
    FabricUplinkStorageFabricAPorts  = "C38S9T2:fibrechannel1/1/43:1"
    FabricUplinkStorageFabricBName   = "StorageFabricBUplink"
    FabricUplinkStorageFabricBPorts  = "CMWSV43:fibrechannel1/1/43:1"
    IdentityPoolName                 = "TestPool01"
    IdentityPoolCount                = 128
    IdentityPoolEthernetMAC          = "02:00:00:00:00:00"
    IdentityPoolFCoEMAC              = "04:00:00:00:00:00"
    TemplateName                     = "DefaultTemplate"
    Attributes                       = @(
        @{Name = "EmailAlertsConf.1#DestinationEmailAddress"; Value = "mail.example.net" },
        @{Name = "EmailAlertsConf.1#portNumber"; Value = 25 },
        @{Name = "EmailAlertsConf.1#useSSL"; Value = $false },
        @{Name = "ChassisLocation.1#DataCenterName"; Value = "DC 1" },
        @{Name = "ChassisLocation.1#RoomName"; Value = "" },
        @{Name = "ChassisLocation.1#AisleName"; Value = "" },
        @{Name = "TimeConfig.1#NTPEnable"; Value = $true },
        @{Name = "TimeConfig.1#TimeZone"; Value = "TZ_ID_9" },
        @{Name = "TimeConfig.1#NTPServer1"; Value = "0.centos.pool.ntp.org" },
        @{Name = "ChassisPower.1#RedundancyPolicy"; Value = "GRID_REDUNDANCY" },
        @{Name = "ChassisPower.1#EnableHotSpare"; Value = $true },
        @{Name = "ChassisPower.1#PrimaryGrid"; Value = "GRID_1" },
        @{Name = "SessionConfiguration.1#maxSessions"; Value = 100 },
        @{Name = "SSH.1#Enable"; Value = $true },
        @{Name = "Preference.1#DeviceName"; Value = "HOST_NAME" }
    )
}

# Use Quick Deploy to Assign IPs to Sleds
# Use Quick Deploy to Assign IPs to IOM
# Set Chassis Slot Names
# OME-M Chassis Setup
# Chassis DNS Name
# Configure Local Users 
# Configure Active Directory
# Import Active Directory Groups
# NTP & Timezone
# SMTP
# Create MCM Group for Multi-Chassis Pods
New-OMEMcmGroup -Name $ChassisSettings.GroupName -VIPIPv4Address $ChassisSettings.GroupVIP `
    -VIPSubnetMask $ChassisSettings.GroupVIPSubnetMask -VIPGateway $ChassisSettings.GroupVIPGateway -Wait -Verbose 
# Add ALL Member chassis to MCM Group
Invoke-OMEMcmGroupAddMember -Wait -Verbose
# Create VLANs
foreach ($Network in $ChassisSettings.Networks) {
    New-OMENetwork -Name $Network.Name -VlanMaximum $Network.Id -VlanMinimum $Network.Id -Type $Network.Type -Verbose
}
New-OMENetwork -Name $ChassisSettings.NetworkStorageFabricA.Name -VlanMaximum $ChassisSettings.NetworkStorageFabricA.Id -VlanMinimum $ChassisSettings.NetworkStorageFabricA.Id -Type $ChassisSettings.NetworkStorageFabricA.Type -Verbose
New-OMENetwork -Name $ChassisSettings.NetworkStorageFabricB.Name -VlanMaximum $ChassisSettings.NetworkStorageFabricB.Id -VlanMinimum $ChassisSettings.NetworkStorageFabricB.Id -Type $ChassisSettings.NetworkStorageFabricB.Type -Verbose

# Create Smart Fabric
New-OMEFabric -Name $ChassisSettings.FabricName -DesignType $ChassisSettings.FabricDesignType `
    -SwitchAServiceTag $ChassisSettings.FabricSwitchAServiceTag -SwitchBServiceTag $ChassisSettings.FabricSwitchBServiceTag -Verbose

$SwitchA = $($ChassisSettings.FabricSwitchAServiceTag | Get-OMEDevice)
$SwitchB = $($ChassisSettings.FabricSwitchBServiceTag | Get-OMEDevice)
# Configure IOM Port Breakout
Set-OMEIOMPortBreakout -Device $SwitchA -BreakoutType $ChassisSettings.FabricUplinkEthernetBreakoutType -PortGroups $ChassisSettings.FabricUplinkEthernetPortGroups -Wait -Verbose
Set-OMEIOMPortBreakout -Device $SwitchA -BreakoutType $ChassisSettings.FabricUplinkStorageBreakoutType -PortGroups $ChassisSettings.FabricUplinkStoragePortGroups -Wait -Verbose
Set-OMEIOMPortBreakout -Device $SwitchB -BreakoutType $ChassisSettings.FabricUplinkEthernetBreakoutType -PortGroups $ChassisSettings.FabricUplinkEthernetPortGroups -Wait -Verbose
Set-OMEIOMPortBreakout -Device $SwitchB -BreakoutType $ChassisSettings.FabricUplinkStorageBreakoutType -PortGroups $ChassisSettings.FabricUplinkStoragePortGroups -Wait -Verbose
Invoke-OMEInventoryRefresh -Devices @($SwitchA, $SwitchB) -Wait
# Create Ethernet and Storage Uplinks
$DefaultNetworks = $($ChassisSettings.Networks | Select-Object -Property Name | Get-OMENetwork)
$StorageFabricANetwork = $($ChassisSettings.NetworkStorageFabricA.Name | Get-OMENetwork)
$StorageFabricBNetwork = $($ChassisSettings.NetworkStorageFabricB.Name | Get-OMENetwork)
$Port1Networks = $($DefaultNetworks + $StorageFabricANetwork)
$Port2Networks = $($DefaultNetworks + $StorageFabricBNetwork)

$Fabric = $($ChassisSettings.FabricName | Get-OMEFabric)

New-OMEFabricUplink -Name $ChassisSettings.FabricUplinkEthernetName -Fabric $Fabric -UplinkType $ChassisSettings.FabricUplinkEthernetType `
    -TaggedNetworks $DefaultNetworks -Ports $ChassisSettings.FabricUplinkEthernetPorts -Verbose
New-OMEFabricUplink -Name $ChassisSettings.FabricUplinkStorageFabricAName -Fabric $Fabric -UplinkType $ChassisSettings.FabricUplinkStorageType `
    -TaggedNetworks $StorageFabricANetwork -Ports $ChassisSettings.FabricUplinkStorageFabricAPorts -Verbose
New-OMEFabricUplink -Name $ChassisSettings.FabricUplinkStorageFabricBName -Fabric $Fabric -UplinkType $ChassisSettings.FabricUplinkStorageType `
    -TaggedNetworks $StorageFabricBNetwork -Ports $ChassisSettings.FabricUplinkStorageFabricBPorts -Verbose

# Create Identity Pool
New-OMEIdentityPool `
    -Name $ChassisSettings.IdentityPoolName `
    -EthernetSettings_IdentityCount $ChassisSettings.IdentityPoolCount `
    -EthernetSettings_StartingMacAddress $ChassisSettings.IdentityPoolEthernetMAC `
    -FcoeSettings_IdentityCount $ChassisSettings.IdentityPoolCount `
    -FcoeSettings_StartingMacAddress $ChassisSettings.IdentityPoolFCoEMAC `
    -Verbose

# Loop through Chassis setting chassis name, slot names and quick deploy for sleds/IOM
foreach ($Chassis in $ChassisSettings.Chassis) {
    $ChassisDevice = $Chassis.ServiceTag | Get-OMEDevice
    # Set Chassis Name
    Set-OMEChassisName -Name $Chassis.Name -Chassis $ChassisDevice -Wait -Verbose
    
    # Quick Deploy Sleds
    Invoke-OMEQuickDeploy -RootPassword $ChassisSettings.RootPassword -SlotType "SLED" -Chassis $ChassisDevice `
        -IPv4Enabled -IPv4NetworkType "DHCP" `
        -Slots $Chassis.SledSlots -Wait -Verbose
    
    # Quick Deploy IOM
    Invoke-OMEQuickDeploy -RootPassword $ChassisSettings.RootPassword -SlotType "IOM" -Chassis $ChassisDevice `
        -IPv4Enabled -IPv4NetworkType "STATIC" -IPv4SubnetMask $ChassisSettings.GroupVIPSubnetMask -IPv4Gateway $ChassisSettings.GroupVIPGateway `
        -Slots $Chassis.IOMSlots -Verbose

    # Set Chassis Slot Names
    foreach ($SledSlot in $Chassis.SledSlots) {
        Set-OMEChassisSlotName -Chassis $ChassisDevice -Slot $SledSlot.Slot -Name $SledSlot.Name -Verbose
    }

    foreach ($IOMSlot in $Chassis.IOMSlots) {
        Set-OMEChassisSlotName -Chassis $ChassisDevice -Slot $IOMSlot.Slot -Name $IOMSlot.Name -SlotType "IOM" -Verbose
    }
}

# Set Application Settings
Set-OMEApplicationSettings -Settings $ChassisSettings.Attributes -Wait -Verbose

# Create Alert Policy (TODO)

# Import Default Template which includes NPAR partitions for FCoE. Configure this on a server via the Lifecycle Controller and export SCP to XML file.
New-OMETemplateFromFile -Name $ChassisSettings.TemplateName -Content $(Get-Content -Path .\Data.xml | Out-String)

# Assign VLANs to Template
$Template = $ChassisSettings.TemplateName | Get-OMETemplate 
$Template | Set-OMETemplateNetwork -NICIdentifier "NIC in Mezzanine 1A" -Port 1 -TaggedNetworks $Port1Networks -Mode "Replace" -Verbose
$Template | Set-OMETemplateNetwork -NICIdentifier "NIC in Mezzanine 1A" -Port 2 -TaggedNetworks $Port2Networks -Mode "Replace" -Verbose

# Assign Identity Pool  to Template
$IdentityPool = $ChassisSettings.IdentityPoolName | Get-OMEIdentityPool
$Template | Set-OMETemplateIdentityPool -IdentityPool $IdentityPool -Verbose

# Deploy Template to Sleds
$DefaultTemplate = $($ChassisSettings.TemplateName | Get-OMETemplate)
$AllComputeDevices = $(1000 | Get-OMEDevice -FilterBy "Type")
Invoke-OMETemplateDeploy -Template $DefaultTemplate -Devices $AllComputeDevices -Wait -Verbose
#Invoke-OMETemplateDeploy -Template $DefaultTemplate -Devices $AllComputeDevices -NetworkBootShareType "CIFS" -NetworkBootShareIpAddress "192.168.1.101" -NetworkBootIsoPath "/Share/ISO/CentOS7-Unattended.iso" -NetworkBootShareUser "Administrator" -NetworkBootSharePassword $(ConvertTo-SecureString 'calvin' -AsPlainText -Force) -NetworkBootShareName "Share" -Wait -Verbose

Disconnect-OMEServer