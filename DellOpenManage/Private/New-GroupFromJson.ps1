using module ..\Classes\Group.psm1
function New-GroupFromJson {
    Param(
        [PSCustomObject]$Group
    )
    return [Group]@{
        Id = $Group.Id
        Name = $Group.Name
        Description = $Group.Description
        CreationTime = $Group.CreationTime
        UpdatedTime = $Group.UpdatedTime
        CreatedBy = $Group.CreatedBy
        UpdatedBy = $Group.UpdatedBy
        Visible = $Group.Visible
        DefinitionId = $Group.DefinitionId
        DefinitionDescription = $Group.DefinitionDescription
        TypeId = $Group.TypeId
        MembershipTypeId = $Group.MembershipTypeId
        HasAttributes = $Group.HasAttributes
        ParentId = $Group.ParentId
    }
}