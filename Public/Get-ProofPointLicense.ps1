Function Get-ProofPointLicense {
    <#
    .SYNOPSIS
    List license details for one or more customers

    .PARAMETER Name
    Part or all of a client name fuzzy matched with wildcard *

    .PARAMETER Domain
    One or more client's exact primary domain

    .EXAMPLE
    Get-ProofPointLicense -Name Bank

    .EXAMPLE
    Get-ProofPointLicense -Domain domain.com

    .EXAMPLE
    'domain.com','differentdomain.com' | Get-ProofPointLicense
    #>

    [cmdletbinding(DefaultParameterSetName='All')]
    Param(
        [parameter(Position=0,ParameterSetName='Name')]
        [string]$Name,

        [parameter(Position=0,ParameterSetName='Domain',ValueFromPipeline,ValueFromPipelineByPropertyName)]
        [Alias('primary_domain','PrimaryDomain')]
        [string]$Domain = $script:ppconfig.organization
    )

    begin{
        $organizationlist = Get-ProofPointOrganization
    }
    
    process{
        $display,$filter = switch -Exact ($PSCmdlet.ParameterSetName){
            Name {
                $Name
                {$_.name -like "*$Name*"}
            }
            Domain  {
                $Domain
                {$_.primarydomain -eq $Domain}
            }
            All  {
                "All"
                {$_.Name -like "*"}
            }
        }

        Write-Verbose "Retrieving domain list for $display"

        $organizationlist | Where-Object $filter | ForEach-Object {[ProofPointLicense]::new($_)}
    }
}