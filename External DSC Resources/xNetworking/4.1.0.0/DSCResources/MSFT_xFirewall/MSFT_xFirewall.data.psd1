@{
    ParameterList = @(
        @{ Name = 'Name';                Variable = 'FirewallRule';                                    Type = 'String'                  }
        @{ Name = 'DisplayName';         Variable = 'FirewallRule';                                    Type = 'String'                  }
        @{ Name = 'Group';               Variable = 'FirewallRule';                                    Type = 'String'                  }
        @{ Name = 'DisplayGroup';        Variable = 'FirewallRule';                                    Type = ''                        }
        @{ Name = 'Enabled';             Variable = 'FirewallRule';                                    Type = 'String'                  }
        @{ Name = 'Action';              Variable = 'FirewallRule';                                    Type = 'String'                  }
        @{ Name = 'Profile';             Variable = 'FirewallRule';                                    Type = 'Array'; Delimiter = ', ' }
        @{ Name = 'Direction';           Variable = 'FirewallRule';                                    Type = 'String'                  }
        @{ Name = 'Description';         Variable = 'FirewallRule';                                    Type = 'String'                  }
        @{ Name = 'RemotePort';          Variable = 'properties';   Property = 'PortFilters';          Type = 'Array'                   }
        @{ Name = 'LocalPort';           Variable = 'properties';   Property = 'PortFilters';          Type = 'Array'                   }
        @{ Name = 'Protocol';            Variable = 'properties';   Property = 'PortFilters';          Type = 'String'                  }
        @{ Name = 'Program';             Variable = 'properties';   Property = 'ApplicationFilters';   Type = 'String'                  }
        @{ Name = 'Service';             Variable = 'properties';   Property = 'ServiceFilters';       Type = 'String'                  }
        @{ Name = 'Authentication';      Variable = 'properties';   Property = 'SecurityFilters';      Type = 'String'                  }
        @{ Name = 'Encryption';          Variable = 'properties';   Property = 'SecurityFilters';      Type = 'String'                  }
        @{ Name = 'InterfaceAlias';      Variable = 'properties';   Property = 'InterfaceFilters';     Type = 'Array'                   }
        @{ Name = 'InterfaceType';       Variable = 'properties';   Property = 'InterfaceTypeFilters'; Type = 'String'                  }
        @{ Name = 'LocalAddress';        Variable = 'properties';   Property = 'AddressFilters';       Type = 'ArrayIP'                 }
        @{ Name = 'LocalUser';           Variable = 'properties';   Property = 'SecurityFilters';      Type = 'String'                  }
        @{ Name = 'Package';             Variable = 'properties';   Property = 'ApplicationFilters';   Type = 'String'                  }
        @{ Name = 'Platform';            Variable = 'FirewallRule';                                    Type = 'Array'                   }
        @{ Name = 'RemoteAddress';       Variable = 'properties';   Property = 'AddressFilters';       Type = 'ArrayIP'                 }
        @{ Name = 'RemoteMachine';       Variable = 'properties';   Property = 'SecurityFilters';      Type = 'String'                  }
        @{ Name = 'RemoteUser';          Variable = 'properties';   Property = 'SecurityFilters';      Type = 'String'                  }
        @{ Name = 'DynamicTransport';    Variable = 'properties';   Property = 'PortFilters';          Type = 'String'                  }
        @{ Name = 'EdgeTraversalPolicy'; Variable = 'FirewallRule';                                    Type = 'String'                  }
        @{ Name = 'IcmpType';            Variable = 'properties';   Property = 'PortFilters';          Type = 'Array'                   }
        @{ Name = 'LocalOnlyMapping';    Variable = 'FirewallRule';                                    Type = 'Boolean'                 }
        @{ Name = 'LooseSourceMapping';  Variable = 'FirewallRule';                                    Type = 'Boolean'                 }
        @{ Name = 'OverrideBlockRules';  Variable = 'properties';   Property = 'SecurityFilters';      Type = 'Boolean'                 }
        @{ Name = 'Owner';               Variable = 'FirewallRule';                                    Type = 'String'                  }
    )
}
