# Testing

## Pester Requirements
Requires Pester 4.0+
```
Install-Module -Name Pester -Scope CurrentUser -Force
```

## Run All Tests
```
.\Tests\Main.Tests.ps1 -Server "192.168.1.100"
```
## Run Group of Tests
```
.\Tests\Main.Tests.ps1 -Server "192.168.1.100" -Test Template
```
## Run Tests by Tag
```
.\Tests\Main.Tests.ps1 -Server "192.168.1.100" -Test Template -Tag Deployment
```