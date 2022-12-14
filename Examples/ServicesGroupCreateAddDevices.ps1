$GroupName = "Services Group Test 1"
$Hosts = @("859N3ZZ", "759N3ZZ")
$GroupJsonString = @'
{
    "Id": 0,
    "MyAccountId": 0,
    "Description": "",
    "Name": "",
    "ContactOptIn": true,
    "DispatchOptIn": false,
    "CustomerDetails": {
      "PrimaryContact": {
        "LastName": "Curell",
        "TimeZone": "TZ_ID_10",
        "AlternatePhone": "",
        "ContactMethod": "phone",
        "TimeFrame": "10:00 AM-4:00 PM",
        "FirstName": "Grant",
        "Phone": "8888888888",
        "Email": "daiershizuihaode@dell.com"
      },
      "SecondaryContact": {
        "LastName": "Curell",
        "TimeZone": "TZ_ID_71",
        "AlternatePhone": "",
        "ContactMethod": "phone",
        "TimeFrame": "10:00 AM-4:00 PM",
        "FirstName": "Angela",
        "Phone": "9999999999",
        "Email": "grantcurell@zheshiwotaitai.com"
      }
    }
  }
'@

# Convert json string to PowerShell object
$GroupJson = $GroupJsonString | ConvertFrom-Json

# Edit properties
$GroupJson.Name = $GroupName

# Print output to screen
Write-Host $($GroupJson | ConvertTo-Json)

# Create Services group from json string
New-OMESupportAssistGroup -AddGroup $($GroupJson | ConvertTo-Json) -Verbose

# Get newly created group
$GroupName | Get-OMEGroup | Format-List

# Get devices to add
$devices = $($Hosts | Get-OMEDevice -FilterBy "ServiceTag")

# Edit group and add devices
$GroupName | Get-OMEGroup | Edit-OMESupportAssistGroup -Devices $devices -Verbose