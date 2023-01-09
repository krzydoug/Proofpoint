Function Get-ProofPointUser {
    [cmdletbinding(DefaultParameterSetName='Organization')]
    Param(
        [parameter(Position = 0,HelpMessage = "Enter the organization primary domain",ParameterSetName='Organization')]
        [parameter(Position = 1,HelpMessage = "Enter the organization primary domain",ParameterSetName='Name')]
        [Alias('Domain','primary_domain','PrimaryDomain')]
        [string]$Organization,

        [parameter(Mandatory,Position = 0,HelpMessage = "Enter a user's name",ParameterSetName='Name')]
        [string]$Name,

        [parameter(Mandatory,Position = 0,HelpMessage = "Enter a user's email",ParameterSetName='Email',ValueFromPipeline,ValueFromPipelineByPropertyName)]
        [Alias('primary_email')]
        [string]$Email,

        [parameter()]
        [ValidateSet('oem_partner_admin','strategic_partner_admin','channel_admin','organization_admin','end_user','silent_user','functional_account')]
        [string[]]$Type = ('oem_partner_admin','strategic_partner_admin','channel_admin','organization_admin','end_user','silent_user','functional_account')
    )

    begin{
        if(!$PSDefaultParameterValues['*:Headers']){
            Get-ProofPointCredential
        }

        $OrgLookup = if($Organization){
            $current = Get-ProofPointOrganization -Domain $Organization

            if(!$current){
                Write-Warning "No organization found with domain $organization"
                break
            }
            $current
        }
        else{
            Get-ProofPointOrganization
        }

    }

    process{

        switch -Exact ($PSCmdlet.ParameterSetName){

            Name {
                Write-Verbose "Searching user list for $name"

                $params = @{
                    ErrorAction = 'Stop'
                }

                $OrgLookup.PrimaryDomain | ForEach-Object {
                    $params.organization = $_
                    $params.Type = $Type
                    try{
                        Get-ProofPointUser @params | Where-Object {$_.firstname -like "*$Name*" -or $_.LastName -like "*$Name*"}
                    }
                    catch{
                        Write-Warning $_.exception.message
                    }
                }
            }

            Email  {
                if($email -match '^[^@]+@[^@]+\.[^@]+'){
                    Write-Verbose "Querying user $Email"
                    
                    $domain = $Email -replace '^.+@'
                    
                    $params = @{
                        ErrorAction = 'Stop'
                        Uri = $script:ppconfig.endpoint + "orgs/" + $domain + "/users/" + $email
                    }

                }
                else{
                    Write-Warning "$email is not a valid email address"
                    continue
                }

                try{
                    $script:ppconfig.TotalRequests++
                    $response = Invoke-RestMethod @params
                    $script:ppconfig.lastresult = $response.StatusCode
                    
                    if($response){
                        [ProofPointUser]::New($domain,$response) | Where-Object Type -in $Type
                    }
                }
                catch{
                    Write-Warning "Error querying $($params.uri)"
                    Write-Warning $_.exception.message
                    $script:ppconfig.lastresult = $_.Exception.Response.StatusCode.value__ 
                }
            }

            Organization  {
                foreach($Org in $OrgLookup.PrimaryDomain){
                    Write-Verbose "Querying organization $Org"

                    $params = @{
                        Uri = $script:ppconfig.endpoint + "orgs/" + $Org + "/users/"
                        ErrorAction = 'Stop'
                    }

                    try{
                        $script:ppconfig.TotalRequests++
                        $response = Invoke-RestMethod @params
                        $script:ppconfig.lastresult = $response.StatusCode
                        $response.users | Foreach-object {[ProofPointUser]::New($Org,$_)} | Where-Object Type -in $Type
                    }
                    catch{
                        Write-Warning "Error querying $($params.uri)"
                        Write-Warning $_.exception.message
                        Write-Warning $_.Exception.Response.StatusCode.value__ 
                    }
                }
            }
        }
    }
}

