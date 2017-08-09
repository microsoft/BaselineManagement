# Localized resources for MSFT_xFirewall

ConvertFrom-StringData @'
    GettingFirewallRuleMessage = Getting firewall rule with Name '{0}'.
    FirewallRuleDoesNotExistMessage = Firewall rule with Name '{0}' does not exist.
    FirewallParameterValueMessage = Firewall rule with Name '{0}' parameter {1} is '{2}'.
    ApplyingFirewallRuleMessage = Applying settings for firewall rule with Name '{0}'.
    FindFirewallRuleMessage = Find firewall rule with Name '{0}'.
    FirewallRuleShouldExistMessage = We want the firewall rule with Name '{0}' to exist since Ensure is set to {1}.
    FirewallRuleShouldExistAndDoesMessage = We want the firewall rule with Name '{0}' to exist and it does. Check for valid properties.
    CheckFirewallRuleParametersMessage = Check each defined parameter against the existing firewall rule with Name '{0}'.
    UpdatingExistingFirewallMessage = Updating existing firewall rule with Name '{0}'.
    FirewallRuleShouldExistAndDoesNotMessage = We want the firewall rule with Name '{0}' to exist, but it does not.
    FirewallRuleShouldNotExistMessage = We do not want the firewall rule with Name '{0}' to exist since Ensure is set to {1}.
    FirewallRuleShouldNotExistButDoesMessage = We do not want the firewall rule with Name '{0}' to exist, but it does. Removing it.
    FirewallRuleShouldNotExistAndDoesNotMessage = We do not want the firewall rule with Name '{0}' to exist, and it does not.
    CheckingFirewallRuleMessage = Checking settings for firewall rule with Name '{0}'.
    CheckingFirewallReturningMessage = Check Firewall rule with Name '{0}' returning {1}.
    PropertyNoMatchMessage = {0} property value '{1}' does not match desired state '{2}'.
    TestFirewallRuleReturningMessage = Test Firewall rule with Name '{0}' returning {1}.
    FirewallRuleNotFoundMessage = No Firewall Rule found with Name '{0}'.
    GetAllPropertiesMessage = Get all the properties and add filter info to rule map.
    RuleNotUniqueError = {0} Firewall Rules with the Name '{1}' were found. Only one expected.
'@
