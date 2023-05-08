using module ..\Classes\AlertPolicy.psm1

function New-AlertPolicyFromJson {
    Param(
        [PSCustomObject]$AlertPolicy
    )

    return [AlertPolicy]@{
        Id = $AlertPolicy.Id
        Name = $AlertPolicy.Name
        Description = $AlertPolicy.Description
        Enabled = $AlertPolicy.Enabled
        DefaultPolicy = $AlertPolicy.DefaultPolicy
        State = $AlertPolicy.State
        Visible = $AlertPolicy.Visible
        Owner = $AlertPolicy.Owner
        PolicyData = $AlertPolicy.PolicyData
    }
}