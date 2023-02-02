
#Requires -Modules DellOpenManage

# Import Module
Import-Module DellOpenManage

. ".\Examples\ExampleCredentials.ps1" 

# Connect to OME
$credentials = New-Object -TypeName System.Management.Automation.PSCredential -ArgumentList $OMEUsername, $(ConvertTo-SecureString -Force -AsPlainText $OMEPassword)
Connect-OMEServer -Name $OMEServer -Credentials $credentials -IgnoreCertificateWarning

$ChassisSettings = @{
    GroupName = "TestLabMX"
    GroupVIP = "192.168.1.111"
    GroupVIPSubnetMask = "255.255.255.0"
    GroupVIPGateway = "192.168.1.1"
    Networks = @(
        { Name = "VLAN 1001", Id = 1001, Type = 1},
        { Name = "VLAN 1002", Id = 1002, Type = 1}
    )
    NetworkStorageFabricA = { Name = "Storage Fabric A", Id = 30, Type = 8}
    NetworkStorageFabricB = { Name = "Storage Fabric B", Id = 40, Type = 8}
    FabricName = "SmartFabric01"
    FabricDesignType = "2xMX9116n_Fabric_Switching_Engines_in_same_chassis"
    FabricSwitchAServiceTag = "C38S9T2"
    FabricSwitchBServiceTag = "CMWSV43"
    FabricUplinkEthernetBreakoutType = "4X10GE"
    FabricUplinkEthernetPortGroups = "port-group1/1/13"
    FabricUplinkEthernetName = "EthernetUplink01"
    FabricUplinkEthernetType = "Ethernet - No Spanning Tree"
    FabricUplinkEthernetPorts = "C38S9T2:ethernet1/1/41:1,CMWSV43:ethernet1/1/41:1"
    FabricUplinkStorageBreakoutType = "4X8GFC"
    FabricUplinkStoragePortGroups = "port-group1/1/15"
    FabricUplinkStorageType = "FC Gateway"
    FabricUplinkStorageFabricAName = "StorageFabricAUplink"
    FabricUplinkStorageFabricAPorts = "C38S9T2:fibrechannel1/1/43:1"
    FabricUplinkStorageFabricBName = "StorageFabricBUplink"
    FabricUplinkStorageFabricBPorts = "CMWSV43:fibrechannel1/1/43:1"
    IdentityPoolCount = 128
    IdentityPoolEthernetMAC = "02:00:00:00:00:00"
    IdentityPoolFCoEMAC = "04:00:00:00:00:00"
    TemplateName = "DefaultTemplate"
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
    -Name "TestPool01" `
    -EthernetSettings_IdentityCount $ChassisSettings.IdentityPoolCount `
    -EthernetSettings_StartingMacAddress $ChassisSettings.IdentityPoolEthernetMAC `
    -FcoeSettings_IdentityCount $ChassisSettings.IdentityPoolCount `
    -FcoeSettings_StartingMacAddress $ChassisSettings.IdentityPoolFCoEMAC `
    -Verbose
# Create Alert Policy
# Import Default Template
    # Configure NPAR partitions for FCoE
    # Assign Identity Pool & VLANs
        # Include FCoE VLANs
New-OMETemplateFromFile -Name $ChassisSettings.TemplateName -Content $(Get-Content -Path .\Data.xml | Out-String)
# Deploy Template to Sleds
$DefaultTemplate = $($ChassisSettings.TemplateName | Get-OMETemplate)
$AllComputeDevices = $(1000 | Get-OMEDevice -FilterBy "Type")
Invoke-OMETemplateDeploy -Template $DefaultTemplate -Devices $AllComputeDevices -Wait -Verbose
#Invoke-OMETemplateDeploy -Template $DefaultTemplate -Devices $AllComputeDevices -NetworkBootShareType "CIFS" -NetworkBootShareIpAddress "192.168.1.101" -NetworkBootIsoPath "/Share/ISO/CentOS7-Unattended.iso" -NetworkBootShareUser "Administrator" -NetworkBootSharePassword $(ConvertTo-SecureString 'calvin' -AsPlainText -Force) -NetworkBootShareName "Share" -Wait -Verbose

Disconnect-OMEServer