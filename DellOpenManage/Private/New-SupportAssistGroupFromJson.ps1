using module ..\Classes\SupportAssistGroup.psm1
function New-SupportAssistGroupFromJson {
    Param(
        [PSCustomObject]$Group
    )
    return [SupportAssistGroup]@{
        Id = $Group.Id
        Name = $Group.Name
        Description = $Group.Description
        ContactOptIn = $Group.ContactOptIn
        DispatchOptIn = $Group.DispatchOptIn
        MyAccountId = $Group.MyAccountId
        CustomerDetails = $Group.CustomerDetails
    }
}