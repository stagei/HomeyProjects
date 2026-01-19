<#
.SYNOPSIS
    Exports all data from Homey devices (devices, flows, zones, apps, etc.)

.DESCRIPTION
    This script connects to your Homey device(s) using the Local API and exports
    all configuration data to JSON files for reference and backup.

.PARAMETER HomeyName
    A friendly name for the Homey (e.g., "Home", "Cabin")

.PARAMETER HomeyIP
    The IP address of the Homey device

.PARAMETER ApiKey
    The API key generated from Homey Settings -> API Keys

.EXAMPLE
    .\Export-Homey.ps1 -HomeyName "Home" -HomeyIP "192.168.1.100" -ApiKey "your-api-key"

.NOTES
    Prerequisites:
    1. Be on the same network as your Homey
    2. Generate an API key in Homey app -> Settings -> API Keys
       Required permissions: Devices, Flows, Zones, Apps, Logic, Insights (all read)
#>

[CmdletBinding()]
param(
    [Parameter(Mandatory = $false)]
    [string]$HomeyName,

    [Parameter(Mandatory = $false)]
    [string]$HomeyIP,

    [Parameter(Mandatory = $false)]
    [string]$ApiKey
)

# Use TLS 1.2
[Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12

function Write-Banner {
    Write-Host ""
    Write-Host "╔════════════════════════════════════════════╗" -ForegroundColor Cyan
    Write-Host "║        HOMEY EXPORT TOOL v1.0.0            ║" -ForegroundColor Cyan
    Write-Host "╚════════════════════════════════════════════╝" -ForegroundColor Cyan
    Write-Host ""
}

function Invoke-HomeyApi {
    param(
        [string]$BaseUrl,
        [string]$Endpoint,
        [string]$Token
    )
    
    $headers = @{
        "Authorization" = "Bearer $Token"
        "Content-Type"  = "application/json"
    }
    
    $url = "$BaseUrl/api/$Endpoint"
    
    try {
        $response = Invoke-RestMethod -Uri $url -Headers $headers -Method Get -TimeoutSec 30
        return $response
    }
    catch {
        Write-Host "    (endpoint not available: $($Endpoint))" -ForegroundColor DarkGray
        return $null
    }
}

function Export-HomeyData {
    param(
        [string]$Name,
        [string]$IP,
        [string]$Token
    )
    
    $baseUrl = "http://$($IP)"
    
    Write-Host "`n📦 Exporting data from: $Name" -ForegroundColor Green
    Write-Host "   Address: $baseUrl" -ForegroundColor DarkGray
    
    # Test connection first
    Write-Host "`n  ➤ Testing connection..." -ForegroundColor Yellow
    $systemInfo = Invoke-HomeyApi -BaseUrl $baseUrl -Endpoint "manager/system" -Token $Token
    
    if (-not $systemInfo) {
        Write-Host "  ❌ Could not connect to Homey at $IP" -ForegroundColor Red
        Write-Host "     - Verify IP address is correct" -ForegroundColor DarkGray
        Write-Host "     - Ensure you're on the same network" -ForegroundColor DarkGray
        Write-Host "     - Check API key permissions" -ForegroundColor DarkGray
        return $null
    }
    
    Write-Host "  ✅ Connected!" -ForegroundColor Green
    
    $exportData = @{
        exportedAt   = (Get-Date).ToString("o")
        homeyName    = $Name
        homeyIP      = $IP
        system       = $null
        zones        = $null
        devices      = $null
        flows        = $null
        advancedFlows = $null
        apps         = $null
        variables    = $null
        insights     = $null
        users        = $null
        notifications = $null
    }
    
    # System info
    Write-Host "  ➤ Fetching system info..." -ForegroundColor Yellow
    $exportData.system = $systemInfo
    if ($systemInfo) {
        Write-Host "    Homey version: $($systemInfo.homeyVersion)" -ForegroundColor DarkGray
        Write-Host "    Model: $($systemInfo.model)" -ForegroundColor DarkGray
    }
    
    # Zones
    Write-Host "  ➤ Fetching zones..." -ForegroundColor Yellow
    $zones = Invoke-HomeyApi -BaseUrl $baseUrl -Endpoint "manager/zones/zone" -Token $Token
    $exportData.zones = $zones
    if ($zones) {
        $zoneCount = ($zones.PSObject.Properties | Measure-Object).Count
        Write-Host "    Found $zoneCount zones" -ForegroundColor DarkGray
    }
    
    # Devices
    Write-Host "  ➤ Fetching devices..." -ForegroundColor Yellow
    $devices = Invoke-HomeyApi -BaseUrl $baseUrl -Endpoint "manager/devices/device" -Token $Token
    $exportData.devices = $devices
    if ($devices) {
        $deviceCount = ($devices.PSObject.Properties | Measure-Object).Count
        Write-Host "    Found $deviceCount devices" -ForegroundColor DarkGray
    }
    
    # Flows
    Write-Host "  ➤ Fetching flows..." -ForegroundColor Yellow
    $flows = Invoke-HomeyApi -BaseUrl $baseUrl -Endpoint "manager/flow/flow" -Token $Token
    $exportData.flows = $flows
    if ($flows) {
        $flowCount = ($flows.PSObject.Properties | Measure-Object).Count
        Write-Host "    Found $flowCount flows" -ForegroundColor DarkGray
    }
    
    # Advanced Flows
    Write-Host "  ➤ Fetching advanced flows..." -ForegroundColor Yellow
    $advFlows = Invoke-HomeyApi -BaseUrl $baseUrl -Endpoint "manager/flow/advancedflow" -Token $Token
    $exportData.advancedFlows = $advFlows
    if ($advFlows) {
        $advFlowCount = ($advFlows.PSObject.Properties | Measure-Object).Count
        Write-Host "    Found $advFlowCount advanced flows" -ForegroundColor DarkGray
    }
    
    # Apps
    Write-Host "  ➤ Fetching installed apps..." -ForegroundColor Yellow
    $apps = Invoke-HomeyApi -BaseUrl $baseUrl -Endpoint "manager/apps/app" -Token $Token
    $exportData.apps = $apps
    if ($apps) {
        $appCount = ($apps.PSObject.Properties | Measure-Object).Count
        Write-Host "    Found $appCount apps" -ForegroundColor DarkGray
    }
    
    # Variables (Logic)
    Write-Host "  ➤ Fetching variables..." -ForegroundColor Yellow
    $variables = Invoke-HomeyApi -BaseUrl $baseUrl -Endpoint "manager/logic/variable" -Token $Token
    $exportData.variables = $variables
    if ($variables) {
        $varCount = ($variables.PSObject.Properties | Measure-Object).Count
        Write-Host "    Found $varCount variables" -ForegroundColor DarkGray
    }
    
    # Insights
    Write-Host "  ➤ Fetching insights..." -ForegroundColor Yellow
    $insights = Invoke-HomeyApi -BaseUrl $baseUrl -Endpoint "manager/insights/log" -Token $Token
    $exportData.insights = $insights
    if ($insights) {
        $insightCount = ($insights.PSObject.Properties | Measure-Object).Count
        Write-Host "    Found $insightCount insight logs" -ForegroundColor DarkGray
    }
    
    # Users
    Write-Host "  ➤ Fetching users..." -ForegroundColor Yellow
    $users = Invoke-HomeyApi -BaseUrl $baseUrl -Endpoint "manager/users/user" -Token $Token
    $exportData.users = $users
    if ($users) {
        $userCount = ($users.PSObject.Properties | Measure-Object).Count
        Write-Host "    Found $userCount users" -ForegroundColor DarkGray
    }
    
    # Notifications
    Write-Host "  ➤ Fetching notifications..." -ForegroundColor Yellow
    $notifications = Invoke-HomeyApi -BaseUrl $baseUrl -Endpoint "manager/notifications/notification" -Token $Token
    $exportData.notifications = $notifications
    
    return $exportData
}

function Save-ExportData {
    param(
        [object]$Data,
        [string]$Name
    )
    
    $exportsDir = Join-Path $PSScriptRoot "exports"
    if (-not (Test-Path $exportsDir)) {
        New-Item -ItemType Directory -Path $exportsDir -Force | Out-Null
    }
    
    $timestamp = Get-Date -Format "yyyyMMdd_HHmmss"
    $safeName = $Name -replace '[^a-zA-Z0-9]', '_'
    $filename = "$($safeName)_$($timestamp).json"
    $filepath = Join-Path $exportsDir $filename
    
    $Data | ConvertTo-Json -Depth 20 | Set-Content -Path $filepath -Encoding UTF8
    
    Write-Host "`n✅ Saved to: $filepath" -ForegroundColor Green
    
    return $filepath
}

function Get-HomeyCredentials {
    $creds = @()
    $continue = $true
    
    while ($continue) {
        Write-Host "`n🏠 Enter Homey Details" -ForegroundColor Cyan
        Write-Host "─────────────────────────────────────────" -ForegroundColor DarkGray
        
        $name = Read-Host "  Homey Name (e.g., 'Home' or 'Cabin')"
        $ip = Read-Host "  Homey IP Address (e.g., 192.168.1.100)"
        $key = Read-Host "  API Key"
        
        $creds += @{
            Name   = $name
            IP     = $ip
            ApiKey = $key
        }
        
        $another = Read-Host "`n  Add another Homey? (y/n)"
        $continue = $another -eq 'y' -or $another -eq 'Y'
    }
    
    return $creds
}

function Show-Instructions {
    Write-Host "`n📋 HOW TO GET YOUR API KEY" -ForegroundColor Cyan
    Write-Host "─────────────────────────────────────────" -ForegroundColor DarkGray
    Write-Host "1. Open the Homey app on your phone" -ForegroundColor White
    Write-Host "2. Go to Settings (gear icon)" -ForegroundColor White
    Write-Host "3. Scroll down to 'API Keys'" -ForegroundColor White
    Write-Host "4. Tap 'Create API Key'" -ForegroundColor White
    Write-Host "5. Name it (e.g., 'Export Script')" -ForegroundColor White
    Write-Host "6. Enable these permissions:" -ForegroundColor White
    Write-Host "   ✓ Devices (read)" -ForegroundColor Green
    Write-Host "   ✓ Flows (read)" -ForegroundColor Green
    Write-Host "   ✓ Zones (read)" -ForegroundColor Green
    Write-Host "   ✓ Apps (read)" -ForegroundColor Green
    Write-Host "   ✓ Logic (read)" -ForegroundColor Green
    Write-Host "   ✓ Insights (read)" -ForegroundColor Green
    Write-Host "   ✓ Users (read) - optional" -ForegroundColor Yellow
    Write-Host "7. Copy the generated API key" -ForegroundColor White
    Write-Host ""
    Write-Host "📋 HOW TO FIND YOUR HOMEY IP ADDRESS" -ForegroundColor Cyan
    Write-Host "─────────────────────────────────────────" -ForegroundColor DarkGray
    Write-Host "1. Open the Homey app" -ForegroundColor White
    Write-Host "2. Go to Settings → General" -ForegroundColor White
    Write-Host "3. Look for 'IP address' under network info" -ForegroundColor White
    Write-Host ""
}

# Main script
Write-Banner

# Check if running with parameters
if ($HomeyName -and $HomeyIP -and $ApiKey) {
    # Direct export with provided parameters
    $exportData = Export-HomeyData -Name $HomeyName -IP $HomeyIP -Token $ApiKey
    
    if ($exportData) {
        Save-ExportData -Data $exportData -Name $HomeyName
    }
}
else {
    # Interactive mode
    Show-Instructions
    
    $ready = Read-Host "Press Enter when you have your API key(s) ready, or 'q' to quit"
    if ($ready -eq 'q') {
        exit 0
    }
    
    $homeys = Get-HomeyCredentials
    
    $allExports = @()
    
    foreach ($homey in $homeys) {
        $exportData = Export-HomeyData -Name $homey.Name -IP $homey.IP -Token $homey.ApiKey
        
        if ($exportData) {
            $filepath = Save-ExportData -Data $exportData -Name $homey.Name
            $allExports += @{
                Name = $homey.Name
                Path = $filepath
            }
        }
    }
    
    if ($allExports.Count -gt 0) {
        Write-Host "`n🎉 EXPORT COMPLETE!" -ForegroundColor Green
        Write-Host "─────────────────────────────────────────" -ForegroundColor DarkGray
        Write-Host "Exported files:" -ForegroundColor White
        foreach ($export in $allExports) {
            Write-Host "  • $($export.Name): $($export.Path)" -ForegroundColor DarkGray
        }
        Write-Host ""
    }
}
