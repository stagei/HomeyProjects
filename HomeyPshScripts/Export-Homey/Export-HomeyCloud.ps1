<#
.SYNOPSIS
    Discovers and exports all Homey devices using Athom Cloud API

.DESCRIPTION
    Authenticates with your Athom account, discovers all your Homeys,
    and exports devices, flows, zones, apps, and configuration.
    
    Exports are saved to: .\_hubExport\<username>\<HomeyAlias>\

.PARAMETER Email
    Your Athom account email

.PARAMETER Password
    Your Athom account password

.PARAMETER Token
    OAuth token (if already authenticated)

.PARAMETER SaveCredentials
    Save credentials securely for future use

.EXAMPLE
    .\Export-HomeyCloud.ps1
    .\Export-HomeyCloud.ps1 -Email "user@example.com" -Password "pass" -SaveCredentials
#>

[CmdletBinding()]
param(
    [Parameter(Mandatory = $false)]
    [string]$Email,

    [Parameter(Mandatory = $false)]
    [string]$Password,

    [Parameter(Mandatory = $false)]
    [string]$Token,

    [Parameter(Mandatory = $false)]
    [switch]$SaveCredentials
)

# Use TLS 1.2
[Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12

# Import configuration module from parent directory
$script:RootPath = Split-Path -Parent $PSScriptRoot
Import-Module (Join-Path $script:RootPath "HomeyConfig.psm1") -Force

$script:AthomToken = $null
$script:AthomUser = $null

function Write-Banner {
    Write-Host ""
    Write-Host "╔════════════════════════════════════════════════════════╗" -ForegroundColor Cyan
    Write-Host "║     HOMEY CLOUD EXPORT - Auto Discovery v2.0           ║" -ForegroundColor Cyan
    Write-Host "╚════════════════════════════════════════════════════════╝" -ForegroundColor Cyan
    Write-Host ""
}

function Get-AthomToken {
    param(
        [string]$Email,
        [string]$Password
    )
    
    Write-Host "🔐 Authenticating with Athom Cloud..." -ForegroundColor Yellow
    
    # Try OAuth2 password grant (if supported) or delegated token
    $authUrl = "https://api.athom.com/oauth2/token"
    
    $body = @{
        client_id     = "5a8d4ca6eb9f7a2c9d6ccf6d"  # Homey CLI client ID (public)
        client_secret = "e3ace394af9f615857ceaa61b053f966ddcfb12a"  # Homey CLI client secret (public)
        grant_type    = "password"
        username      = $Email
        password      = $Password
    }
    
    try {
        $response = Invoke-RestMethod -Uri $authUrl -Method Post -Body $body -ContentType "application/x-www-form-urlencoded"
        $script:AthomToken = $response.access_token
        Write-Host "✅ Authentication successful!" -ForegroundColor Green
        return $true
    }
    catch {
        Write-Host "  Trying alternative authentication..." -ForegroundColor DarkGray
        
        # Try login endpoint
        try {
            $loginUrl = "https://api.athom.com/login"
            $loginBody = @{
                email    = $Email
                password = $Password
            } | ConvertTo-Json
            
            $response = Invoke-RestMethod -Uri $loginUrl -Method Post -Body $loginBody -ContentType "application/json"
            $script:AthomToken = $response.token
            Write-Host "✅ Authentication successful!" -ForegroundColor Green
            return $true
        }
        catch {
            Write-Host "❌ Authentication failed: $($_.Exception.Message)" -ForegroundColor Red
            return $false
        }
    }
}

function Get-AthomUser {
    Write-Host "👤 Fetching user info..." -ForegroundColor Yellow
    
    $headers = @{
        "Authorization" = "Bearer $($script:AthomToken)"
    }
    
    try {
        $user = Invoke-RestMethod -Uri "https://api.athom.com/user/me" -Headers $headers -Method Get
        $script:AthomUser = $user
        Write-Host "  Welcome, $($user.firstname) $($user.lastname)!" -ForegroundColor Green
        return $user
    }
    catch {
        Write-Host "❌ Failed to get user info: $($_.Exception.Message)" -ForegroundColor Red
        return $null
    }
}

function Get-MyHomeys {
    Write-Host "`n🏠 Discovering your Homeys..." -ForegroundColor Yellow
    
    $headers = @{
        "Authorization" = "Bearer $($script:AthomToken)"
    }
    
    try {
        $homeys = Invoke-RestMethod -Uri "https://api.athom.com/user/me/homey" -Headers $headers -Method Get
        
        if ($homeys.Count -eq 0) {
            Write-Host "  No Homeys found on your account" -ForegroundColor DarkGray
            return @()
        }
        
        Write-Host "`n  Found $($homeys.Count) Homey(s):" -ForegroundColor Green
        
        $homeyList = @()
        foreach ($homey in $homeys) {
            $homeyInfo = @{
                id              = $homey._id
                name            = $homey.name
                localAddress    = $homey.localAddress
                localUrl        = $homey.localUrl
                cloudUrl        = "https://$($homey._id).connect.athom.com"
                platform        = $homey.platform
                state           = $homey.state
                apiVersion      = $homey.apiVersion
                softwareVersion = $homey.softwareVersion
            }
            
            Write-Host "    • $($homey.name)" -ForegroundColor White
            Write-Host "      ID: $($homey._id)" -ForegroundColor DarkGray
            if ($homey.localAddress) {
                Write-Host "      Local IP: $($homey.localAddress)" -ForegroundColor DarkGray
            }
            Write-Host "      State: $($homey.state)" -ForegroundColor DarkGray
            Write-Host ""
            
            $homeyList += $homeyInfo
        }
        
        return $homeyList
    }
    catch {
        Write-Host "❌ Failed to get Homeys: $($_.Exception.Message)" -ForegroundColor Red
        return @()
    }
}

function Get-HomeyDelegationToken {
    param(
        [string]$HomeyId
    )
    
    $headers = @{
        "Authorization" = "Bearer $($script:AthomToken)"
        "Content-Type"  = "application/json"
    }
    
    try {
        # Get a delegation token for this specific Homey
        $response = Invoke-RestMethod -Uri "https://api.athom.com/delegation/token?audience=homey" -Headers $headers -Method Post
        return $response.jwt
    }
    catch {
        Write-Host "    (Could not get delegation token)" -ForegroundColor DarkGray
        return $null
    }
}

function Invoke-HomeyCloudApi {
    param(
        [string]$HomeyId,
        [string]$Endpoint,
        [string]$Token
    )
    
    $headers = @{
        "Authorization" = "Bearer $Token"
        "Content-Type"  = "application/json"
    }
    
    $url = "https://$($HomeyId).connect.athom.com/api/$Endpoint"
    
    try {
        $response = Invoke-RestMethod -Uri $url -Headers $headers -Method Get -TimeoutSec 60
        return $response
    }
    catch {
        # Try with manager prefix
        try {
            $url2 = "https://$($HomeyId).connect.athom.com/api/manager/$Endpoint"
            $response = Invoke-RestMethod -Uri $url2 -Headers $headers -Method Get -TimeoutSec 60
            return $response
        }
        catch {
            Write-Host "    (endpoint not available: $($Endpoint))" -ForegroundColor DarkGray
            return $null
        }
    }
}

function Get-HomeyAliasFromName {
    param([string]$Name)
    
    # Try to match existing hub aliases, or create a safe one
    $hubs = Get-AllHomeyHubs
    
    foreach ($hub in $hubs) {
        if ($hub.Hub.name -eq $Name -or $hub.Hub.cloudId) {
            return $hub.Alias
        }
    }
    
    # Create alias from name (remove special chars, use PascalCase)
    $alias = $Name -replace '[^a-zA-Z0-9\s]', '' -replace '\s+', ''
    if (-not $alias) { $alias = "Homey" }
    
    return $alias
}

function Export-SingleHomey {
    param(
        [object]$Homey,
        [string]$Token,
        [string]$Alias
    )
    
    Write-Host "`n📦 Exporting data from: $($Homey.name) (as '$Alias')" -ForegroundColor Green
    Write-Host "   Using cloud connection..." -ForegroundColor DarkGray
    
    # Update hub config
    Set-HomeyHub -Alias $Alias `
        -IP $Homey.localAddress `
        -Name $Homey.name `
        -CloudId $Homey.id `
        -Version $Homey.softwareVersion | Out-Null
    
    $exportData = @{
        exportedAt      = (Get-Date).ToString("o")
        homeyAlias      = $Alias
        homeyName       = $Homey.name
        homeyId         = $Homey.id
        localAddress    = $Homey.localAddress
        platform        = $Homey.platform
        softwareVersion = $Homey.softwareVersion
        system          = $null
        zones           = $null
        devices         = $null
        flows           = $null
        advancedFlows   = $null
        apps            = $null
        variables       = $null
        insights        = $null
    }
    
    # System info
    Write-Host "  ➤ Fetching system info..." -ForegroundColor Yellow
    $exportData.system = Invoke-HomeyCloudApi -HomeyId $Homey.id -Endpoint "system" -Token $Token
    
    # Zones
    Write-Host "  ➤ Fetching zones..." -ForegroundColor Yellow
    $zones = Invoke-HomeyCloudApi -HomeyId $Homey.id -Endpoint "zones/zone" -Token $Token
    $exportData.zones = $zones
    if ($zones) {
        $zoneCount = ($zones.PSObject.Properties | Measure-Object).Count
        Write-Host "    Found $zoneCount zones" -ForegroundColor DarkGray
    }
    
    # Devices
    Write-Host "  ➤ Fetching devices..." -ForegroundColor Yellow
    $devices = Invoke-HomeyCloudApi -HomeyId $Homey.id -Endpoint "devices/device" -Token $Token
    $exportData.devices = $devices
    if ($devices) {
        $deviceCount = ($devices.PSObject.Properties | Measure-Object).Count
        Write-Host "    Found $deviceCount devices" -ForegroundColor DarkGray
    }
    
    # Flows
    Write-Host "  ➤ Fetching flows..." -ForegroundColor Yellow
    $flows = Invoke-HomeyCloudApi -HomeyId $Homey.id -Endpoint "flow/flow" -Token $Token
    $exportData.flows = $flows
    if ($flows) {
        $flowCount = ($flows.PSObject.Properties | Measure-Object).Count
        Write-Host "    Found $flowCount flows" -ForegroundColor DarkGray
    }
    
    # Advanced Flows
    Write-Host "  ➤ Fetching advanced flows..." -ForegroundColor Yellow
    $advFlows = Invoke-HomeyCloudApi -HomeyId $Homey.id -Endpoint "flow/advancedflow" -Token $Token
    $exportData.advancedFlows = $advFlows
    if ($advFlows) {
        $advFlowCount = ($advFlows.PSObject.Properties | Measure-Object).Count
        Write-Host "    Found $advFlowCount advanced flows" -ForegroundColor DarkGray
    }
    
    # Apps
    Write-Host "  ➤ Fetching installed apps..." -ForegroundColor Yellow
    $apps = Invoke-HomeyCloudApi -HomeyId $Homey.id -Endpoint "apps/app" -Token $Token
    $exportData.apps = $apps
    if ($apps) {
        $appCount = ($apps.PSObject.Properties | Measure-Object).Count
        Write-Host "    Found $appCount apps" -ForegroundColor DarkGray
    }
    
    # Variables (Logic)
    Write-Host "  ➤ Fetching variables..." -ForegroundColor Yellow
    $variables = Invoke-HomeyCloudApi -HomeyId $Homey.id -Endpoint "logic/variable" -Token $Token
    $exportData.variables = $variables
    if ($variables) {
        $varCount = ($variables.PSObject.Properties | Measure-Object).Count
        Write-Host "    Found $varCount variables" -ForegroundColor DarkGray
    }
    
    # Insights
    Write-Host "  ➤ Fetching insights..." -ForegroundColor Yellow
    $insights = Invoke-HomeyCloudApi -HomeyId $Homey.id -Endpoint "insights/log" -Token $Token
    $exportData.insights = $insights
    
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
    
    $Data | ConvertTo-Json -Depth 30 | Set-Content -Path $filepath -Encoding UTF8
    
    Write-Host "`n✅ Saved to: $filepath" -ForegroundColor Green
    
    # Update last export time in config
    $config = Get-HomeyConfig
    if ($config.homeys.PSObject.Properties.Name -contains $Alias) {
        $config.homeys.$Alias.lastExport = (Get-Date).ToString("o")
        Save-HomeyConfig -Config $config
    }
    
    return $filepath
}

# Main script
Write-Banner

# Load stored credentials if available
$storedCreds = Get-AthomCredential

if (-not $Email -and $storedCreds) {
    $Email = $storedCreds.Email
}
if (-not $Password -and $storedCreds -and $storedCreds.Password) {
    $Password = $storedCreds.Password
}
if (-not $Token -and $storedCreds -and $storedCreds.Token) {
    $Token = $storedCreds.Token
}

# Check if we have a token already
$authSuccess = $false

if ($Token) {
    Write-Host "🔑 Using stored/provided token..." -ForegroundColor Yellow
    $script:AthomToken = $Token
    $authSuccess = $true
}
else {
    # Get credentials if not provided
    if (-not $Email) {
        Write-Host "📧 Enter your Athom account credentials" -ForegroundColor Cyan
        $Email = Read-Host "  Email"
    }
    if (-not $Password) {
        $Password = Read-Host "  Password"
    }
    
    # Authenticate
    $authSuccess = Get-AthomToken -Email $Email -Password $Password
    
    # Save credentials if requested and successful
    if ($authSuccess -and $SaveCredentials) {
        Set-AthomCredential -Email $Email -Password $Password -Token $script:AthomToken
        Write-Host "  🔐 Credentials saved securely" -ForegroundColor Green
    }
    elseif ($authSuccess -and $script:AthomToken) {
        # At least save the token
        Set-AthomCredential -Email $Email -Token $script:AthomToken
    }
}

if (-not $authSuccess) {
    Write-Host "`n❌ Could not authenticate. Please check your credentials." -ForegroundColor Red
    exit 1
}

# Get user info
$user = Get-AthomUser

if (-not $user) {
    Write-Host "`n❌ Could not retrieve user information." -ForegroundColor Red
    exit 1
}

# Discover Homeys
$homeys = Get-MyHomeys

if ($homeys.Count -eq 0) {
    Write-Host "`n❌ No Homeys found on your account." -ForegroundColor Red
    exit 1
}

# Get delegation token for API access
Write-Host "`n🔑 Getting API access token..." -ForegroundColor Yellow
$delegationToken = Get-HomeyDelegationToken -HomeyId $homeys[0].id

if (-not $delegationToken) {
    Write-Host "  Using account token instead..." -ForegroundColor DarkGray
    $delegationToken = $script:AthomToken
}

# Export each Homey
$allExports = @()

foreach ($homey in $homeys) {
    if ($homey.state -ne "online") {
        Write-Host "`n⚠️ Skipping $($homey.name) - Status: $($homey.state)" -ForegroundColor Yellow
        continue
    }
    
    # Determine alias for this Homey
    $alias = Get-HomeyAliasFromName -Name $homey.name
    
    $exportData = Export-SingleHomey -Homey $homey -Token $delegationToken -Alias $alias
    
    if ($exportData) {
        $filepath = Save-ExportData -Data $exportData -Alias $alias
        $allExports += @{
            Name  = $homey.name
            Alias = $alias
            Path  = $filepath
        }
    }
}

# Summary
if ($allExports.Count -gt 0) {
    Write-Host "`n" -NoNewline
    Write-Host "════════════════════════════════════════════════════════" -ForegroundColor Cyan
    Write-Host "🎉 EXPORT COMPLETE!" -ForegroundColor Green
    Write-Host "════════════════════════════════════════════════════════" -ForegroundColor Cyan
    Write-Host "`nExported files:" -ForegroundColor White
    foreach ($export in $allExports) {
        Write-Host "  • $($export.Name) → $($export.Path)" -ForegroundColor DarkGray
    }
    Write-Host ""
}
else {
    Write-Host "`n❌ No data was exported." -ForegroundColor Red
}
