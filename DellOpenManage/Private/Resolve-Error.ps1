function Resolve-Error ($ErrorRecord=$Error[0]) {
    Write-Host $("ERROR: " + $ErrorRecord.Exception.Message) -ForegroundColor Red
    Write-Host $($ErrorRecord | Format-List * -Force | Out-String) -ForegroundColor Red
    Write-Host $($ErrorRecord.InvocationInfo | Format-List * | Out-String) -ForegroundColor Red
    $Exception = $ErrorRecord.Exception
    for ($i = 0; $Exception; $i++, ($Exception = $Exception.InnerException)) {
        Write-Host $($Exception | Format-List * -Force | Out-String) -ForegroundColor Red
    }
}