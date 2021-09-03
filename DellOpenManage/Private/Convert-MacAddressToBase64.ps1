function Convert-MacAddressToBase64 {
    param(
        [Parameter(Mandatory, ValueFromPipeline)]
        [String]$MacAddress
        )
    
    Begin {}

    Process {
        Try {
            # Remove everything except hex digits from the string
            $MacAddress = $MacAddress -replace '[^0-9a-f]'

            # Convert all hex-digit pairs in the string to an array of bytes.
            $MacAddressBytes = [byte[]] ($MacAddress -split '(..)' -ne '' -replace '^', '0x')

            # Get the Base64 encoding of the byte array.
            $MacAddressBase64 = [System.Convert]::ToBase64String($MacAddressBytes)
            return $MacAddressBase64
        }

        Catch {
            Resolve-Error $_
        }
    }
    
    End {}

}