Function Set-ProofPointConfig {
    <#
    .SYNOPSIS
    Set the session settings for proofpoint endpoint and/or credential

    .PARAMETER Endpoint
    The endpoint to target for running commands against

    .PARAMETER Credential
    Credentials to use for the proofpoint commands

    .PARAMETER Passthru
    Show the config after setting it

    .EXAMPLE
    $credential = Get-Credential -Message "Enter your proofpoint credentials" -UserName user@email.com

    Set-ProofPointConfig -Credential $credential

    .EXAMPLE
    $credential = Get-Credential -Message "Enter your proofpoint credentials" -UserName user@email.com

    Set-ProofPointConfig -Credential $credential -Endpoint https://us2.proofpointessentials.com/api/v1/

    .EXAMPLE
    'domain.com','differentdomain.com' | Get-ProofPointLicense
    #>

    [cmdletbinding()]
    Param(
        [parameter(Mandatory,HelpMessage="Choose your proofpoint region: US1, US2, US3, US4, US5, EU1")]
        [validateset('US1', 'US2', 'US3', 'US4', 'US5', 'EU1')]
        [string]$Endpoint,

        [parameter(HelpMessage="Enter the organizations primary domain")]
        [Alias('PrimaryDomain')]
        [string]$Organization,

        [parameter(HelpMessage="Enter your proofpoint credentials")]
        [Alias('UserName','Password')]
        [pscredential]$Credential,

        [switch]$Passthru
    )
    
    Write-Verbose "Updating Proofpoint configuration"

    $script:propertymap = @{
        FirstName      = 'firstname'
        LastName       = 'surname'
        UserID         = 'uid'
        Email          = 'primary_email'
        Active         = 'is_active'
        Type           = 'type'
        Alias          = 'alias_emails'
        SafeSenders    = 'safe_list_senders'
        BlockedSenders = 'block_list_senders'
        ReadOnly       = 'read_only_user'
        WelcomeEmail   = 'send_welcome_email'
        Billable       = 'is_billable'
        OdinSettings   = 'odin_settings'
    }

    if($Endpoint){
        $script:ppconfig.Endpoint = $script:baseuri -f $Endpoint
    }

    if($Organization){
        $script:ppconfig.Organization = $Organization
    }

    if($Credential){
        $script:ppconfig.Credential = $Credential
        $script:headers = @{
            'X-User' = $Credential.UserName
            'X-Password' = $Credential.GetNetworkCredential().Password
            'X-Terms-Update' = $true
        }
        $PSDefaultParameterValues['*:Headers'] = $script:headers
    }

    if($Passthru){
        return Get-ProofPointConfig
    }
    
}