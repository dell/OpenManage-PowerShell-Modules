using module ..\Classes\Role.psm1
function New-RoleFromJson {
    Param(
        [PSCustomObject]$Role
    )
    return [Role]@{
        Id = $Role.Id
        Description = $Role.Description
        Name = $Role.Name
        OemPrivileges = $Role.OemPrivileges
        AssignedPrivileges = $Role.AssignedPrivileges
        IsPredefined = $Role.IsPredefined
        IsScopeSupported = $Role.IsScopeSupported
    }
}