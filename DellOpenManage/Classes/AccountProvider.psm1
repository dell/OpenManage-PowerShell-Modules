Class AccountProvider {
    [Int]$Id
    [String]$Name
    [String]$ServerType
    [String[]]$ServerName
    [String[]]$DnsServer
    [String]$GroupDomain
    [Int]$ServerPort
    [Int]$NetworkTimeOut
    [Int]$SearchTimeOut
    [Boolean]$CertificateValidation
    [String]$BindDN
    [String]$BaseDistinguishedName
    [String]$AttributeUserLogin
    [String]$AttributeGroupMembership
    [String]$SearchFilter
}