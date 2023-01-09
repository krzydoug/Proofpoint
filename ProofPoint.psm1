[cmdletbinding()]
Param()

$functionFolders = @('Public', 'Internal', 'Classes')

ForEach ($folder in $functionFolders)
{
    $folderPath = Join-Path -Path $PSScriptRoot -ChildPath $folder
    If (Test-Path -Path $folderPath)
    {
        $functions = Get-ChildItem -Path $folderPath -Filter '*.ps1' 
        ForEach ($function in $functions)
        {
            . $($function.FullName)
        }
    }    
}

$script:baseuri = "https://{0}.proofpointessentials.com/api/v1/"

$script:ppconfig = [PSCustomObject]@{
    Organization  = ""
    Endpoint      = ''
    TotalRequests = 0
    LastResult    = 0
    Credential    = ''
}

$FormatList = Get-ChildItem -Path $PSScriptRoot/formats/Proof*.ps1xml

foreach ($Format in $FormatList) {
    Update-FormatData -PrependPath $Format.FullName
}

$publicFunctions = (Get-ChildItem -Path "$PSScriptRoot\Public" -Filter '*.ps1').BaseName
Export-ModuleMember -Function $publicFunctions
