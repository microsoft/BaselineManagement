@{
    "Accounts_Administrator_account_status" = @{
        Value   = 'EnableAdminAccount'
        Section = 'System Access'
        Option  = @{
            "Enabled"  = '1'
            "Disabled" = '0'
        }
    }

    "Accounts_Block_Microsoft_accounts" = @{
        Value   = "MACHINE\Software\Microsoft\Windows\CurrentVersion\Policies\System\NoConnectedUser"
        Section = 'Registry Values'
        Option  = @{
            "This policy is disabled" = '4,0'
            "Users cant add Microsoft accounts" = '4,1'
            "Users cant add or log on with Microsoft accounts" = '4,3'
        }
    }

    "Accounts_Guest_account_status" = @{
        Value   = 'EnableGuestAccount'
        Section = 'System Access'
        Option  = @{
            "Enabled"  = '1'
            "Disabled" = '0'
        }
    }

    "Accounts_Limit_local_account_use_of_blank_passwords_to_console_logon_only" = @{
        Value   = "MACHINE\System\CurrentControlSet\Control\Lsa\LimitBlankPasswordUse"
        Section = 'Registry Values'
        Option  = @{
            Enabled  = '4,1'
            Disabled = '4,0'
        }
    }

    "Accounts_Rename_administrator_account" = @{
        Value   = 'NewAdministratorName'
        Section = 'System Access'
        Option  = @{
            String = '' # supply name of administrator account
        }
    }

    "Accounts_Rename_guest_account" = @{
        Value   = 'NewGuestName'
        Section = 'System Access'
        Option  = @{
            String = '' # supply name of guest account
        }
    }

    "Audit_Audit_the_access_of_global_system_objects" = @{
        Value   = "MACHINE\System\CurrentControlSet\Control\Lsa\AuditBaseObjects"
        Section = 'Registry Values'
        Option  = @{
            Enabled  = '4,1'
            Disabled = '4,0'
        }
    }

    "Audit_Audit_the_use_of_Backup_and_Restore_privilege" = @{
        Value   = "MACHINE\System\CurrentControlSet\Control\Lsa\FullPrivilegeAuditing"
        Section = 'Registry Values'
        Option  = @{
            Enabled  = '3,1'
            Disabled = '3,0'
        }
    }

    "Audit_Force_audit_policy_subcategory_settings_Windows_Vista_or_later_to_override_audit_policy_category_settings" = @{
        Value   = "MACHINE\System\CurrentControlSet\Control\Lsa\SCENoApplyLegacyAuditPolicy"
        Section = 'Registry Values'
        Option  = @{
            Enabled  = '4,1'
            Disabled = '4,0'
        }
    }

    "Audit_Shut_down_system_immediately_if_unable_to_log_security_audits" = @{
        Value   = "MACHINE\System\CurrentControlSet\Control\Lsa\CrashOnAuditFail"
        Section = 'Registry Values'
        Option  = @{
            Enabled  = '4,1'
            Disabled = '4,0'
        }
    }

    "DCOM_Machine_Access_Restrictions_in_Security_Descriptor_Definition_Language_SDDL_syntax" = @{
        Value   = "MACHINE\Software\Policies\Microsoft\Windows NT\DCOM\MachineAccessRestriction"
        Section = 'Registry Values'
        Option  = @{
            String = '1,' # + <SecurityDescriptorString(same format as icacls)>
        }
    }

    "DCOM_Machine_Launch_Restrictions_in_Security_Descriptor_Definition_Language_SDDL_syntax" = @{
        Value   = "MACHINE\Software\Policies\Microsoft\Windows NT\DCOM\MachineLaunchRestriction"
        Section = 'Registry Values'
        Option  = @{
            String = '1,' # + <SecurityDescriptorString(same format as icacls)>
        }
    }

    "Devices_Allow_undock_without_having_to_log_on" = @{
        Value   = "MACHINE\Software\Microsoft\Windows\CurrentVersion\Policies\System\UndockWithoutLogon"
        Section = 'Registry Values'
        Option  = @{
            Enabled  = '4,1'
            Disabled = '4,0'
        }
    }

    "Devices_Allowed_to_format_and_eject_removable_media" = @{
        Value   = "MACHINE\Software\Microsoft\Windows NT\CurrentVersion\Winlogon\AllocateDASD"
        Section = 'Registry Values'
        Option  = @{
            'Administrators' = '1,"0"'
            'Administrators and Power Users' = '1,"1"'
            'Administrators and Interactive Users' = '1,"2"'
        }
    }

    "Devices_Prevent_users_from_installing_printer_drivers" = @{
        Value   = "MACHINE\System\CurrentControlSet\Control\Print\Providers\LanMan Print Services\Servers\AddPrinterDrivers"
        Section = 'Registry Values'
        Option  = @{
            Enabled  = '4,1'
            Disabled = '4,0'
        }
    }

    "Devices_Restrict_CD_ROM_access_to_locally_logged_on_user_only" = @{
        Value   = "MACHINE\Software\Microsoft\Windows NT\CurrentVersion\Winlogon\AllocateCDRoms"
        Section = 'Registry Values'
        Option  = @{
            Enabled = '1,"1"'
            Disabled = '1,"0"'
        }
    }

    "Devices_Restrict_floppy_access_to_locally_logged_on_user_only" = @{
        Value   = "MACHINE\Software\Microsoft\Windows NT\CurrentVersion\Winlogon\AllocateFloppies"
        Section = 'Registry Values'
        Option  = @{
            Enabled  = '1,"1"'
            Disabled = '1,"0"'
        }
    }

    "Domain_controller_Allow_server_operators_to_schedule_tasks" = @{
        Value   = "MACHINE\System\CurrentControlSet\Control\Lsa\SubmitControl"
        Section = 'Registry Values'
        Option  = @{
            Enabled  = '4,1'
            Disabled = '4,0'
        }
    }

    "Domain_controller_LDAP_server_signing_requirements" = @{
        Value   = "MACHINE\System\CurrentControlSet\Services\NTDS\Parameters\LDAPServerIntegrity"
        Section = 'Registry Values'
        Option  = @{
            'None' = '4,1'
            'Require Signing' = '4,2'
        }
    }

    "Domain_controller_Refuse_machine_account_password_changes" = @{
        Value   = "MACHINE\System\CurrentControlSet\Services\Netlogon\Parameters\RefusePasswordChange"
        Section = 'Registry Values'
        Option  = @{
            Enabled  = '4,1'
            Disabled = '4,0'
        }
    }

    "Domain_member_Digitally_encrypt_or_sign_secure_channel_data_always" = @{
        Value   = "MACHINE\System\CurrentControlSet\Services\Netlogon\Parameters\RequireSignOrSeal"
        Section = 'Registry Values'
        Option  = @{
            Enabled  = '4,1'
            Disabled = '4,0'
        }
    }

    "Domain_member_Digitally_encrypt_secure_channel_data_when_possible" = @{
        Value   = "MACHINE\System\CurrentControlSet\Services\Netlogon\Parameters\SealSecureChannel"
        Section = 'Registry Values'
        Option  = @{
            Enabled  = '4,1'
            Disabled = '4,0'
        }
    }

    "Domain_member_Digitally_sign_secure_channel_data_when_possible" = @{
        Value   = "MACHINE\System\CurrentControlSet\Services\Netlogon\Parameters\SignSecureChannel"
        Section = 'Registry Values'
        Option  = @{
            Enabled  = '4,1'
            Disabled = '4,0'
        }
    }

    "Domain_member_Disable_machine_account_password_changes" = @{
        Value   = "MACHINE\System\CurrentControlSet\Services\Netlogon\Parameters\DisablePasswordChange"
        Section = 'Registry Values'
        Option  = @{
            Enabled  = '4,1'
            Disabled = '4,0'
        }
    }

    "Domain_member_Maximum_machine_account_password_age" = @{
        Value   = "MACHINE\System\CurrentControlSet\Services\Netlogon\Parameters\MaximumPasswordAge"
        Section = 'Registry Values'
        Option  = @{
            String = "4," # + <NumberOfDays>
        }
    }

    "Domain_member_Require_strong_Windows_2000_or_later_session_key" = @{
        Value   = "MACHINE\System\CurrentControlSet\Services\Netlogon\Parameters\RequireStrongKey"
        Section = 'Registry Values'
        Option  = @{
            Enabled  = '4,1'
            Disabled = '4,0'
        }
    }

    "Interactive_logon_Display_user_information_when_the_session_is_locked" = @{
        Value   = "MACHINE\Software\Microsoft\Windows\CurrentVersion\Policies\System\DontDisplayLockedUserId"
        Section = 'Registry Values'
        Option  = @{
            'User displayname, domain and user names' = '4,1'
            'User display name only' = '4,2'
            'Do not display user information' = '4,3'
        }
    }

    "Interactive_logon_Do_not_display_last_user_name" = @{
        Value   = "MACHINE\Software\Microsoft\Windows\CurrentVersion\Policies\System\DontDisplayLastUserName"
        Section = 'Registry Values'
        Option  = @{
            Enabled  = '4,1'
            Disabled = '4,0'
        }
    }

    "Interactive_logon_Do_not_require_CTRL_ALT_DEL" = @{
        Value   = "MACHINE\Software\Microsoft\Windows\CurrentVersion\Policies\System\DisableCAD"
        Section = 'Registry Values'
        Option  = @{
            Enabled  = '4,1'
            Disabled = '4,0'
        }
    }

    "Interactive_logon_Machine_account_lockout_threshold" = @{
        Value   = "MACHINE\Software\Microsoft\Windows\CurrentVersion\Policies\System\MaxDevicePasswordFailedAttempts"
        Section = 'Registry Values'
        Option  = @{
            String = "4," # + <NumberOfAttempts>
        }
    }

    "Interactive_logon_Machine_inactivity_limit" = @{
        Value   = "MACHINE\Software\Microsoft\Windows\CurrentVersion\Policies\System\InactivityTimeoutSecs"
        Section = 'Registry Values'
        Option  = @{
            String = "4," # + <NumberOfSeconds>
        }
    }

    "Interactive_logon_Message_text_for_users_attempting_to_log_on" = @{
        Value   = "MACHINE\Software\Microsoft\Windows\CurrentVersion\Policies\System\LegalNoticeText"
        Section = 'Registry Values'
        Option  = @{
            String = "7," # + <Message>
        }
    }

    "Interactive_logon_Message_title_for_users_attempting_to_log_on" = @{
        Value   = "MACHINE\Software\Microsoft\Windows\CurrentVersion\Policies\System\LegalNoticeCaption"
        Section = 'Registry Values'
        Option  = @{
            String = "1," # + <Message>
        }
    }

    "Interactive_logon_Number_of_previous_logons_to_cache_in_case_domain_controller_is_not_available" = @{
        Value   = "MACHINE\Software\Microsoft\Windows NT\CurrentVersion\Winlogon\CachedLogonsCount"
        Section = 'Registry Values'
        Option  = @{
            String = "1," # + <NumberOfFailedAttempts>
        }
    }

    "Interactive_logon_Prompt_user_to_change_password_before_expiration" = @{
        Value   = "MACHINE\Software\Microsoft\Windows NT\CurrentVersion\Winlogon\PasswordExpiryWarning"
        Section = 'Registry Values'
        Option  = @{
            String = "4," # + <NumberOfDays>
        }
    }

    "Interactive_logon_Require_Domain_Controller_authentication_to_unlock_workstation" = @{
        Value   = "MACHINE\Software\Microsoft\Windows NT\CurrentVersion\Winlogon\ForceUnlockLogon"
        Section = 'Registry Values'
        Option  = @{
            Enabled  = '4,1'
            Disabled = '4,0'
        }
    }

    "Interactive_logon_Require_smart_card" = @{
        Value   = "MACHINE\Software\Microsoft\Windows\CurrentVersion\Policies\System\ScForceOption"
        Section = 'Registry Values'
        Option  = @{
            Enabled  = '4,1'
            Disabled = '4,0'
        }
    }

    "Interactive_logon_Smart_card_removal_behavior" = @{
        Value   = "MACHINE\Software\Microsoft\Windows NT\CurrentVersion\Winlogon\ScRemoveOption"
        Section = 'Registry Values'
        Option  = @{
            'No Action'        = '1,"0"'
            'Lock workstation' = '1,"1"'
            'Force logoff'     = '1,"2"'
            'Disconnect if a remote Remote Desktop Services session' = '1,"3"'
        }
    }

    "Microsoft_network_client_Digitally_sign_communications_always" = @{
        Value   = "MACHINE\System\CurrentControlSet\Services\LanmanWorkstation\Parameters\RequireSecuritySignature"
        Section = 'Registry Values'
        Option  = @{
            Enabled  = '4,1'
            Disabled = '4,0'
        }
    }

    "Microsoft_network_client_Digitally_sign_communications_if_server_agrees" = @{
        Value   = "MACHINE\System\CurrentControlSet\Services\LanmanWorkstation\Parameters\EnableSecuritySignature"
        Section = 'Registry Values'
        Option  = @{
            Enabled  = '4,1'
            Disabled = '4,0'
        }
    }

    "Microsoft_network_client_Send_unencrypted_password_to_third_party_SMB_servers" = @{
        Value   = "MACHINE\System\CurrentControlSet\Services\LanmanWorkstation\Parameters\EnablePlainTextPassword"
        Section = 'Registry Values'
        Option  = @{
            Enabled  = '4,1'
            Disabled = '4,0'
        }
    }

    "Microsoft_network_server_Amount_of_idle_time_required_before_suspending_session" = @{
        Value   = "MACHINE\System\CurrentControlSet\Services\LanManServer\Parameters\AutoDisconnect"
        Section = 'Registry Values'
        Option  = @{
            String = '4,' # + <Minutes>
        }
    }

    "Microsoft_network_server_Attempt_S4U2Self_to_obtain_claim_information" = @{
        Value   = "MACHINE\System\CurrentControlSet\Services\LanManServer\Parameters\EnableS4U2SelfForClaims"
        Section = 'Registry Values'
        Option  = @{
            Default  = '4,0'
            Enabled  = '4,1'
            Disabled = '4,2'
        }
    }

    "Microsoft_network_server_Digitally_sign_communications_always" = @{
        Value   = "MACHINE\System\CurrentControlSet\Services\LanManServer\Parameters\RequireSecuritySignature"
        Section = 'Registry Values'
        Option  = @{
            Enabled  = '4,1'
            Disabled = '4,0'
        }
    }

    "Microsoft_network_server_Digitally_sign_communications_if_client_agrees" = @{
        Value   = "MACHINE\System\CurrentControlSet\Services\LanManServer\Parameters\EnableSecuritySignature"
        Section = 'Registry Values'
        Option  = @{
            Enabled  = '4,1'
            Disabled = '4,0'
        }
    }

    "Microsoft_network_server_Disconnect_clients_when_logon_hours_expire" = @{
        Value   = "MACHINE\System\CurrentControlSet\Services\LanManServer\Parameters\EnableForcedLogOff"
        Section = 'Registry Values'
        Option  = @{
            Enabled  = '4,1'
            Disabled = '4,0'
        }
    }

    "Microsoft_network_server_Server_SPN_target_name_validation_level" = @{
        Value   = "MACHINE\System\CurrentControlSet\Services\LanManServer\Parameters\SmbServerNameHardeningLevel"
        Section = 'Registry Values'
        Option  = @{
            'Off' = '4,0'
            'Accept if provided by client' = '4,1'
            'Required from client' = '4,2'
        }
    }

    "Network_access_Allow_anonymous_SID_Name_translation" = @{
        Value   = 'LSAAnonymousNameLookup'
        Section = 'System Access'
        Option  = @{
            Enabled  = '1'
            Disabled = '0'
        }
    }

    "Network_access_Do_not_allow_anonymous_enumeration_of_SAM_accounts" = @{
        Value   = "MACHINE\System\CurrentControlSet\Control\Lsa\RestrictAnonymousSAM"
        Section = 'Registry Values'
        Option  = @{
            Enabled  = '4,1'
            Disabled = '4,0'
        }
    }

    "Network_access_Do_not_allow_anonymous_enumeration_of_SAM_accounts_and_shares" = @{
        Value   = "MACHINE\System\CurrentControlSet\Control\Lsa\RestrictAnonymous"
        Section = 'Registry Values'
        Option  = @{
            Enabled  = '4,1'
            Disabled = '4,0'
        }
    }

    "Network_access_Do_not_allow_storage_of_passwords_and_credentials_for_network_authentication" = @{
        Value   = "MACHINE\System\CurrentControlSet\Control\Lsa\DisableDomainCreds"
        Section = 'Registry Values'
        Option  = @{
            Enabled  = '4,1'
            Disabled = '4,0'
        }
    }

    "Network_access_Let_Everyone_permissions_apply_to_anonymous_users" = @{
        Value   = "MACHINE\System\CurrentControlSet\Control\Lsa\EveryoneIncludesAnonymous"
        Section = 'Registry Values'
        Option  = @{
            Enabled  = '4,1'
            Disabled = '4,0'
        }
    }

    "Network_access_Named_Pipes_that_can_be_accessed_anonymously" = @{
        Value   = "MACHINE\System\CurrentControlSet\Services\LanManServer\Parameters\NullSessionPipes"
        Section = 'Registry Values'
        Option  = @{
            String = '7,' # + accounts (Identities seperated by commas)
        }
    }

    "Network_access_Remotely_accessible_registry_paths" = @{
        Value   = "MACHINE\System\CurrentControlSet\Control\SecurePipeServers\Winreg\AllowedExactPaths\Machine"
        Section = 'Registry Values'
        Option  = @{
            String = '7,' # + accounts (Identities seperated by commas)
        }
    }

    "Network_access_Remotely_accessible_registry_paths_and_subpaths" = @{
        Value   = "MACHINE\System\CurrentControlSet\Control\SecurePipeServers\Winreg\AllowedPaths\Machine"
        Section = 'Registry Values'
        Option  = @{
            String = '7,' # + accounts (Identities seperated by commas)
        }
    }

    "Network_access_Restrict_anonymous_access_to_Named_Pipes_and_Shares" = @{
        Value   = "MACHINE\System\CurrentControlSet\Services\LanManServer\Parameters\RestrictNullSessAccess"
        Section = 'Registry Values'
        Option  = @{
            Enabled  = '4,1'
            Disabled = '4,0'
        }
    }

    "Network_access_Restrict_clients_allowed_to_make_remote_calls_to_SAM" = @{
        Value   = "MACHINE\System\CurrentControlSet\Control\Lsa\RestrictRemoteSAM"
        Section = 'Registry Values'
        Option  = @{
            String = '1,'
        }
    }

    "Network_access_Shares_that_can_be_accessed_anonymously" = @{
        Value   = "MACHINE\System\CurrentControlSet\Services\LanManServer\Parameters\NullSessionShares"
        Section = 'Registry Values'
        Option  = @{
            String = '7,' # + accounts (Identities seperated by commas)
        }
    }

    "Network_access_Sharing_and_security_model_for_local_accounts" = @{
        Value   = "MACHINE\System\CurrentControlSet\Control\Lsa\ForceGuest"
        Section = 'Registry Values'
        Option  = @{
            'Classic - Local users authenticate as themselves' = '4,0'
            'Guest only - Local users authenticate as Guest'   = '4,1'
        }
    }

    "Network_security_Allow_Local_System_to_use_computer_identity_for_NTLM" = @{
        Value   = "MACHINE\System\CurrentControlSet\Control\Lsa\UseMachineId"
        Section = 'Registry Values'
        Option  = @{
            Enabled  = '4,1'
            Disabled = '4,0'
        }
    }

    "Network_security_Allow_LocalSystem_NULL_session_fallback" = @{
        Value   = "MACHINE\System\CurrentControlSet\Control\Lsa\MSV1_0\allownullsessionfallback"
        Section = 'Registry Values'
        Option  = @{
            Enabled  = '4,1'
            Disabled = '4,0'
        }
    }

    "Network_Security_Allow_PKU2U_authentication_requests_to_this_computer_to_use_online_identities" = @{
        Value   = "MACHINE\System\CurrentControlSet\Control\Lsa\pku2u\AllowOnlineID"
        Section = 'Registry Values'
        Option  = @{
            Enabled  = '4,1'
            Disabled = '4,0'
        }
    }

    "Network_security_Configure_encryption_types_allowed_for_Kerberos" = @{
        Value   = "MACHINE\Software\Microsoft\Windows\CurrentVersion\Policies\System\Kerberos\Parameters\SupportedEncryptionTypes"
        Section = 'Registry Values'
        Option  = @{
            DES_CBC_CRC  = '4,1'
            DES_CBC_MD5  = '4,2'
            RC4_HMAC_MD5 = '4,4'
            AES128_HMAC_SHA1  = '4,8'
            AES256_HMAC_SHA1  = '4,16'
            FUTURE = '4,2147483616'
        }
    }

    "Network_security_Do_not_store_LAN_Manager_hash_value_on_next_password_change" = @{
        Value   = "MACHINE\System\CurrentControlSet\Control\Lsa\NoLMHash"
        Section = 'Registry Values'
        Option  = @{
            Enabled  = '4,1'
            Disabled = '4,0'
        }
    }

    "Network_security_Force_logoff_when_logon_hours_expire" = @{
        Value   = "ForceLogoffWhenHourExpire"
        Section = 'System Access'
        Option  = @{
            Enabled  = '1'
            Disabled = '0'
        }
    }

    "Network_security_LAN_Manager_authentication_level" = @{
        Value   = "MACHINE\System\CurrentControlSet\Control\Lsa\LmCompatibilityLevel"
        Section = 'Registry Values'
        Option  = @{
            'Send LM & NTLM responses' = '4,0'
            'Send LM & NTLM - use NTLMv2 session security if negotiated' = '4,1'
            'Send NTLM responses only' = '4,2'
            'Send NTLMv2 responses only' = '4,3'
            'Send NTLMv2 responses only. Refuse LM' = '4,4'
            'Send NTLMv2 responses only. Refuse LM & NTLM' = '4,5'
        }
    }

    "Network_security_LDAP_client_signing_requirements" = @{
        Value   = "MACHINE\System\CurrentControlSet\Services\LDAP\LDAPClientIntegrity"
        Section = 'Registry Values'
        Option  = @{
            'None'              = '4,0'
            'Negotiate Signing' = '4,1'
            'Require Signing'   = '4,2'
        }
    }

    "Network_security_Minimum_session_security_for_NTLM_SSP_based_including_secure_RPC_clients" = @{
        Value   = "MACHINE\System\CurrentControlSet\Control\Lsa\MSV1_0\NTLMMinClientSec"
        Section = 'Registry Values'
        Option  = @{
            'Require NTLMv2 session security' = '4,524288'
            'Require 128-bit encryption'      = '4,536870912'
            'Both options checked'            = '4,537395200'
        }
    }

    "Network_security_Minimum_session_security_for_NTLM_SSP_based_including_secure_RPC_servers" = @{
        Value   = "MACHINE\System\CurrentControlSet\Control\Lsa\MSV1_0\NTLMMinServerSec"
        Section = 'Registry Values'
        Option  = @{
            'Require NTLMv2 session security' = '4,524288'
            'Require 128-bit encryption'      = '4,536870912'
            'Both options checked'            = '4,537395200'
        }
    }

    "Network_security_Restrict_NTLM_Add_remote_server_exceptions_for_NTLM_authentication" = @{
        Value   = "MACHINE\System\CurrentControlSet\Control\Lsa\MSV1_0\ClientAllowedNTLMServers"
        Section = 'Registry Values'
        Option  = @{
            String = '7,'  # <Option>
        }
    }

    "Network_security_Restrict_NTLM_Add_server_exceptions_in_this_domain" = @{
        Value   = "MACHINE\System\CurrentControlSet\Services\Netlogon\Parameters\DCAllowedNTLMServers"
        Section = 'Registry Values'
        Option  = @{
            String = '7,' # <Options>
        }
    }

    "Network_Security_Restrict_NTLM_Audit_Incoming_NTLM_Traffic" = @{
        Value   = "MACHINE\System\CurrentControlSet\Control\Lsa\MSV1_0\AuditReceivingNTLMTraffic"
        Section = 'Registry Values'
        Option  = @{
            'Disabled' = '4,0'
            'Enable auditing for domain accounts' = '4,1'
            'Enable auditing for all accounts' = '4,2'
        }
    }

    "Network_Security_Restrict_NTLM_Audit_NTLM_authentication_in_this_domain" = @{
        Value   = "MACHINE\System\CurrentControlSet\Services\Netlogon\Parameters\AuditNTLMInDomain"
        Section = 'Registry Values'
        Option  = @{
            'Disable' = '4,0'
            'Enable for domain accounts to domain servers' = '4,1'
            'Enable for domain accounts' = '4,3'
            'Enable for domain servers' = '4,5'
            'Enable all' = '4,7'
        }
    }

    "Network_Security_Restrict_NTLM_Incoming_NTLM_Traffic" = @{
        Value   = "MACHINE\System\CurrentControlSet\Control\Lsa\MSV1_0\RestrictReceivingNTLMTraffic"
        Section = 'Registry Values'
        Option  = @{
            'Allow all' = '4,0'
            'Deny all domain accounts' = '4,1'
            'Deny all accounts' = '4,2'
        }
    }

    "Network_Security_Restrict_NTLM_NTLM_authentication_in_this_domain" = @{
        Value   = "MACHINE\System\CurrentControlSet\Services\Netlogon\Parameters\RestrictNTLMInDomain"
        Section = 'Registry Values'
        Option  = @{
            'Disable' = '4,0'
            'Deny for domain accounts to domain servers' = '4,1'
            'Deny for domain accounts' = '4,3'
            'Deny for domain servers' = '4,5'
            'Deny all' = '4,7'
        }
    }

    "Network_Security_Restrict_NTLM_Outgoing_NTLM_traffic_to_remote_servers" = @{
        Value   = "MACHINE\System\CurrentControlSet\Control\Lsa\MSV1_0\RestrictSendingNTLMTraffic"
        Section = 'Registry Values'
        Option  = @{
            'Allow all' = '4,0'
            'Audit all' = '4,1'
            'Deny all'  = '4,2'
        }
    }

    "Recovery_console_Allow_automatic_administrative_logon" = @{
        Value   = "MACHINE\Software\Microsoft\Windows NT\CurrentVersion\Setup\RecoveryConsole\SecurityLevel"
        Section = 'Registry Values'
        Option  = @{
            Enabled = '4,1'
            Disabled = '4,0'
        }
    }

    "Recovery_console_Allow_floppy_copy_and_access_to_all_drives_and_folders" = @{
        Value   = "MACHINE\Software\Microsoft\Windows NT\CurrentVersion\Setup\RecoveryConsole\SetCommand"
        Section = 'Registry Values'
        Option  = @{
            Enabled  = '4,1'
            Disabled = '4,0'
        }
    }

    "Shutdown_Allow_system_to_be_shut_down_without_having_to_log_on" = @{
        Value   = "MACHINE\Software\Microsoft\Windows\CurrentVersion\Policies\System\ShutdownWithoutLogon"
        Section = 'Registry Values'
        Option  = @{
            Enabled  = '4,1'
            Disabled = '4,0'
        }
    }

    "Shutdown_Clear_virtual_memory_pagefile" = @{
        Value   = "MACHINE\System\CurrentControlSet\Control\Session Manager\Memory Management\ClearPageFileAtShutdown"
        Section = 'Registry Values'
        Option  = @{
            Enabled  = '4,1'
            Disabled = '4,0'
        }
    }

    "System_cryptography_Force_strong_key_protection_for_user_keys_stored_on_the_computer" = @{
        Value   = "MACHINE\Software\Policies\Microsoft\Cryptography\ForceKeyProtection"
        Section = 'Registry Values'
        Option  = @{
            'User input is not required when new keys are stored and used' = '4,0'
            'User is prompted when the key is first used' = '4,1'
            'User must enter a password each time they use a key' = '4,2'
        }
    }

    "System_cryptography_Use_FIPS_compliant_algorithms_for_encryption_hashing_and_signing" = @{
        Value   = "MACHINE\System\CurrentControlSet\Control\Lsa\FIPSAlgorithmPolicy\Enabled"
        Section = 'Registry Values'
        Option  = @{
            Enabled  = '4,1'
            Disabled = '4,0'
        }
    }

    "System_objects_Require_case_insensitivity_for_non_Windows_subsystems" = @{
        Value   = "MACHINE\System\CurrentControlSet\Control\Session Manager\Kernel\ObCaseInsensitive"
        Section = 'Registry Values'
        Option  = @{
            Enabled  = '4,1'
            Disabled = '4,0'
        }
    }

    "System_objects_Strengthen_default_permissions_of_internal_system_objects_eg_Symbolic_Links" = @{
        Value   = "MACHINE\System\CurrentControlSet\Control\Session Manager\ProtectionMode"
        Section = 'Registry Values'
        Option  = @{
            Enabled  = '4,1'
            Disabled = '4,0'
        }
    }

    "System_settings_Optional_subsystems" = @{
        Value   = "MACHINE\System\CurrentControlSet\Control\Session Manager\SubSystems\optional"
        Section = 'Registry Values'
        Option  = @{
            String = '7,' # + Posix
        }
    }

    "System_settings_Use_Certificate_Rules_on_Windows_Executables_for_Software_Restriction_Policies" = @{
        Value   = "MACHINE\Software\Policies\Microsoft\Windows\Safer\CodeIdentifiers\AuthenticodeEnabled"
        Section = 'Registry Values'
        Option  = @{
            Enabled  = '4,1'
            Disabled = '4,0'
        }
    }

    "User_Account_Control_Admin_Approval_Mode_for_the_Built_in_Administrator_account" = @{
        Value   = "MACHINE\Software\Microsoft\Windows\CurrentVersion\Policies\System\FilterAdministratorToken"
        Section = 'Registry Values'
        Option  = @{
            Enabled  = '4,1'
            Disabled = '4,0'
        }
    }

    "User_Account_Control_Allow_UIAccess_applications_to_prompt_for_elevation_without_using_the_secure_desktop" = @{
        Value   = "MACHINE\Software\Microsoft\Windows\CurrentVersion\Policies\System\EnableUIADesktopToggle"
        Section = 'Registry Values'
        Option  = @{
            Enabled  = '4,1'
            Disabled = '4,0'
        }
    }

    "User_Account_Control_Behavior_of_the_elevation_prompt_for_administrators_in_Admin_Approval_Mode" = @{
        Value   = "MACHINE\Software\Microsoft\Windows\CurrentVersion\Policies\System\ConsentPromptBehaviorAdmin"
        Section = 'Registry Values'
        Option  = @{
            'Elevate without prompting' = '4,0'
            'Prompt for credentials on the secure desktop' = '4,1'
            'Prompt for consent on the secure desktop' = '4,2'
            'Prompt for credentials' = '4,3'
            'Prompt for consent' = '4,4'
            'Prompt for consent for non-Windows binaries' = '4,5'
        }
    }

    "User_Account_Control_Behavior_of_the_elevation_prompt_for_standard_users" = @{
        Value   = "MACHINE\Software\Microsoft\Windows\CurrentVersion\Policies\System\ConsentPromptBehaviorUser"
        Section = 'Registry Values'
        Option  = @{
            'Automatically deny elevation request' = '4,0'
            'Prompt for credentials on the secure desktop' = '4,1'
            'Prompt for credentials' = '4,3'
        }
    }

    "User_Account_Control_Detect_application_installations_and_prompt_for_elevation" = @{
        Value   = "MACHINE\Software\Microsoft\Windows\CurrentVersion\Policies\System\EnableInstallerDetection"
        Section = 'Registry Values'
        Option  = @{
            Enabled  = '4,1'
            Disabled = '4,0'
        }
    }

    "User_Account_Control_Only_elevate_executables_that_are_signed_and_validated" = @{
        Value   = "MACHINE\Software\Microsoft\Windows\CurrentVersion\Policies\System\ValidateAdminCodeSignatures"
        Section = 'Registry Values'
        Option  = @{
            Enabled  = '4,1'
            Disabled = '4,0'
        }
    }

    "User_Account_Control_Only_elevate_UIAccess_applications_that_are_installed_in_secure_locations" = @{
        Value   = "MACHINE\Software\Microsoft\Windows\CurrentVersion\Policies\System\EnableSecureUIAPaths"
        Section = 'Registry Values'
        Option  = @{
            Enabled  = '4,1'
            Disabled = '4,0'
        }
    }

    "User_Account_Control_Run_all_administrators_in_Admin_Approval_Mode" = @{
        Value   = "MACHINE\Software\Microsoft\Windows\CurrentVersion\Policies\System\EnableLUA"
        Section = 'Registry Values'
        Option  = @{
            Enabled  = '4,1'
            Disabled = '4,0'
        }
    }

    "User_Account_Control_Switch_to_the_secure_desktop_when_prompting_for_elevation" = @{
        Value   = "MACHINE\Software\Microsoft\Windows\CurrentVersion\Policies\System\PromptOnSecureDesktop"
        Section = 'Registry Values'
        Option  = @{
            Enabled  = '4,1'
            Disabled = '4,0'
        }
    }

    "User_Account_Control_Virtualize_file_and_registry_write_failures_to_per_user_locations" = @{
        Value   = "MACHINE\Software\Microsoft\Windows\CurrentVersion\Policies\System\EnableVirtualization"
        Section = 'Registry Values'
        Option  = @{
            Enabled  = '4,1'
            Disabled = '4,0'
        }
    }
}