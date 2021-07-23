function Get-MXDomains {
    param(
        [Parameter(Mandatory)]
        [String]$BaseUri,

        [Parameter(Mandatory)]
        [PSCustomObject]$Headers,

        [Parameter(Mandatory, ValueFromPipeline)]
        [ValidateSet("LEAD", "BACKUPLEAD", "MEMBER")]
        [String]$RoleType
    )
    $Members = @()
    $URL = $BaseUri + "/api/ManagementDomainService/Domains"
    $ContentType = "application/json"
    $Response = Invoke-WebRequest -Uri $URL -Headers $Headers -ContentType $ContentType -Method GET
    if ($Response.StatusCode -eq 200) {
        $DomainResp = $Response.Content | ConvertFrom-Json
        if ($DomainResp."value".Length -gt 0) {
            $MemberDevices = $DomainResp."value"
            foreach ($Member in $MemberDevices) {
                if ($RoleType -eq "LEAD" -and $Member.'DomainRoleTypeValue' -eq "LEAD") {
                    $Members += $Member
                } elseif ($RoleType -eq "MEMBER" -and $Member.'DomainRoleTypeValue' -eq "MEMBER") {
                    $Members += $Member
                } elseif ($RoleType -eq "BACKUPLEAD" -and $Member.'BackupLead' -eq $true) {
                    $Members += $Member
                }
            }
        }
        else {
            Write-Warning "No domains discovered"
        }
        return $Members
    }
    else {
        Write-Warning "Failed to get domains and status code returned is $($Response.StatusCode)"
    }
}