$GroupName = "Services Group Test 1"
$Hosts = @("859N3ZZ", "759N3ZZ")
$GroupJsonString = @'
{
    "Id": 0,
    "MyAccountId": null,
    "Description": "Support Assist Test Group 1",
    "Name": "Support Assist Test Group 1",
    "DispatchOptIn": true,
    "ContactOptIn": true,
    "CustomerDetails": {
      "ShippingDetails": {
        "AddressLine1": "109 Gelante Way",
        "TechnicianRequired": true,
        "PrimaryContact": {
          "LastName": "Curell",
          "Phone": "1111111111",
          "AlternatePhone": "",
          "FirstName": "Grant",
          "Email": "grant_curell@meiguo.com"
        },
        "AddressLine4": "",
        "City": "Dayton",
        "Country": "US",
        "DispatchNotes": "No",
        "State": "Ohio",
        "SecondaryContact": {
          "LastName": "Curell",
          "Phone": "9999999999",
          "AlternatePhone": "",
          "FirstName": "Angela",
          "Email": "grantcurell@wojia.com"
        },
        "Cnpj": null,
        "AddressLine3": "78210",
        "PreferredContactTimeFrame": "10:00 AM-4:00 PM",
        "Zip": "45459",
        "Ie": null,
        "PreferredContactTimeZone": "TZ_ID_65",
        "AddressLine2": "San Antonio TX"
      },
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
Write-Host $($GroupJson | ConvertTo-Json  -Depth 10)

# Create Services group from json string
New-OMESupportAssistGroup -AddGroup $($GroupJson | ConvertTo-Json  -Depth 10) -Verbose

# Get newly created group
$GroupName | Get-OMEGroup | Format-List

# Get devices to add
$devices = $($Hosts | Get-OMEDevice -FilterBy "ServiceTag")

# Edit group and add devices
$GroupName | Get-OMEGroup | Edit-OMESupportAssistGroup -Devices $devices -Verbose