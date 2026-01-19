<#
.SYNOPSIS
    Exports all data from Homey devices (devices, flows, zones, apps, etc.)

.DESCRIPTION
    This script connects to your Homey device(s) using the Local API and exports
    all configuration data to JSON files for reference and backup.
    
    Exports are saved to: .\_hubExport\<username>\<HomeyAlias>\

.PARAMETER HomeyAlias
    The alias/nickname for the Homey hub (e.g., "Home", "Cabin")

.PARAMETER HomeyIP
    The IP address of the Homey device (optional if already in config)

.PARAMETER ApiKey
    The API key (optional if already stored securely)

.PARAMETER SaveCredentials
    Save the provided API key securely for future use

.EXAMPLE
    .\Export-Homey.ps1 -HomeyAlias "Home"
    .\Export-Homey.ps1 -HomeyAlias "Home" -HomeyIP "192.168.1.100" -ApiKey "your-key" -SaveCredentials

.NOTES
    Prerequisites:
    1. Be on the same network as your Homey
    2. Generate an API key in Homey app -> Settings -> API Keys
       Required permissions: Devices, Flows, Zones, Apps, Logic, Insights (all read)
#>

[CmdletBinding()]
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
    [switch]$ListHubs
)

# Use TLS 1.2
[Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12

# Import configuration module from parent directory
$script:RootPath = Split-Path -Parent $PSScriptRoot
Import-Module (Join-Path $script:RootPath "HomeyConfig.psm1") -Force

function Write-Banner {
    Write-Host ""
    Write-Host "╔════════════════════════════════════════════╗" -ForegroundColor Cyan
    Write-Host "║        HOMEY EXPORT TOOL v2.0.0            ║" -ForegroundColor Cyan
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
        [string]$Alias,
        [string]$IP,
        [string]$Token
    )
    
    $baseUrl = "http://$($IP)"
    
    Write-Host "`n📦 Exporting data from: $Alias" -ForegroundColor Green
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
    
    # Update hub config with system info
    Set-HomeyHub -Alias $Alias -IP $IP `
        -Name $systemInfo.name `
        -Model $systemInfo.model `
        -Version $systemInfo.homeyVersion `
        -CloudId $systemInfo.cloudId | Out-Null
    
    $exportData = @{
        exportedAt    = (Get-Date).ToString("o")
        homeyAlias    = $Alias
        homeyIP       = $IP
        system        = $null
        zones         = $null
        devices       = $null
        flows         = $null
        advancedFlows = $null
        apps          = $null
        variables     = $null
        insights      = $null
        users         = $null
        notifications = $null
    }
    
    # System info
    Write-Host "  ➤ Fetching system info..." -ForegroundColor Yellow
    $exportData.system = $systemInfo
    if ($systemInfo) {
        Write-Host "    Homey: $($systemInfo.name)" -ForegroundColor DarkGray
        Write-Host "    Version: $($systemInfo.homeyVersion)" -ForegroundColor DarkGray
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
        [string]$Alias
    )
    
    # Get export path: .\_hubExport\<username>\<Alias>\
    $exportDir = Get-HomeyExportPath -HomeyAlias $Alias
    
    $timestamp = Get-Date -Format "yyyyMMdd_HHmmss"
    $filename = "export_$($timestamp).json"
    $filepath = Join-Path $exportDir $filename
    
    $Data | ConvertTo-Json -Depth 20 | Set-Content -Path $filepath -Encoding UTF8
    
    Write-Host "`n✅ Saved to: $filepath" -ForegroundColor Green
    
    # Update last export time in config
    $config = Get-HomeyConfig
    if ($config.homeys.PSObject.Properties.Name -contains $Alias) {
        $config.homeys.$Alias.lastExport = (Get-Date).ToString("o")
        Save-HomeyConfig -Config $config
    }
    
    return $filepath
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
    Write-Host "   OR run: .\Scan-Network.ps1 -UpdateConfig" -ForegroundColor Cyan
    Write-Host ""
}

