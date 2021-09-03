[CmdletBinding()]
param(
    [Parameter(Mandatory=$false, ValueFromPipeline)]
    [Switch]$ExportCsv
)

if (Get-Module -ListAvailable -Name PSScriptAnalyzer) {
    Write-Host "Module exists..."
}
else {
    Write-Host "Installing module..."
    Install-Module -Name PSScriptAnalyzer -Scope CurrentUser
}

Import-Module -Name PSScriptAnalyzer

if ($ExportCsv) {
    $fields = @("Line", "Column", "ScriptName", "Severity", "Message", "RuleName", "ScriptPath")
    # -Severity Error,Warning
    Invoke-ScriptAnalyzer -Path .\DellOpenManage\ -Recurse -ExcludeRule PSAvoidUsingWriteHost,PSUseShouldProcessForStateChangingFunctions,PSUseToExportFieldsInManifest | Select-Object -Property $fields | Export-Csv -Path .\Tests\Invoke-PSScriptAnalyzer.csv -NoTypeInformation
} else {
    Invoke-ScriptAnalyzer -Path .\DellOpenManage\ -Recurse -ExcludeRule PSAvoidUsingWriteHost,PSUseShouldProcessForStateChangingFunctions,PSUseToExportFieldsInManifest
}
