Function Remove-ProofPointUser {
    [cmdletbinding(SupportsShouldProcess,ConfirmImpact='High')]
    Param(
        [parameter(Position = 0,HelpMessage = "Enter a user's email",ValueFromPipeline,ValueFromPipelineByPropertyName)]
        [Alias('primary_email')]
        [string]$Email
    )

    begin{
        if(!$PSDefaultParameterValues['*:Headers']){
            Get-ProofPointCredential
        }
    }

    process{

        if($email -match '^[^@]+@[^@]+\.[^@]+'){
            Write-Verbose "Querying user $Email"
            
            $domain = $Email -replace '^.+@'

            if(!(Get-ProofPointOrganization -Domain $domain)){
                Write-Warning "No organization found matching $domain"
                continue
            }
            
            if(!(Get-ProofPointUser -Email $Email)){
                Write-Verbose "No account with email $Email found"
                continue
            }
        }
        else{
            Write-Warning "$email is not a valid email address"
            continue
        }

        if(!$PSCmdlet.ShouldProcess($Email)){
            continue
        }

        $params = @{
            Uri = $script:ppconfig.endpoint + "orgs/" + $domain + "/users/" + $email
            Method = 'Delete'
            Body        = @{primary_email=$Email} | ConvertTo-Json
            ErrorAction = 'Stop'
        }

        try{
            $script:ppconfig.TotalRequests++
            $response = Invoke-WebRequest @params
            $script:ppconfig.lastresult = $response.statuscode
        }
        catch{
            Write-Warning "Error querying $($params.uri)"
            Write-Warning $_.exception.message
            Write-Warning $_.Exception.Response.StatusCode.value__
        }

        if($response.statuscode -eq '204'){
            Write-Verbose "Account $Email deleted successfully"
        }
    }
}