function Show-ConfiguredHubs {
    $hubs = Get-AllHomeyHubs
    
    if ($hubs.Count -eq 0) {
        Write-Host "`n  No Homey hubs configured yet." -ForegroundColor Yellow
        Write-Host "  Run: .\Scan-Network.ps1 -UpdateConfig -HomeyAlias 'Home'" -ForegroundColor Cyan
        return
    }
    
    Write-Host "`n📋 Configured Homey Hubs:" -ForegroundColor Cyan
    Write-Host "─────────────────────────────────────────" -ForegroundColor DarkGray
    
    foreach ($item in $hubs) {
        $hub = $item.Hub
        $hasKey = if (Get-HomeyApiKey -Alias $item.Alias) { "✓" } else { "✗" }
        
        Write-Host "  🏠 $($item.Alias)" -ForegroundColor White
        Write-Host "     IP: $($hub.ip)" -ForegroundColor DarkGray
        Write-Host "     Name: $($hub.name)" -ForegroundColor DarkGray
        Write-Host "     API Key: $hasKey" -ForegroundColor $(if ($hasKey -eq "✓") { "Green" } else { "Yellow" })
        if ($hub.lastExport) {
            Write-Host "     Last Export: $($hub.lastExport)" -ForegroundColor DarkGray
        }
        Write-Host ""
    }
}

# Main script
Write-Banner

# List hubs mode
if ($ListHubs) {
    Show-ConfiguredHubs
    exit 0
}

# Try to get config from stored values
$hub = Get-HomeyHub -Alias $HomeyAlias

# Override with parameters if provided
if (-not $HomeyIP -and $hub) {
    $HomeyIP = $hub.ip
}

if (-not $ApiKey) {
    $ApiKey = Get-HomeyApiKey -Alias $HomeyAlias
}

# Save credentials if requested
if ($SaveCredentials -and $ApiKey) {
    Set-HomeyApiKey -Alias $HomeyAlias -ApiKey $ApiKey
}

# Check if we have required config
$hasConfig = $HomeyIP -and $ApiKey

if ($hasConfig) {
    Write-Host "📋 Using configuration for: $HomeyAlias" -ForegroundColor Cyan
    Write-Host "   IP: $HomeyIP" -ForegroundColor DarkGray
    Write-Host "   API Key: $($ApiKey.Substring(0, [Math]::Min(8, $ApiKey.Length)))..." -ForegroundColor DarkGray
    Write-Host "   Export to: .\_hubExport\$($env:USERNAME)\$HomeyAlias\" -ForegroundColor DarkGray
    Write-Host ""
    
    # Update hub config with IP if not already set
    if (-not $hub -or -not $hub.ip) {
        Set-HomeyHub -Alias $HomeyAlias -IP $HomeyIP | Out-Null
    }
    
    # Direct export
    $exportData = Export-HomeyData -Alias $HomeyAlias -IP $HomeyIP -Token $ApiKey
    
    if ($exportData) {
        Save-ExportData -Data $exportData -Alias $HomeyAlias
    }
}
else {
    # Interactive mode - show what's missing
    Write-Host "⚠️ Missing configuration for '$HomeyAlias':" -ForegroundColor Yellow
    if (-not $HomeyIP) { Write-Host "   • IP address not set" -ForegroundColor DarkGray }
    if (-not $ApiKey) { Write-Host "   • API key not stored" -ForegroundColor DarkGray }
    Write-Host ""
    
    Show-ConfiguredHubs
    
    Write-Host "`n💡 Quick setup:" -ForegroundColor Cyan
    Write-Host "   1. Run: .\Scan-Network.ps1 -UpdateConfig -HomeyAlias '$HomeyAlias'" -ForegroundColor White
    Write-Host "   2. Run: .\Export-Homey.ps1 -HomeyAlias '$HomeyAlias' -ApiKey 'your-key' -SaveCredentials" -ForegroundColor White
    Write-Host ""
    
    Show-Instructions
    
    $inputIp = Read-Host "Enter Homey IP (or press Enter to quit)"
    if (-not $inputIp) { exit 0 }
    
    $inputKey = Read-Host "Enter API Key"
    if (-not $inputKey) { exit 0 }
    
    $saveChoice = Read-Host "Save credentials securely? (y/n)"
    if ($saveChoice -eq 'y' -or $saveChoice -eq 'Y') {
        Set-HomeyHub -Alias $HomeyAlias -IP $inputIp | Out-Null
        Set-HomeyApiKey -Alias $HomeyAlias -ApiKey $inputKey
    }
    
    $exportData = Export-HomeyData -Alias $HomeyAlias -IP $inputIp -Token $inputKey
    
    if ($exportData) {
        Save-ExportData -Data $exportData -Alias $HomeyAlias
    }
}
