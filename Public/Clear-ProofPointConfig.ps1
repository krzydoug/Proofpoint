Function Clear-ProofPointConfig {
    <#
    .SYNOPSIS
    Set the session settings for proofpoint endpoint and/or credential

    .PARAMETER Endpoint
    Clear the endpoint entry

    .PARAMETER Credential
    Credentials to use for the proofpoint commands

    .PARAMETER All
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

    [cmdletbinding(DefaultParameterSetName='All')]
    Param(
        [switch]$Endpoint,

        [Alias('UserName','Password')]
        [switch]$Credential,

        [switch]$All,

        [switch]$Passthru
    )

    if($All){
        Write-Verbose "Clearing Proofpoint configuration"
        $script:ppconfig.TotalRequests = 0
        $script:ppconfig.LastResult = 0
        $Credential = $true
        $Endpoint = $true
    }

    if($Endpoint){
        $script:ppconfig.Endpoint = $null
    }
    
    if($Credential){
        $script:ppconfig.Credential = $null

        $script:headers = @{
            'X-User' = $null
            'X-Password' = $null
            'X-Terms-Update' = $true
        }

        $script:ppconfig = [PSCustomObject]@{
            Organization  = "bethegeek.com"
            Endpoint      = 'https://us2.proofpointessentials.com/api/v1/'
            TotalRequests = 0
            LastResult    = 0
            Credential    = ''
        }

        $PSDefaultParameterValues['*:Headers'] = $script:headers
    }

    if($Passthru){
        return Get-ProofPointConfig
    }
    
}