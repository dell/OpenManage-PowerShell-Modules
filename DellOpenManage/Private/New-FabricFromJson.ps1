using module ..\Classes\Fabric.psm1
function New-FabricFromJson {
    Param(
        [PSCustomObject]$Fabric
    )
    return [Fabric]@{
        Id = $Fabric.Id
        Name = $Fabric.Name
        Description = $Fabric.Description
        OverrideLLDPConfiguration = $Fabric.OverrideLLDPConfiguration
        ScaleVLANProfile = $Fabric.ScaleVLANProfile
    }
}