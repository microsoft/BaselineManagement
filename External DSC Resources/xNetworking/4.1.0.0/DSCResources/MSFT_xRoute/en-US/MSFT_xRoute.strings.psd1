# Localized resources for MSFT_xRoute

ConvertFrom-StringData @'
    GettingRouteMessage = Getting {0} Route on "{1}" dest {2} nexthop {3}.
    RouteExistsMessage = {0} Route on "{1}" dest {2} nexthop {3} exists.
    RouteDoesNotExistMessage = {0} Route on "{1}" dest {2} nexthop {3} does not exist.
    SettingRouteMessage = Setting {0} Route on "{1}" dest {2} nexthop {3}.
    EnsureRouteExistsMessage = Ensuring {0} Route on "{1}" dest {2} nexthop {3} exists.
    EnsureRouteDoesNotExistMessage = Ensuring {0} Route on "{1}" dest {2} nexthop {3} does not exist.
    RouteCreatedMessage = {0} Route on "{1}" dest {2} nexthop {3} has been created.
    RouteUpdatedMessage = {0} Route on "{1}" dest {2} nexthop {3} has been updated.
    RouteRemovedMessage = {0} Route on "{1}" dest {2} nexthop {3} has been removed.
    TestingRouteMessage = Testing {0} Route on "{1}" dest {2} nexthop {3}.
    RoutePropertyNeedsUpdateMessage = {4} property on {0} Route on "{1}" dest {2} nexthop {3} is different. Change required.
    RouteDoesNotExistButShouldMessage = {0} Route on "{1}" dest {2} nexthop {3} does not exist but should. Change required.
    RouteExistsButShouldNotMessage = {0} Route on "{1}" dest {2} nexthop {3} exists but should not. Change required.
    RouteDoesNotExistAndShouldNotMessage = {0} Route on "{1}" dest {2} nexthop {3} does not exist and should not. Change not required.
    InterfaceNotAvailableError = Interface "{0}" is not available. Please select a valid interface and try again.
    AddressFormatError = Address "{0}" is not in the correct format. Please correct the Address parameter in the configuration and try again.
    AddressIPv4MismatchError = Address "{0}" is in IPv4 format, which does not match address family {1}. Please correct either of them in the configuration and try again.
    AddressIPv6MismatchError = Address "{0}" is in IPv6 format, which does not match address family {1}. Please correct either of them in the configuration and try again.
'@
