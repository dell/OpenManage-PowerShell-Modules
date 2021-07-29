function Get-SupportAssistGroupPayload {
    $Payload = '{
        "Id": 0,
        "MyAccountId": 0,
        "Description": "Support Assist Group 1",
        "Name": "Support Assist Group 1",
        "DispatchOptIn": true,
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
        },
        "ContactOptIn": true
      }' | ConvertFrom-Json
      return $Payload
}