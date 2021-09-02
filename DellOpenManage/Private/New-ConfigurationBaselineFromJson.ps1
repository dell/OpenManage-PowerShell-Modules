using module ..\Classes\ConfigurationBaseline.psm1
function New-ConfigurationBaselineFromJson {
    Param(
        [PSCustomObject]$ConfigurationBaseline
    )
    $Targets = @()
    foreach ($Target in $ConfigurationBaseline.BaselineTargets){
        $Targets += $Target.Id
    }
    if ($ConfigurationBaseline.LastRun -eq "Unknown") {
        $LastRun = $null
    } else {
        $LastRun = $ConfigurationBaseline.LastRun
    }
    return [ConfigurationBaseline]@{
        Id = $ConfigurationBaseline.Id
        Name = $ConfigurationBaseline.Name
        Description = $ConfigurationBaseline.Description
        TemplateId = $ConfigurationBaseline.TemplateId
        TemplateName = $ConfigurationBaseline.TemplateName
        TemplateType = $ConfigurationBaseline.TemplateType
        LastRun = $LastRun
        BaselineTargets = $ConfigurationBaseline.BaselineTargets
        Targets = $Targets
    }
}