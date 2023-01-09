class ProofPointUser {
    [string]$Organization
    [string]$FirstName
    [string]$LastName
    [String]$Email
    [string]$Type
    [bool]$Active
    [bool]$Billable
    [int]$UserID
    [array]$Alias
    [array]$SafeSenders
    [array]$BlockedSenders
    [bool]$ReadOnly

    ProofpointUser (){}

    ProofpointUser ([string]$Organization, $User){
        $this.Organization   = $Organization
        $this.FirstName      = $user.firstname
        $this.LastName       = $user.surname
        $this.UserID         = $user.uid
        $this.Email          = $user.primary_email
        $this.Active         = $user.is_active
        $this.Billable       = $user.is_billable
        $this.Type           = $user.type
        $this.Alias          = $user.alias_emails
        $this.SafeSenders    = $user.safe_list_senders
        $this.BlockedSenders = $user.block_list_senders
        $this.ReadOnly       = $user.read_only_user
    }

    [string] ToString() {
        return "$($this.FirstName) $($this.LastName) ($($this.Email))"
    }
}

class ProofPointDomain {
    [string]$Name
    [string]$Organization
    [bool]$Active
    [bool]$Relay
    [string]$Destination
    [array]$Failovers

    ProofPointDomain (){}

    ProofPointDomain ($Domain){
        $this.Name         = $Domain.name
        $this.Organization = $Domain.Organization
        $this.Active       = $Domain.is_active
        $this.Relay        = $Domain.is_relay
        $this.Destination  = $Domain.destination
        $this.Failovers    = $Domain.failovers
    }

    [string] ToString() {
        return $this.Name
    }
}

class ProofPointOrganization {
    [string]$Name
    [string]$PrimaryDomain
    [string]$Hierarchy
    [int]$Eid
    [String]$LicensePackage
    [string]$Type
    [bool]$Active
    [bool]$Trial
    [int]$UserLicenses
    [int]$ActiveUsers
    [datetime]$RenewalDate
    [bool]$BeginnerPlus
    [bool]$BeginnerPlusEnabled
    [string]$Website
    [string]$Address
    [string]$ZipCode
    [string]$State
    [string]$Country
    [string]$Phone
    [array]$AdminList
    [array]$DomainList
    [array]$OutgoingServers
    [string]$LDAPURL
    [string]$LDAPUser
    [string]$LDAPBaseDN
    [array]$SafeSenders
    [array]$BlockedSenders
    [bool]$SmtpDiscoveryEnabled
    [int]$AccountTemplateId
    [bool]$SendWelcomeMail
    [array]$OdinCapabilities

    ProofPointOrganization (){}

    ProofPointOrganization ($Organization){
        $this.Name                 = $Organization.Name
        $this.PrimaryDomain        = $Organization.primary_domain
        $this.Hierarchy            = $Organization.organization_hierarchy
        $this.Eid                  = $Organization.eid
        $this.LicensePackage       = [cultureinfo]::CurrentCulture.TextInfo.ToTitleCase($Organization.licensing_package)
        $this.Active               = $Organization.is_active
        $this.Trial                = $Organization.is_on_trial
        $this.Type                 = $Organization.type
        $this.UserLicenses         = $Organization.user_licenses
        $this.ActiveUsers          = $Organization.active_users
        $this.RenewalDate          = $Organization.when_renewal
        $this.BeginnerPlus         = $Organization.is_beginner_plus
        $this.BeginnerPlusEnabled  = $Organization.is_beginner_plus_enabled
        $this.Website              = $Organization.www
        $this.Address              = $Organization.address
        $this.ZipCode              = $Organization.postcode
        $this.State                = $Organization.stateprov
        $this.Country              = $Organization.country
        $this.Phone                = $Organization.phone
        $this.AdminList            = $Organization.admin_user | ForEach-Object {[ProofPointUser]::New($Organization.Name,$_)}
        $this.DomainList           = $Organization.domains | ForEach-Object {[ProofPointDomain]::New($_)}
        $this.OutgoingServers      = $Organization.outgoing_servers
        $this.SafeSenders          = $Organization.safe_list_senders
        $this.BlockedSenders       = $Organization.block_list_senders
        $this.LDAPURL              = $Organization.ldap_url
        $this.LDAPUser             = $Organization.ldap_username
        $this.LDAPBaseDN           = $Organization.ldap_basedn
        $this.SmtpDiscoveryEnabled = $Organization.is_smtp_discovery_enabled
        $this.AccountTemplateId    = $Organization.account_template_id
        $this.SendWelcomeMail      = $Organization.send_welcome_email
        $this.OdinCapabilities     = $Organization.odin_capabilities
    }

    [string] ToString() {
        return $this.PrimaryDomain
    }
}

class ProofPointLicense {
    [string]$Name
    [string]$PrimaryDomain
    [String]$LicensePackage
    [bool]$Trial
    [int]$UserLicenses
    [int]$ActiveUsers
    [datetime]$RenewalDate

    ProofPointLicense (){}

    ProofPointLicense ($License){
        $this.Name                 = $License.Name
        $this.PrimaryDomain        = $License.PrimaryDomain
        $this.LicensePackage       = $License.LicensePackage
        $this.Trial                = $License.Trial
        $this.UserLicenses         = $License.UserLicenses
        $this.ActiveUsers          = $License.ActiveUsers
        $this.RenewalDate          = $License.RenewalDate
    }

    [string] ToString() {
        return $this.LicensePackage
    }
}

