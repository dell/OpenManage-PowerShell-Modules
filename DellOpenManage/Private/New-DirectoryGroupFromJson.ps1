using module ..\Classes\DirectoryGroup.psm1
function New-DirectoryGroupFromJson {
    Param(
        [PSCustomObject]$DirectoryGroup
    )
    return [DirectoryGroup]@{
        CommonName = $DirectoryGroup.CommonName
        GroupType = $DirectoryGroup.GroupType
        DistinguishedName = $DirectoryGroup.DistinguishedName
        DomainComponent = $DirectoryGroup.DomainComponent
        ObjectGuid = $DirectoryGroup.ObjectGuid
        ObjectSid = $DirectoryGroup.ObjectSid
    }
}

