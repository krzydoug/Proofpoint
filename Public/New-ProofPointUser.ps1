Function New-ProofPointUser {
    <#
    .SYNOPSIS
    List organization details for one or more customers

    .PARAMETER Email
    Email of account to take action on

    .PARAMETER FirstName

    .PARAMETER LastName

    .PARAMETER Type
    The type of account from this list

        oem_partner_admin
        strategic_partner_admin
        channel_admin
        organization_admin
        end_user
        silent_user
        functional_account

    .PARAMETER Active
    Designates if the account is active or not

    .PARAMETER WelcomeEmail
    Sends a welcome email to the account
    If true, a welcome email will be sent on user creation.
    (NOTE: To send a welcome email this must be true at org level. This can optionally be overridden to false at a per user level)
    
    .PARAMETER Alias
    List of alias emails for the account

    .PARAMETER SafeSenders
    Whitelist of email addresses or domains. Can include wildcard *

    .PARAMETER BlockedSenders
    Blacklist of email addresses or domains. Can include wildcard *

    .PARAMETER Billable
    default: true
    Is the user a billable user? (NOTE: Only one user per org can be non-billable)

    .PARAMETER OdinSettings
    can_impersonate	boolean
    default: false
    can the user impersonate users from child Organizations

    is_imitable	boolean
    default: false
    can the user be authenticated with an Odin token

    .PARAMETER ReadOnly
    Set the account to read-only

    .PARAMETER Password
    Password to set on the account. Not required for functional_accounts

    .EXAMPLE
    $Password = Read-Host -AsSecureString
    New-ProofPointUser -Email 'someemail@domain.com' -Firstname "John" -Password $Password

    .EXAMPLE
    New-ProofPointUser -Email 'someemail@domain.com' -Firstname "Some name" -Type functional_account -Confirm:$false

    .EXAMPLE
    $userparams = @{
        Email     = 'someemail@domain.com'
        Firstname = 'John'
        LastName  = 'Doe'
        Type      = 'end_user'
        Password  = Read-Host -AsSecureString
    }
    
    New-ProofPointUser @userparams
    #>

    [cmdletbinding(SupportsShouldProcess,ConfirmImpact='High')]
    Param(
        [parameter(Mandatory,Position = 0,HelpMessage = "Enter the user's email",ValueFromPipeline,ValueFromPipelineByPropertyName)]
        [Alias('PrimaryEmail','primary_email')]
        [string]$Email,

        [parameter(HelpMessage = "Enter the user's first name",ValueFromPipelineByPropertyName)]
        [string]$FirstName,

        [parameter(HelpMessage = "Enter the user's last name",ValueFromPipelineByPropertyName)]
        [Alias('Surname')]
        [string]$LastName,

        [parameter(HelpMessage = "Enter the account type",ValueFromPipelineByPropertyName)]
        [ValidateSet('oem_partner_admin','strategic_partner_admin','channel_admin','organization_admin','end_user','silent_user','functional_account')]
        [string]$Type = 'end_user',

        [parameter(HelpMessage = "Mark account active or not")]
        [bool]$Active = $true,

        [parameter(HelpMessage = "Use to send welcome email to new account")]
        [switch]$WelcomeEmail,

        [parameter(HelpMessage = "Alias email address(es)")]
        [array]$Alias,

        [parameter(HelpMessage = "Safe sender list")]
        [array]$SafeSenders,

        [parameter(HelpMessage = "Blocked sender list")]
        [array]$BlockedSenders,

        [parameter(HelpMessage = "Mark account billable or not")]
        [bool]$Billable = $true,

        [parameter(HelpMessage = "Two bool options can_impersonate and is_imitable which are both false by default")]
        [hashtable]$OdinSettings,

        [parameter(HelpMessage = "Set account to read-only")]
        [switch]$ReadOnly,

        [parameter(HelpMessage = "New account password as secure string")]
        [securestring]$Password
    )

    begin{
        if(!$PSDefaultParameterValues['*:Headers']){
            Get-ProofPointCredential
        }
    }

    process{

        if($email -match '^[^@]+@[^@]+\.[^@]+'){
            $domain = $Email -replace '^.+@'
        }
        else{
            Write-Warning "Enter a valid email address"
            continue
        }

        Write-Verbose "Checking for organization with domain $domain"

        if(Get-ProofPointOrganization -Domain $domain){
            Write-Verbose "Checking if user $Email already exists"

            if(Get-ProofPointUser -Email $Email){
                Write-Warning "User $Email already exists in $domain"
                continue
            }
        }
        else{
            Write-Warning "No organization with domain $domain could be found"
            continue
        }

        if(!$PSCmdlet.ShouldProcess("Create new ProofPoint $type $($Email)?",'','')){
            continue
        }

        Write-Verbose "Creating new user $Email"

        $ht = @{}

        foreach($key in $PSBoundParameters.Keys){
            if($script:propertymap.Keys -contains $key){
                $ht.Add($script:propertymap[$key],$PSBoundParameters[$key])
            }
        }

        $body = $ht | ConvertTo-Json

        $params = @{
            Uri         = $script:ppconfig.endpoint + "orgs/" + $domain + "/users/"
            Body        = $body
            Method      = 'Post'
            ErrorAction = 'Stop'
        }

        $script:ppconfig.lastresult = try{
            $script:ppconfig.TotalRequests++
            $response = Invoke-WebRequest @params
            $response.statuscode
        }
        catch{
            Write-Warning "Error querying $($params.uri)"
            Write-Warning $_.exception.message
            Write-Warning $_.Exception.Response.StatusCode.value__
            $response.statuscode
        }
    
        if($script:ppconfig.lastresult -eq 201){
            Write-Verbose "User $email was created successfully"
            Get-ProofPointUser -Email $Email

            if($Password -and $Type -notin 'functional_acount','silent_user'){
                Set-ProofPointUser -Email $Email -Password $Password -confirm:$false
            }
            else{
                Write-Warning "No password has been set for $Email. Use Set-ProofPointUser to set the password"
            }
        }
    }
}