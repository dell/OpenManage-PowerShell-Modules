function Convert-PSObjectToHashtable
{
  <#
    .SYNOPSIS
      Converts a PSObject to a HashTable

    .DESCRIPTION
      Often, when we get input back from the API we want to be able to manipulate the output as a hashtable rather
      than a PSCustomObject. This function will take as input a PSObject and convert it to a hashtable. When data
      is converted using ConvertFromJson that requires some extra handling.

      Note: This was shamelessly stolen from @Dave Wyatt's answere here:
      https://stackoverflow.com/questions/22002748/hashtables-from-convertfrom-json-have-different-type-from-powershells-built-in-h

    .PARAMETER InputObject
      The PSObject you would like to convert.

    .OUTPUTS
      A HashTable equivalent of the input PSObject.
  #>
    param (
        [Parameter(ValueFromPipeline)]
        $InputObject
    )

    process
    {
        if ($null -eq $InputObject) { return $null }

        if ($InputObject -is [System.Collections.IEnumerable] -and $InputObject -isnot [string])
        {
            $Collection = @(
                foreach ($object in $InputObject) { ConvertPSObjectToHashtable $object }
            )

            Write-Output -NoEnumerate $Collection
        }
        elseif ($InputObject -is [psobject])
        {
            $Hash = @{}

            foreach ($Property in $InputObject.PSObject.Properties)
            {
                $Hash[$Property.Name] = ConvertPSObjectToHashtable $Property.Value
            }

            return $Hash
        }
        else
        {
            return $InputObject
        }
    }
}