#Install-Module -Name PSScriptAnalyzer -Scope CurrentUser
Import-Module -Name PSScriptAnalyzer

Invoke-ScriptAnalyzer -Path .\DellOpenManage\Private\*.ps1
Invoke-ScriptAnalyzer -Path .\DellOpenManage\Public\*.ps1