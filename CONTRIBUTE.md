# Contribution Guidelines

## Getting Started
1. Fork `OpenManage-PowerShell-Modules` repository on GitHub.com
2. Clone your personal fork (`git clone git@github.com:TrevorSquillario/OpenManage-PowerShell-Modules.git`)
4. Create your feature branch (`git checkout -b feature/AmazingFeature`)
5. Run PSScriptAnalyzer to ensure no Warnings or Errors are reported (`.\Tests\Invoke-PSScriptAnalyzer.ps1`)
5. Commit your Changes (`git commit -m 'Add some AmazingFeature'`)
6. Push the Branch (`git push origin feature/AmazingFeature`)
8. Create a Pull Request on GitHub.com from this commit to the `devel` branch of the main repository

## Troubleshooting
### How to resync fork from upstream repository
*This will overwrite any local commits that don't exist on the upstream repo. 
```
git remote add upstream https://github.com/dell/OpenManage-PowerShell-Modules.git
git fetch upstream
git checkout devel
git rebase upstream/devel
```