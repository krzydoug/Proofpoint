Function Get-ProofPointDomain {
    <#
    .SYNOPSIS
    List domain details for one or more organizations.

    .DESCRIPTION
    List domain details for one or more organizations.
    Return domain(s) details for all organizations if no parameters used.

    .PARAMETER Name
    Part or all of a client name fuzzy matched with wildcard *

    .PARAMETER Domain
    One or more client domain.

    .EXAMPLE
    Get-ProofPointDomain

    .EXAMPLE
    Get-ProofPointOrganization | Get-ProofPointDomain

    .EXAMPLE
    'domain.com','differentdomain.com' | Get-ProofPointDomain
    #>

    [cmdletbinding(DefaultParameterSetName='All')]
    Param(
        [parameter(Position=0,ParameterSetName='Name')]
        [string]$Name,

        [parameter(Position=0,ParameterSetName='Domain',ValueFromPipeline,ValueFromPipelineByPropertyName)]
        [Alias('primary_domain','PrimaryDomain')]
        [string]$Domain
    )

    begin{
        if(!$PSDefaultParameterValues['*:Headers']){
            Get-ProofPointCredential
        }

        $organizationlist = Get-ProofPointOrganization
    }

    process{
        $display,$wherefilter = switch -Exact ($PSCmdlet.ParameterSetName){
            Name {
                $Name
                {$_.name -like "*$Name*"}
            }
            Domain  {
                $Domain
                {$_.primarydomain -eq $Domain}
            }
            All  {
                "All organizations"
                {$_.name -like "*"}
            }
        }

        Write-Verbose "Retrieving domain list for $display"

        foreach($organization in $organizationlist | Where-Object $wherefilter){

            $params = @{
                Uri = $script:ppconfig.endpoint + "orgs/" + $organization.primarydomain + "/domains/"
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
            
            $response.domains | ForEach-Object {[ProofPointDomain]::New($_)}
            
        }
    }

}