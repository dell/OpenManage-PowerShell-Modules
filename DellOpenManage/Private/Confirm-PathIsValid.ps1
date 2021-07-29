function Confirm-PathIsValid {
    <#
    .SYNOPSIS
      Tests whether a filepath is valid or not.
  
    .DESCRIPTION
      Performs different tests depending on whether you are testing a file for the ability to read
      (InputFilePath) or write (OutputFilePath)
  
    .PARAMETER OutputFilePath
      The path to an output file you want to test
  
    .PARAMETER InputFilePath
      The path to an input file you want to test
  
    .OUTPUTS
      Returns true if the path is valid and false if it is not
    #>
    [CmdletBinding()]
    param (
  
      [Parameter(Mandatory = $false)]
      [string]
      $OutputFilePath,
  
      [Parameter(Mandatory = $false)]
      [string]
      $InputFilePath
    )
  
    if ($PSBoundParameters.ContainsKey('InputFilePath') -and $PSBoundParameters.ContainsKey('OutputFilePath')) {
      Write-Error "You can only provide either an InputFilePath or an OutputFilePath."
      Exit
    }
  
    # Some of the tests are the same - we can use the same variable name
    if ($PSBoundParameters.ContainsKey('InputFilePath')) {
      $OutputFilePath = $InputFilePath
    }
  
    if ($PSBoundParameters.ContainsKey('InputFilePath')) {
      if (-not $(Test-Path -Path $InputFilePath -PathType Leaf)) {
        Write-Error "The file $($InputFilePath) does not exist."
        return $false
      }
    }
    else {
      if (Test-Path -Path $OutputFilePath -PathType Leaf) {
        if (-not $(Read-Confirmation "$($OutputFilePath) already exists. Do you want to continue? (Y/N)")) {
          return $false
        } 
      }
    }
  
    $ParentPath = $(Split-Path -Path $OutputFilePath -Parent)
    if ($ParentPath -ne "") {
      if (-not $(Test-Path -PathType Container $ParentPath)) {
        Write-Error "The path '$($OutputFilePath)' does not appear to be valid."
        return $false
      }
    }
  
    if (Test-Path $(Split-Path -Path $OutputFilePath -Leaf) -PathType Container) {
      Write-Error "You must provide a filename as part of the path. It looks like you only provided a folder in $($OutputFilePath)!"
      return $false
    }
  
    return $true
  }