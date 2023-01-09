Function Get-ProofPointCredential {
    [cmdletbinding()]
    Param(
        [parameter()]
        [string]$UserName
    )

    $params = @{
        Message = "Enter Proofpoint credentials"
    }

    if($UserName){
        $params.Add('Credential',$UserName)
    }

    Write-Verbose "Gathering Proofpoint credentials"

    try{
        $cred = Get-Credential @params 
    }
    catch{
        Write-Warning $_.Exception.Message
    }

    if($cred){
        Set-ProofPointConfig -Credential $cred
    }
    
}