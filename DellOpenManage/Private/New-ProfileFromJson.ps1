using module ..\Classes\Profile.psm1
function New-ProfileFromJson {
    Param(
        [PSCustomObject]$Profile
    )
    $LastDeployDate = $null
    if ($Profile.LastDeployDate -eq "") {
        $LastDeployDate = $null
    } else {
        $LastDeployDate = $Profile.LastDeployDate
    }
    $ProfileObj = [Profile]@{
        Id = $Profile.Id
        ProfileName = $Profile.ProfileName
        ProfileDescription = $Profile.ProfileDescription
        TemplateId = $Profile.TemplateId
        TemplateName = $Profile.TemplateName
        DataSchemaId = $Profile.DataSchemaId
        TargetId = $Profile.TargetId
        TargetName = $Profile.TargetName
        TargetTypeId = $Profile.TargetTypeId
        DeviceIdInSlot = $Profile.DeviceIdInSlot
        ChassisId = $Profile.ChassisId
        ChassisName = $Profile.ChassisName
        GroupId = $Profile.GroupId
        GroupName = $Profile.GroupName
        NetworkBootToIso = $Profile.NetworkBootToIso
        ProfileState = $Profile.ProfileState
        DeploymentTaskId = $Profile.DeploymentTaskId
        LastRunStatus = $Profile.LastRunStatus
        ProfileModified = $Profile.ProfileModified
        CreatedBy = $Profile.CreatedBy
        EditedBy = $Profile.EditedBy
        CreatedDate = $Profile.CreatedDate
        LastEditDate = $Profile.LastEditDate
        LastDeployDate = $LastDeployDate
    }
    return $ProfileObj
}

