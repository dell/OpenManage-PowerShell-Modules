Class ConfigurationBaseline {
    [Int]$Id
    [String]$Name
    [String]$Description
    [Int]$TemplateId
    [String]$TemplateName
    [Int]$TemplateType
    [nullable[DateTime]]$LastRun
    [Int[]]$Targets
}