<#
.SYNOPSIS
Generate JSON object to be used when submitting Jobs to the DiscoveryConfigService

.DESCRIPTION

.PARAMETER $Protocol
String containing protocol

.OUTPUTS
PCCustomObject
#>
function Get-DiscoveryProtocolPayload($Protocol) {
    
    $WSManProtocolPayload = '{
        "type":"WSMAN",
        "authType":"Basic",
        "modified":false,
        "credentials": {
            "username":"",
            "password":"",
            "caCheck":false,
            "cnCheck":false,
            "port":443,
            "retries":3,
            "timeout": 60
        }
    }' | ConvertFrom-Json

    $RedfishProtocolPayload = '{
        "type":"REDFISH",
        "authType":"Basic",
        "modified":false,
        "credentials": {
            "username":"",
            "password":"",
            "caCheck":false,
            "cnCheck":false,
            "port":443,
            "retries":3,
            "timeout": 60
        }
    }' | ConvertFrom-Json

    $VMwareProtocolPayload = '{
        "type":"VMWARE",
        "authType":"Basic",
        "modified":false,
        "credentials":{
            "username":"",
            "password":"",
            "caCheck":false,
            "cnCheck":false,
            "port":443,
            "retries":3,
            "timeout":60,
            "isHttp":false,
            "keepAlive":false}
    }' | ConvertFrom-Json

    $SNMPProtocolPayload = '{
        "type":"SNMP",
        "authType":"Basic",
        "modified":false,
        "credentials":{
            "community":"public",
            "enableV1V2":true,
            "port":161,
            "retries":3,
            "timeout":3}
    }' | ConvertFrom-Json

    $IPMIProtocolPayload = '{
        "type":"IPMI",
        "authType":"Basic",
        "modified":false,
        "credentials":{
            "username":"",
            "password":"",
            "privilege":2,
            "retries":3,
            "timeout":59}
    }' | ConvertFrom-Json

    $SSHProtocolPayload = '{
        "type":"SSH",
        "authType":"Basic",
        "modified":false,
        "credentials":{
            "username":"",
            "isSudoUser":false,
            "password":"",
            "port":22,
            "useKey":false,
            "retries":1,
            "timeout":59,
            "checkKnownHosts":false}
    }' | ConvertFrom-Json

    $Payload = $null
    if ($Protocol -eq "WSMAN") {
        $Payload = $WSManProtocolPayload
    } elseif ($Protocol -eq "REDFISH") {
        $Payload = $RedfishProtocolPayload
    } elseif ($Protocol -eq "VMWARE") {
        $Payload = $VMwareProtocolPayload
    } elseif ($Protocol -eq "SNMP") {
        $Payload = $SNMPProtocolPayload
    } elseif ($Protocol -eq "IPMI") {
        $Payload = $IPMIProtocolPayload
    } elseif ($Protocol -eq "SSH") {
        $Payload = $SSHProtocolPayload
    }
    return $Payload
}