using module ..\Classes\AccountProvider.psm1
function New-AccountProviderFromJson {
    Param(
        [PSCustomObject]$AccountProvider
    )
    return [AccountProvider]@{
        Id = $AccountProvider.Id
        Name = $AccountProvider.Name
        ServerType = $AccountProvider.ServerType
        ServerName = $AccountProvider.ServerName
        DnsServer = $AccountProvider.DnsServer
        GroupDomain = $AccountProvider.GroupDomain
        ServerPort = $AccountProvider.ServerPort
        NetworkTimeOut = $AccountProvider.NetworkTimeOut
        SearchTimeOut = $AccountProvider.SearchTimeOut
        CertificateValidation = $AccountProvider.CertificateValidation
        BindDN = $AccountProvider.BindDN
        BaseDistinguishedName = $AccountProvider.BaseDistinguishedName
        AttributeUserLogin = $AccountProvider.AttributeUserLogin
        AttributeGroupMembership = $AccountProvider.AttributeGroupMembership
        SearchFilter = $AccountProvider.SearchFilter
    }
}