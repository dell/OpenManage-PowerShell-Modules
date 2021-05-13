Class ConfigurationBaseline {
    [Int]$Id
    [String]$Name
    [String]$Description
    [Int]$TemplateId
    [String]$TemplateName
    [Int]$TemplateType
    [nullable[DateTime]]$LastRun
    [PSCustomObject]$BaselineTargets
    [Int[]]$Targets
}