# Localized resources for MSFT_xIPAddress

ConvertFrom-StringData @'
    GettingIPAddressMessage = Getting the IP Address.
    ApplyingIPAddressMessage = Applying the IP Address.
    IPAddressSetStateMessage = IP Interface was set to the desired state.
    CheckingIPAddressMessage = Checking the IP Address.
    IPAddressDoesNotMatchMessage = IP Address does NOT match desired state. Expected {0}, actual {1}.
    IPAddressMatchMessage = IP Address is in desired state.
    PrefixLengthDoesNotMatchMessage = Prefix Length does NOT match desired state. Expected {0}, actual {1}.
    PrefixLengthMatchMessage = Prefix Length is in desired state.
    DHCPIsNotDisabledMessage = DHCP is NOT disabled.
    DHCPIsAlreadyDisabledMessage = DHCP is already disabled.
    DHCPIsNotTestedMessage = DHCP status is ignored when Address Family is IPv6.
    InterfaceNotAvailableError = Interface "{0}" is not available. Please select a valid interface and try again.
    AddressFormatError = Address "{0}" is not in the correct format. Please correct the Address parameter in the configuration and try again.
    AddressIPv4MismatchError = Address "{0}" is in IPv4 format, which does not match server address family {1}. Please correct either of them in the configuration and try again.
    AddressIPv6MismatchError = Address "{0}" is in IPv6 format, which does not match server address family {1}. Please correct either of them in the configuration and try again.
    PrefixLengthError = A Prefix Length of {0} is not valid for {1} addresses. Please correct the Prefix Length and try again.
'@
