using module ..\Classes\Template.psm1
function New-TemplateFromJson {
    Param(
        [PSCustomObject]$Template
    )

    return [Template]@{
        Id = $Template.Id
        Name = $Template.Name
        Description = $Template.Description
        Content = $Template.Content
        SourceDeviceId = $Template.SourceDeviceId
        TypeId = $Template.TypeId
        ViewTypeId = $Template.ViewTypeId
        TaskId = $Template.TaskId
        HasIdentityAttributes = $Template.HasIdentityAttributes
        Status = $Template.Status
        IdentityPoolId = $Template.IdentityPoolId
        IsPersistencePolicyValid = $Template.IsPersistencePolicyValid
        IsStatelessAvailable = $Template.IsStatelessAvailable
        IsBuiltIn = $Template.IsBuiltIn
        CreatedBy = $Template.CreatedBy
        CreationTime = $Template.CreationTime
        LastUpdatedBy = $Template.LastUpdatedBy
        LastUpdatedTime = $Template.LastUpdatedTime
        Views = $Template.Views
    }
}