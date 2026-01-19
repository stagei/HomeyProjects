<#
.SYNOPSIS
    Launcher for Export-Homey scripts

.DESCRIPTION
    Convenience script to run Export-Homey.ps1 from the root folder.

.EXAMPLE
    .\Run-Export.ps1 -HomeyAlias "Home"
    .\Run-Export.ps1 -ListHubs
#>

param(
    [Parameter(Mandatory = $false)]
    [string]$HomeyAlias = "Home",

    [Parameter(Mandatory = $false)]
    [string]$HomeyIP,

    [Parameter(Mandatory = $false)]
    [string]$ApiKey,

    [Parameter(Mandatory = $false)]
    [switch]$SaveCredentials,

    [Parameter(Mandatory = $false)]
    [switch]$ListHubs,

    [Parameter(Mandatory = $false)]
    [switch]$Cloud
)

if ($Cloud) {
    $scriptPath = Join-Path $PSScriptRoot "Export-Homey\Export-HomeyCloud.ps1"
    & $scriptPath
}
else {
    $scriptPath = Join-Path $PSScriptRoot "Export-Homey\Export-Homey.ps1"
    
    $params = @{}
    if ($HomeyAlias) { $params['HomeyAlias'] = $HomeyAlias }
    if ($HomeyIP) { $params['HomeyIP'] = $HomeyIP }
    if ($ApiKey) { $params['ApiKey'] = $ApiKey }
    if ($SaveCredentials) { $params['SaveCredentials'] = $true }
    if ($ListHubs) { $params['ListHubs'] = $true }
    
    & $scriptPath @params
}
