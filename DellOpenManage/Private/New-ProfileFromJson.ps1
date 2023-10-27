using module ..\Classes\Profile.psm1
function New-ProfileFromJson {
    Param(
        [PSCustomObject]$ServerProfile
    )
    $LastDeployDate = $null
    if ($ServerProfile.LastDeployDate -eq "") {
        $LastDeployDate = $null
    } else {
        $LastDeployDate = $ServerProfile.LastDeployDate
    }
    $ProfileObj = [Profile]@{
        Id = $ServerProfile.Id
        ProfileName = $ServerProfile.ProfileName
        ProfileDescription = $ServerProfile.ProfileDescription
        TemplateId = $ServerProfile.TemplateId
        TemplateName = $ServerProfile.TemplateName
        DataSchemaId = $ServerProfile.DataSchemaId
        TargetId = $ServerProfile.TargetId
        TargetName = $ServerProfile.TargetName
        TargetTypeId = $ServerProfile.TargetTypeId
        DeviceIdInSlot = $ServerProfile.DeviceIdInSlot
        ChassisId = $ServerProfile.ChassisId
        ChassisName = $ServerProfile.ChassisName
        GroupId = $ServerProfile.GroupId
        GroupName = $ServerProfile.GroupName
        NetworkBootToIso = $ServerProfile.NetworkBootToIso
        ProfileState = $ServerProfile.ProfileState
        DeploymentTaskId = $ServerProfile.DeploymentTaskId
        LastRunStatus = $ServerProfile.LastRunStatus
        ProfileModified = $ServerProfile.ProfileModified
        CreatedBy = $ServerProfile.CreatedBy
        EditedBy = $ServerProfile.EditedBy
        CreatedDate = $ServerProfile.CreatedDate
        LastEditDate = $ServerProfile.LastEditDate
        LastDeployDate = $LastDeployDate
    }
    return $ProfileObj
}

