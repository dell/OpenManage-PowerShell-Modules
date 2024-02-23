function Get-ApiAllData {
<#
    .SYNOPSIS

    .DESCRIPTION

    .PARAMETER InputObject

    .OUTPUTS
#>
    param (
        [Parameter(Mandatory)]
        [String]$BaseUri,

        [Parameter(Mandatory)]
        [String]$Url,

        [Parameter(Mandatory)]
        [PSCustomObject]$Headers

    )
    $Data = @()
    $ContentType = "application/json"
    $Response = Invoke-WebRequest -UseBasicParsing -Uri $Url -Headers $Headers -Method Get
    if ($Response.StatusCode -in (200,201)) {
        $Info = $Response.Content | ConvertFrom-Json
        if ($Info.value) { 
            foreach ($Value in $Info.value) {
                $Data += $Value
            }
            if ($Info.'@odata.nextLink') {
                $NextLinkUrl = $BaseUri + $Info.'@odata.nextLink'
            }
            while($NextLinkUrl) {
                $NextLinkResponse = Invoke-WebRequest -Uri $NextLinkUrl -UseBasicParsing -Method Get -Headers $Headers -ContentType $ContentType
                if($NextLinkResponse.StatusCode -in (200,201))
                {
                    $NextLinkData = $NextLinkResponse.Content | ConvertFrom-Json
                    foreach ($NextLink in $NextLinkData.'value') {
                        $Data += $NextLink
                    }
                    if ($NextLinkData.'@odata.nextLink') {
                        $NextLinkUrl = $BaseUri + $NextLinkData.'@odata.nextLink'
                    }
                    else {
                        $NextLinkUrl = $null
                    }
                }
                else
                {
                    Write-Warning "Unable to get nextlink response for $($NextLinkUrl)"
                    $NextLinkUrl = $null
                }
            }
        }
        return $Data
    }
}