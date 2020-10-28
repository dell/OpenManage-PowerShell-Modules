# Sign the module
$cert = Get-ChildItem Cert:\CurrentUser\My\ -CodeSigningCert | Where { $_.HasPrivateKey -and ( $_.NotAfter -gt (Get-Date)) }
 
Get-ChildItem ~/Documents\WindowsPowerShell\Modules\$MyModule -Include *.psd1,*.psm1 -Recurse |
Set-AuthenticodeSignature -Certificate $cert -TimestampServer http://timestamp.digicert.com -Verbose -HashAlgorithm SHA256
# at this stage only .psd1 and psm1 are signed
Get-AuthenticodeSignature ~/Documents\WindowsPowerShell\Modules\$MyModule\*

# Create the catalog file
New-FileCatalog -Path  ~/Documents\WindowsPowerShell\Modules\$MyModule -CatalogFilePath ~/Documents\WindowsPowerShell\Modules\$MyModule\MyModule.cat -CatalogVersion 2.0 -Verbose

# Sign the catalog file
Get-ChildItem ~/Documents\WindowsPowerShell\Modules\$MyModule\MyModule.cat -EA 0 |
Set-AuthenticodeSignature -Certificate $cert -TimestampServer http://timestamp.digicert.com -Verbose -HashAlgorithm SHA256

# Test the catalog file
Test-FileCatalog -Path ~/Documents\WindowsPowerShell\Modules\$MyModule -CatalogFilePath ~/Documents\WindowsPowerShell\Modules\$MyModule\MyModule.cat -Detailed
Get-AuthenticodeSignature ~/Documents\WindowsPowerShell\Modules\$MyModule\*
