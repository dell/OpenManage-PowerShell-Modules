function Confirm-IsAuthenticated {
    if (!$SessionAuth.Token){
        Write-Error "Please use Connect-OMEServer first"
        return $false
    } else {
        return $true
    }
}