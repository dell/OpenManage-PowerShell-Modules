<#
    This example will connect to Active Directory using DNS to lookup the Global Catalog servers.
    It will then import an Active Directory Group and assign it to the CHASSIS_ADMINISTRATOR account role
#>

$ADDomain = "lab.local"
$ADGroup = "Administrators"
$UserName = "Usename@${ADDomain}"
$Password = $(ConvertTo-SecureString "calvin" -AsPlainText -Force)

New-OMEDirectoryService -Name $ADDomain.ToUpper() -DirectoryType "AD" `
    -DirectoryServerLookup "DNS" -DirectoryServers @($ADDomain) -ADGroupDomain $ADDomain

$AD = Get-OMEDirectoryService -DirectoryType "AD" -Name $ADDomain
$ADGroups = Get-OMEDirectoryServiceSearch -Name $ADGroup -DirectoryService $AD -DirectoryType "AD" -UserName $UserName  -Password $Password
$Role = Get-OMERole -Name "chassis"

Invoke-OMEDirectoryServiceImportGroup -DirectoryService $AD -DirectoryGroups $ADGroups -Role $Role -Verbose
