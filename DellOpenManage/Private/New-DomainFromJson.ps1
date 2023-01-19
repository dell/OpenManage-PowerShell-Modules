using module ..\Classes\Domain.psm1
function New-DomainFromJson {
    Param(
        [PSCustomObject]$Domain
    )
    return [Domain]@{
        Id = $Domain.Id
        DeviceId = $Domain.DeviceId
        PublicAddress = $Domain.PublicAddress
        Name = $Domain.Name
        Description = $Domain.Description
        Identifier = $Domain.Identifier
        DomainTypeId = $Domain.DomainTypeId
        DomainTypeValue = $Domain.DomainTypeValue
        DomainRoleTypeId = $Domain.DomainRoleTypeId
        DomainRoleTypeValue = $Domain.DomainRoleTypeValue
        Version = $Domain.Version
        Local = $Domain.Local
        GroupId = $Domain.GroupId
        GroupName = $Domain.GroupName
        BackupLead = $Domain.BackupLead
        Capabilities = $Domain.Capabilities
        BackupLeadHealth = $Domain.BackupLeadHealth
    }
}