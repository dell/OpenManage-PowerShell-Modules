function Resolve-Error ($ErrorRecord=$Error[0])
{
    Write-Host $($ErrorRecord | Format-List * -Force | Out-String) -Foreground "Red"
    Write-Host $($ErrorRecord.InvocationInfo | Format-List * | Out-String) -Foreground "Red"
    $Exception = $ErrorRecord.Exception
    for ($i = 0; $Exception; $i++, ($Exception = $Exception.InnerException))
    {
        Write-Host $($Exception | Format-List * -Force | Out-String) -Foreground "Red"
    }
}