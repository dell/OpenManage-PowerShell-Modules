using module ..\Classes\ConfigurationBaseline.psm1
function New-ConfigurationBaselineFromJson {
    Param(
        [PSCustomObject]$ConfigurationBaseline
    )
    $Targets = @()
    foreach ($Target in $ConfigurationBaseline.BaselineTargets){
        $Targets += $Target.Id
    }
    return [ConfigurationBaseline]@{
        Id = $ConfigurationBaseline.Id
        Name = $ConfigurationBaseline.Name
        Description = $ConfigurationBaseline.Description
        TemplateId = $ConfigurationBaseline.TemplateId
        TemplateName = $ConfigurationBaseline.TemplateName
        TemplateType = $ConfigurationBaseline.TemplateType
        LastRun = $ConfigurationBaseline.LastRun
        BaselineTargets = $ConfigurationBaseline.BaselineTargets
        Targets = $Targets
    }
}