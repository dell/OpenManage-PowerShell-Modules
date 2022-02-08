
#Requires -Modules DellOpenManage

Import-Module DellOpenManage

. ".\Examples\ExampleCredentials.ps1" 

# Connect to OME
$credentials = New-Object -TypeName System.Management.Automation.PSCredential -ArgumentList $OMEUsername, $(ConvertTo-SecureString -Force -AsPlainText $OMEPassword)
Connect-OMEServer -Name $OMEServer -Credentials $credentials -IgnoreCertificateWarning

# Generate report and download to CSV file
$ReportId = Get-OMEReport | Where-Object 'Name' -EQ "Warranty Report" | Select-Object -ExpandProperty Id
Invoke-OMEReport -ReportId $ReportId | Export-Csv c:\Temp\report.csv -NoTypeInformation

Disconnect-OMEServer