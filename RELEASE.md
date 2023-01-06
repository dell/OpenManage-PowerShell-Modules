# Release Process

## Run Pester Tests
```
.\Tests\Main.Tests.ps1 -Server "192.168.1.100"
```

## Run PSScriptAnalyzer
```
.\Tests\Invoke-PSScriptAnalyzer.ps1
```

## Generate Documentation
```
.\Documentation\GenerateMD.ps1
```

## Update CHANGELOG.md
```
## [x.x.x]() - YYYY-MM-DD
### Added
- Added new commandlet

### Changed
- Changed existing commandlet

### Fixed
- Fixed issue on existing commandlet
```

## Bump Version
```
.\Build-Module.ps1 -Version 2.3.1
```

## Commit Changes
```
git commit -m 'Release 2.3.1'
git checkout main
git merge devel

# Only tag releases as this triggers a git workflow (.github/workflows/create-release.yml)
git tag v2.3.1
git push origin v2.3.1
git push origin main
```