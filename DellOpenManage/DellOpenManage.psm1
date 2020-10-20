using module .\Classes\SessionAuth.psm1

# Get public and private function definition files.
$Public  = @( Get-ChildItem -Path $PSScriptRoot\Public\OME\*.ps1 -ErrorAction SilentlyContinue )
$Private = @( Get-ChildItem -Path $PSScriptRoot\Private\*.ps1 -ErrorAction SilentlyContinue )

# Declare module scoped variables to store session info
$SessionAuth = [SessionAuth]::new()
$Script:SessionAuth = $SessionAuth

# Dot source the files
Foreach($import in @($Public + $Private))
{
    Try
    {
        . $import.fullname
    }
    Catch
    {
        Write-Error -Message "Failed to import function $($import.fullname): $_"
    }
}

# Here I might...
# Read in or create an initial config file and variable
# Export Public functions ($Public.BaseName) for WIP modules
# Set variables visible to the module and its functions only

Export-ModuleMember -Function $Public.Basename