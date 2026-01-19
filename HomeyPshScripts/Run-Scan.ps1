<#
.SYNOPSIS
    Launcher for Scan-Network script

.DESCRIPTION
    Convenience script to run Scan-Network.ps1 from the root folder.

.EXAMPLE
    .\Run-Scan.ps1
    .\Run-Scan.ps1 -UpdateConfig -HomeyAlias "Cabin"
#>

param(
    [Parameter(Mandatory = $false)]
    [string]$OutputFile = "network-scan.json",

    [Parameter(Mandatory = $false)]
    [string]$SearchForText = "Homey",

    [Parameter(Mandatory = $false)]
    [switch]$UpdateConfig,

    [Parameter(Mandatory = $false)]
    [string]$HomeyAlias = "Home"
)

$scriptPath = Join-Path $PSScriptRoot "Scan-Network\Scan-Network.ps1"

$params = @{
    OutputFile    = $OutputFile
    SearchForText = $SearchForText
    HomeyAlias    = $HomeyAlias
}
if ($UpdateConfig) { $params['UpdateConfig'] = $true }

& $scriptPath @params
