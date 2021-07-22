using module ..\Classes\Account.psm1
function New-AccountFromJson {
    Param(
        [PSCustomObject]$Account
    )
    $AccountObj = [Account]@{
        Id = $Account.Id
        UserTypeId = $Account.UserTypeId
        DirectoryServiceId = $Account.DirectoryServiceId
        Description = $Account.Description
        Name = $Account.Name
        UserName = $Account.UserName
        RoleId = $Account.RoleId
        Locked = $Account.Locked
        IsBuiltin = $Account.IsBuiltin
        Enabled = $Account.Enabled
        IsVisible = $Account.IsVisible
    }
    return $AccountObj
}

