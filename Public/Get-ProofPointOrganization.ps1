Function Get-ProofPointOrganization {
    <#
    .SYNOPSIS
    List organization details for one or more customers

    .PARAMETER Name
    Part or all of a client name fuzzy matched with wildcard *

    .PARAMETER Domain
    One or more of a client's domain

    .EXAMPLE
    Get-ProofPointOrganization -Name "Bank of"

    .EXAMPLE
    Get-ProofPointOrganization -Domain domain.com

    .EXAMPLE
    'domain.com','differentdomain.com' | Get-ProofPointOrganization
    #>

    [cmdletbinding(DefaultParameterSetName='All')]
    Param(
        [parameter(ParameterSetName='Name')]
        [string]$Name,

        [parameter(Position=0,ParameterSetName='Domain',ValueFromPipeline,ValueFromPipelineByPropertyName)]
        [Alias('primary_domain','PrimaryDomain')]
        [string]$Domain
    )

    begin{
        if(!$PSDefaultParameterValues['*:Headers']){
            Get-ProofPointCredential
        }
    }
    
    process{

        $message,$suburl = if($Domain){
            "Retrieving organization $Domain"
            $Domain
        }
        else{
            "Retrieving all organizations"
            $script:ppconfig.organization + "/orgs"
        }

        Write-Verbose $message

        $params = @{
            Uri = $script:ppconfig.endpoint + "orgs/" + $suburl
            ErrorAction = 'Stop'
        }

        $script:ppconfig.lastresult = try{
            $script:ppconfig.TotalRequests++
            $response = Invoke-RestMethod @params
            $response.StatusCode
        }
        catch{
            Write-Warning "Error querying $($params.uri)"
            Write-Warning $_.Exception.Message
            Write-Warning $_.Exception.Response.StatusCode.value__ 
        }

        $customerlist = switch -Exact ($PSCmdlet.ParameterSetName){
            Name {
                Write-Verbose "Searching organization list for $Name"
                $response.orgs | Where-Object {$_.name -match [regex]::Escape($Name)}
            }
            Domain {$response}
            All {$response.orgs}
        }

        foreach($customer in $customerlist){
            [ProofPointOrganization]::New($customer)
        }
    }
}