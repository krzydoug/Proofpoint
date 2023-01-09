Function Set-ProofPointUser {
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
    Set-ProofPointUser -Email 'someemail@domain.com' -Password $Password

    .EXAMPLE
    Set-ProofPointUser -Email 'someemail@domain.com' -Firstname "Some name" -Type functional_account -Confirm:$false

    .EXAMPLE
    $userparams = @{
        Email     = 'someemail@domain.com'
        LastName  = 'Just-Married'
        Password  = Read-Host "Enter the password" -AsSecureString
    }
    
    Set-ProofPointUser @userparams
    #>

    [cmdletbinding(SupportsShouldProcess,ConfirmImpact='High')]
    Param(
        [parameter(Mandatory,Position = 0,HelpMessage = "Enter the user's email",ValueFromPipelineByPropertyName)]
        [Alias('PrimaryEmail','primary_email')]
        [string]$Email,

        [parameter(HelpMessage = "Enter the user's first name",ValueFromPipelineByPropertyName)]
        [string]$FirstName,

        [parameter(HelpMessage = "Enter the user's last name",ValueFromPipelineByPropertyName)]
        [Alias('Surname')]
        [string]$LastName,

        [parameter(HelpMessage = "Enter the account type",ValueFromPipelineByPropertyName)]
        [ValidateSet('oem_partner_admin','strategic_partner_admin','channel_admin','organization_admin','end_user','silent_user','functional_account')]
        [string]$Type,

        [parameter(HelpMessage = "Mark account active or not")]
        [bool]$Active = $true,

        [parameter(HelpMessage = "Send welcome email")]
        [switch]$WelcomeEmail,

        [parameter(HelpMessage = "Alias email address(es)")]
        [array]$Alias,

        [parameter(HelpMessage = "Safe senders list")]
        [array]$SafeSenders,

        [parameter(HelpMessage = "Blocked senders list")]
        [array]$BlockedSenders,

        [parameter(HelpMessage = "Mark account billable or not")]
        [bool]$Billable = $true,

        [parameter(HelpMessage = "Two bool options can_impersonate and is_imitable")]
        [hashtable]$OdinSettings,

        [parameter(HelpMessage = "Set account to read-only")]
        [switch]$ReadOnly,

        [parameter(HelpMessage = "New password as secure string")]
        [securestring]$Password
    )

    begin{
        if(!$PSDefaultParameterValues['*:Headers']){
            Get-ProofPointCredential
        }
    }

    process{
        $user = Get-ProofPointUser -Email $Email

        if(!$user){
            Write-Warning "No user found matching $Email"
            continue
        }

        if(!$PSCmdlet.ShouldProcess($Email)){
            continue
        }

        Write-Verbose "Setting properties on $Email"

        $ht = @{}
        
        foreach($property in $user.psobject.Properties | Where-Object {$_.Value -and $_.name -ne 'Organization'}){
            $key = if($script:propertymap.Keys -contains $property.name){
                $script:propertymap[$property.name]
            }
            else{
                $property.name.ToLower()
            }

            $ht.Add($key,$property.Value)
        }  

        foreach($boundkey in $PSBoundParameters.Keys | Where-Object {$_ -notin 'password','Confirm','Verbose'}){

            $key = if($script:propertymap.Keys -contains $boundkey){
                $script:propertymap[$boundkey]
            }
            else{
                $boundkey
            }

            $ht[$key] = $PSBoundParameters[$boundkey]
        }

        if($Password){
            $ht.password = [pscredential]::new('dummy',$Password).GetNetworkCredential().Password
        }

        $body = $ht | ConvertTo-Json

        $params = @{
            Uri         = $script:ppconfig.endpoint + "orgs/" + $user.Organization + "/users/" + $Email
            Body        = $body
            Method      = 'Put'
            ErrorAction = 'Stop'
        }

        $script:ppconfig.lastresult = try{
            $script:ppconfig.TotalRequests++
            $response = Invoke-WebRequest @params
            $response.statuscode
        }
        catch{
            Write-Warning "Error setting properties on $Email"
            Write-Warning $_.exception.message
            Write-Warning $_.Exception.Response.StatusCode.value__
            $response.statuscode
        }

        if($response.statuscode -eq '204'){
            Write-Verbose "Account $Email updated successfully"
        }
    }
}

<#
if($Password){
    Write-Verbose "Setting password on user $Email"
    $params.Method = 'Put'
    $params.body = @{'}
    $script:ppconfig.lastresult = try{
        $script:ppconfig.TotalRequests++
        $response = Invoke-WebRequest @params
        $response.statuscode
    }
    catch{
        Write-Warning "Error setting password $Email"
        Write-Warning $_.exception.message
        Write-Warning $_.Exception.Response.StatusCode.value__
        $response.statuscode
    }
}
#>