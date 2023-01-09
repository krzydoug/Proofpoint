Function Get-ProofPointConfig {
    [cmdletbinding()]
    Param()

    $properties = 'Endpoint', 'TotalRequests', 'LastResult', @{n='Credential';e={$_.credential.username}}

    Write-Verbose "Retrieving current Proofpoint configuration"
    return $Script:ppconfig | Select-Object $properties
}