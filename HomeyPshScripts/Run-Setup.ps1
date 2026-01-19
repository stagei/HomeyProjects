<#
.SYNOPSIS
    Launcher for Setup-Homey wizard

.DESCRIPTION
    Convenience script to run the Setup-Homey wizard from the root folder.

.EXAMPLE
    .\Run-Setup.ps1
    .\Run-Setup.ps1 -HomeyAlias "Cabin"
#>

param(
    [Parameter(Mandatory = $false)]
    [string]$HomeyAlias,

    [Parameter(Mandatory = $false)]
    [switch]$SkipScan
)

$scriptPath = Join-Path $PSScriptRoot "Setup-Homey\Setup-Homey.ps1"

$params = @{}
if ($HomeyAlias) { $params['HomeyAlias'] = $HomeyAlias }
if ($SkipScan) { $params['SkipScan'] = $true }

& $scriptPath @params
