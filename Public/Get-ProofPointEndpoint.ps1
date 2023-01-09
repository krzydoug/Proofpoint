Function Get-ProofPointEndpoint {
    <#
    .SYNOPSIS
    List license details for one or more customers

    .PARAMETER Domain
    One or more client's exact primary domain. Return endpoint list for default organization if omitted.

    .EXAMPLE
    Get-ProofPointEndpoint

    .EXAMPLE
    Get-ProofPointDomain | Get-ProofPointEndpoint

    .EXAMPLE
    'domain.com','differentdomain.com' | Get-ProofPointEndpoint
    #>

    [cmdletbinding()]
    Param(
        [parameter(Position=0,ValueFromPipeline,ValueFromPipelineByPropertyName)]
        [string]$Domain = $script:ppconfig.organization
    )

    begin{
        if(!$PSDefaultParameterValues['*:Headers']){
            Get-ProofPointCredential
        }
    }

    process{
        Write-Verbose "Retrieving Proofpoint endpoint list for $Domain"

        $params = @{
            Uri = $script:ppconfig.endpoint + "endpoints/" + $Domain
            ErrorAction = 'Stop'
        }

        $script:ppconfig.lastresult = try{
            $script:ppconfig.TotalRequests++
            $response = Invoke-RestMethod @params
            200
        }
        catch{
            Write-Warning "Error querying $($params.uri)"
            Write-Warning $_.Exception.Message
            Write-Warning $_.Exception.Response.StatusCode.value__ 
        }

        if($response.endpoints){
            return $response.endpoints
        }
    }
}