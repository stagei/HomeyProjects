<#
.SYNOPSIS
    Interactive setup wizard for Homey export tools.

.DESCRIPTION
    Guides you through:
    1. Network scan to find Homey devices
    2. Configuring each Homey hub with an alias
    3. Obtaining and storing API keys securely
    4. Running the first export

.PARAMETER HomeyAlias
    Optional: Skip to configuring a specific Homey alias

.PARAMETER SkipScan
    Skip network scanning (use existing config)

.EXAMPLE
    .\Setup-Homey.ps1
    .\Setup-Homey.ps1 -HomeyAlias "Cabin"
#>

[CmdletBinding()]
param(
    [Parameter(Mandatory = $false)]
    [string]$HomeyAlias,

    [Parameter(Mandatory = $false)]
    [switch]$SkipScan
)

# Import configuration module from parent directory
$script:RootPath = Split-Path -Parent $PSScriptRoot
Import-Module (Join-Path $script:RootPath "HomeyConfig.psm1") -Force

# Use TLS 1.2
[Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12

#region Helper Functions

function Write-Banner {
    Clear-Host
    Write-Host ""
    Write-Host "╔════════════════════════════════════════════════════════════╗" -ForegroundColor Cyan
    Write-Host "║              HOMEY SETUP WIZARD v1.0                       ║" -ForegroundColor Cyan
    Write-Host "║         Configure & Export Your Homey Devices              ║" -ForegroundColor Cyan
    Write-Host "╚════════════════════════════════════════════════════════════╝" -ForegroundColor Cyan
    Write-Host ""
}

function Write-Step {
    param(
        [int]$Number,
        [string]$Title,
        [string]$Status = "pending"
    )
    
    $icon = switch ($Status) {
        "pending" { "○" }
        "current" { "●" }
        "done" { "✓" }
        "skip" { "○" }
        default { "○" }
    }
    
    $color = switch ($Status) {
        "pending" { "DarkGray" }
        "current" { "Yellow" }
        "done" { "Green" }
        "skip" { "DarkGray" }
        default { "DarkGray" }
    }
    
    Write-Host "  $icon Step $Number`: $Title" -ForegroundColor $color
}

function Write-StepHeader {
    param(
        [int]$Number,
        [string]$Title
    )
    
    Write-Host ""
    Write-Host "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━" -ForegroundColor Cyan
    Write-Host "  STEP $Number`: $Title" -ForegroundColor White
    Write-Host "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━" -ForegroundColor Cyan
    Write-Host ""
}

function Read-UserChoice {
    param(
        [string]$Prompt,
        [string[]]$ValidChoices,
        [string]$Default
    )
    
    $promptText = $Prompt
    if ($Default) {
        $promptText += " [$Default]"
    }
    
    while ($true) {
        $input = Read-Host $promptText
        
        if ([string]::IsNullOrWhiteSpace($input) -and $Default) {
            return $Default
        }
        
        if ($ValidChoices -and $input -notin $ValidChoices) {
            Write-Host "  Invalid choice. Please enter one of: $($ValidChoices -join ', ')" -ForegroundColor Yellow
            continue
        }
        
        return $input
    }
}

function Read-YesNo {
    param(
        [string]$Prompt,
        [bool]$Default = $true
    )
    
    $defaultText = if ($Default) { "Y/n" } else { "y/N" }
    $input = Read-Host "$Prompt [$defaultText]"
    
    if ([string]::IsNullOrWhiteSpace($input)) {
        return $Default
    }
    
    return $input -match '^[Yy]'
}

function Test-HomeyConnection {
    param(
        [string]$IP,
        [string]$ApiKey
    )
    
    $headers = @{
        "Authorization" = "Bearer $ApiKey"
        "Content-Type"  = "application/json"
    }
    
    try {
        $response = Invoke-RestMethod -Uri "http://$IP/api/manager/system" -Headers $headers -Method Get -TimeoutSec 10
        return @{
            Success = $true
            Data    = $response
        }
    }
    catch {
        return @{
            Success = $false
            Error   = $_.Exception.Message
        }
    }
}

function Find-HomeyDevices {
    Write-Host "  🔍 Scanning network for Homey devices..." -ForegroundColor Yellow
    Write-Host "     This may take 30-60 seconds..." -ForegroundColor DarkGray
    Write-Host ""
    
    # Get network info
    $adapter = Get-NetIPConfiguration | Where-Object { 
        $_.IPv4DefaultGateway -ne $null -and 
        $_.NetAdapter.Status -eq "Up" 
    } | Select-Object -First 1
    
    if (-not $adapter) {
        Write-Host "  ❌ No active network adapter found!" -ForegroundColor Red
        return @()
    }
    
    $ip = $adapter.IPv4Address.IPAddress
    $ipParts = $ip.Split('.')
    $networkBase = "$($ipParts[0]).$($ipParts[1]).$($ipParts[2])"
    
    Write-Host "  📡 Network: $networkBase.0/24" -ForegroundColor DarkGray
    
    # Quick ping sweep
    $total = 254
    for ($i = 1; $i -le 254; $i++) {
        $targetIp = "$networkBase.$i"
        if ($i % 50 -eq 0) {
            Write-Progress -Activity "Scanning network" -Status "$targetIp" -PercentComplete (($i / $total) * 100)
        }
        $ping = New-Object System.Net.NetworkInformation.Ping
        try { $ping.Send($targetIp, 30) | Out-Null } catch {}
        $ping.Dispose()
    }
    Write-Progress -Activity "Scanning network" -Completed
    
    # Check ARP cache for devices
    $arpEntries = Get-NetNeighbor -AddressFamily IPv4 | Where-Object {
        $_.State -in @("Reachable", "Stale", "Permanent") -and
        $_.IPAddress -like "$networkBase.*" -and
        $_.IPAddress -ne "$networkBase.255"
    }
    
    Write-Host "  📊 Found $($arpEntries.Count) devices on network" -ForegroundColor DarkGray
    
    # Check each device for Homey API
    $homeyDevices = @()
    $current = 0
    $total = $arpEntries.Count
    
    foreach ($entry in $arpEntries) {
        $current++
        $targetIp = $entry.IPAddress
        
        Write-Progress -Activity "Checking for Homey devices" -Status "$targetIp ($current/$total)" -PercentComplete (($current / $total) * 100)
        
        # Quick check - try to reach Homey API without auth
        try {
            $response = Invoke-RestMethod -Uri "http://$targetIp/api/manager/system" -Method Get -TimeoutSec 2 -ErrorAction Stop
            
            if ($response.homeyVersion -or $response.name) {
                $homeyDevices += @{
                    IP        = $targetIp
                    MAC       = $entry.LinkLayerAddress
                    Name      = $response.name
                    Version   = $response.homeyVersion
                    Model     = $response.model
                    ModelName = $response.modelName
                    CloudId   = $response.cloudId
                }
            }
        }
        catch {
            # Not a Homey or requires auth - skip
        }
    }
    
    Write-Progress -Activity "Checking for Homey devices" -Completed
    
    return $homeyDevices
}

function Show-FoundHomeys {
    param([array]$Homeys)
    
    if ($Homeys.Count -eq 0) {
        Write-Host "  ⚠️ No Homey devices found on the network." -ForegroundColor Yellow
        Write-Host ""
        Write-Host "  Possible reasons:" -ForegroundColor DarkGray
        Write-Host "    • Homey is on a different network" -ForegroundColor DarkGray
        Write-Host "    • Homey is offline" -ForegroundColor DarkGray
        Write-Host "    • Firewall blocking discovery" -ForegroundColor DarkGray
        Write-Host ""
        return
    }
    
    Write-Host "  🏠 Found $($Homeys.Count) Homey device(s):" -ForegroundColor Green
    Write-Host ""
    
    $index = 1
    foreach ($homey in $Homeys) {
        Write-Host "  [$index] $($homey.Name)" -ForegroundColor White
        Write-Host "      IP: $($homey.IP)" -ForegroundColor DarkGray
        Write-Host "      Model: $($homey.ModelName)" -ForegroundColor DarkGray
        Write-Host "      Version: $($homey.Version)" -ForegroundColor DarkGray
        Write-Host ""
        $index++
    }
}

function Show-ApiKeyInstructions {
    Write-Host ""
    Write-Host "  📱 HOW TO GET YOUR API KEY:" -ForegroundColor Cyan
    Write-Host "  ─────────────────────────────────────────────────────" -ForegroundColor DarkGray
    Write-Host ""
    Write-Host "  1. Open the Homey app on your phone" -ForegroundColor White
    Write-Host "  2. Tap ⚙️ Settings (gear icon)" -ForegroundColor White
    Write-Host "  3. Scroll down and tap 'API Keys'" -ForegroundColor White
    Write-Host "  4. Tap '+ Create API Key'" -ForegroundColor White
    Write-Host "  5. Name it: 'Export Script'" -ForegroundColor White
    Write-Host "  6. Enable these permissions:" -ForegroundColor White
    Write-Host "       ✓ Devices (read)" -ForegroundColor Green
    Write-Host "       ✓ Flows (read)" -ForegroundColor Green
    Write-Host "       ✓ Zones (read)" -ForegroundColor Green
    Write-Host "       ✓ Apps (read)" -ForegroundColor Green
    Write-Host "       ✓ Logic (read)" -ForegroundColor Green
    Write-Host "       ✓ Insights (read)" -ForegroundColor Green
    Write-Host "       ✓ Users (read) - optional" -ForegroundColor Yellow
    Write-Host "  7. Tap 'Create' and copy the key" -ForegroundColor White
    Write-Host ""
}

function Show-ExistingHubs {
    $hubs = Get-AllHomeyHubs
    
    if ($hubs.Count -eq 0) {
        return $false
    }
    
    Write-Host "  📋 Existing Homey configurations:" -ForegroundColor Cyan
    Write-Host ""
    
    foreach ($item in $hubs) {
        $hub = $item.Hub
        $hasKey = if (Get-HomeyApiKey -Alias $item.Alias) { "✓ API Key" } else { "✗ No API Key" }
        $keyColor = if (Get-HomeyApiKey -Alias $item.Alias) { "Green" } else { "Yellow" }
        
        Write-Host "  🏠 $($item.Alias)" -ForegroundColor White
        Write-Host "     IP: $($hub.ip)" -ForegroundColor DarkGray
        Write-Host "     Name: $($hub.name)" -ForegroundColor DarkGray
        Write-Host "     Status: $hasKey" -ForegroundColor $keyColor
        Write-Host ""
    }
    
    return $true
}

function Invoke-HomeyExport {
    param(
        [string]$Alias,
        [string]$IP,
        [string]$ApiKey
    )
    
    Write-Host "  📦 Exporting data from '$Alias'..." -ForegroundColor Yellow
    Write-Host ""
    
    $headers = @{
        "Authorization" = "Bearer $ApiKey"
        "Content-Type"  = "application/json"
    }
    
    $baseUrl = "http://$IP"
    
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
    
    $endpoints = @(
        @{ Name = "system"; Endpoint = "manager/system" },
        @{ Name = "zones"; Endpoint = "manager/zones/zone" },
        @{ Name = "devices"; Endpoint = "manager/devices/device" },
        @{ Name = "flows"; Endpoint = "manager/flow/flow" },
        @{ Name = "advancedFlows"; Endpoint = "manager/flow/advancedflow" },
        @{ Name = "apps"; Endpoint = "manager/apps/app" },
        @{ Name = "variables"; Endpoint = "manager/logic/variable" },
        @{ Name = "insights"; Endpoint = "manager/insights/log" },
        @{ Name = "users"; Endpoint = "manager/users/user" },
        @{ Name = "notifications"; Endpoint = "manager/notifications/notification" }
    )
    
    foreach ($ep in $endpoints) {
        Write-Host "     ➤ Fetching $($ep.Name)..." -ForegroundColor DarkGray
        try {
            $response = Invoke-RestMethod -Uri "$baseUrl/api/$($ep.Endpoint)" -Headers $headers -Method Get -TimeoutSec 30
            $exportData[$ep.Name] = $response
            
            if ($response -and $response.PSObject.Properties) {
                $count = ($response.PSObject.Properties | Measure-Object).Count
                Write-Host "       Found $count items" -ForegroundColor DarkGray
            }
        }
        catch {
            Write-Host "       (not available)" -ForegroundColor DarkGray
        }
    }
    
    # Update hub config with system info
    if ($exportData.system) {
        Set-HomeyHub -Alias $Alias -IP $IP `
            -Name $exportData.system.name `
            -Model $exportData.system.model `
            -Version $exportData.system.homeyVersion `
            -CloudId $exportData.system.cloudId | Out-Null
    }
    
    # Save export
    $exportDir = Get-HomeyExportPath -HomeyAlias $Alias
    $timestamp = Get-Date -Format "yyyyMMdd_HHmmss"
    $filename = "export_$($timestamp).json"
    $filepath = Join-Path $exportDir $filename
    
    $exportData | ConvertTo-Json -Depth 20 | Set-Content -Path $filepath -Encoding UTF8
    
    # Update last export time
    $config = Get-HomeyConfig
    if ($config.homeys.PSObject.Properties.Name -contains $Alias) {
        $config.homeys.$Alias.lastExport = (Get-Date).ToString("o")
        Save-HomeyConfig -Config $config
    }
    
    return $filepath
}

#endregion

#region Main Wizard Flow

Write-Banner

# Show progress steps
Write-Host "  Setup Steps:" -ForegroundColor White
Write-Step -Number 1 -Title "Scan Network" -Status $(if ($SkipScan) { "skip" } else { "current" })
Write-Step -Number 2 -Title "Select/Configure Homey" -Status "pending"
Write-Step -Number 3 -Title "Enter API Key" -Status "pending"
Write-Step -Number 4 -Title "Test Connection" -Status "pending"
Write-Step -Number 5 -Title "Export Data" -Status "pending"
Write-Host ""

# Check for existing config
$existingHubs = Get-AllHomeyHubs
$foundHomeys = @()

#region Step 1: Network Scan
if (-not $SkipScan) {
    Write-StepHeader -Number 1 -Title "NETWORK SCAN"
    
    if ($existingHubs.Count -gt 0) {
        Show-ExistingHubs | Out-Null
        
        $rescan = Read-YesNo -Prompt "  Scan for new Homey devices?" -Default $false
        
        if (-not $rescan) {
            $SkipScan = $true
        }
    }
    
    if (-not $SkipScan) {
        $foundHomeys = Find-HomeyDevices
        Show-FoundHomeys -Homeys $foundHomeys
        
        # Save found Homeys to config with temporary aliases
        $index = 1
        foreach ($homey in $foundHomeys) {
            # Check if this IP is already configured
            $existing = $existingHubs | Where-Object { $_.Hub.ip -eq $homey.IP }
            
            if (-not $existing) {
                $tempAlias = "Homey$index"
                Set-HomeyHub -Alias $tempAlias -IP $homey.IP `
                    -Name $homey.Name -Model $homey.Model -Version $homey.Version -CloudId $homey.CloudId | Out-Null
                Write-Host "  💾 Saved '$($homey.Name)' as '$tempAlias'" -ForegroundColor DarkGray
                $index++
            }
        }
        
        # Refresh hub list
        $existingHubs = Get-AllHomeyHubs
    }
}
#endregion

#region Step 2: Select/Configure Homey
Write-StepHeader -Number 2 -Title "SELECT HOMEY"

$selectedAlias = $HomeyAlias
$selectedHub = $null

if ($existingHubs.Count -eq 0 -and $foundHomeys.Count -eq 0) {
    # Manual entry required
    Write-Host "  No Homey devices found. Please enter details manually:" -ForegroundColor Yellow
    Write-Host ""
    
    $manualAlias = Read-Host "  Enter an alias for your Homey (e.g., 'Home', 'Cabin')"
    if ([string]::IsNullOrWhiteSpace($manualAlias)) { $manualAlias = "Home" }
    
    $manualIP = Read-Host "  Enter the Homey IP address"
    if ([string]::IsNullOrWhiteSpace($manualIP)) {
        Write-Host "  ❌ IP address is required!" -ForegroundColor Red
        exit 1
    }
    
    Set-HomeyHub -Alias $manualAlias -IP $manualIP | Out-Null
    Write-Host "  💾 Saved configuration for '$manualAlias'" -ForegroundColor Green
    
    $selectedAlias = $manualAlias
    $selectedHub = Get-HomeyHub -Alias $manualAlias
}
elseif ($HomeyAlias) {
    # Alias provided as parameter
    $selectedHub = Get-HomeyHub -Alias $HomeyAlias
    
    if (-not $selectedHub) {
        Write-Host "  ⚠️ No configuration found for '$HomeyAlias'" -ForegroundColor Yellow
        
        # Maybe they meant to configure a found Homey with this alias?
        if ($foundHomeys.Count -gt 0) {
            Write-Host ""
            Show-FoundHomeys -Homeys $foundHomeys
            $choice = Read-Host "  Select a Homey to configure as '$HomeyAlias' (1-$($foundHomeys.Count))"
            
            if ($choice -match '^\d+$' -and [int]$choice -ge 1 -and [int]$choice -le $foundHomeys.Count) {
                $selected = $foundHomeys[[int]$choice - 1]
                Set-HomeyHub -Alias $HomeyAlias -IP $selected.IP `
                    -Name $selected.Name -Model $selected.Model -Version $selected.Version | Out-Null
                $selectedHub = Get-HomeyHub -Alias $HomeyAlias
            }
        }
    }
}
else {
    # Let user choose from existing hubs
    $existingHubs = Get-AllHomeyHubs
    
    if ($existingHubs.Count -eq 1) {
        $selectedAlias = $existingHubs[0].Alias
        $selectedHub = $existingHubs[0].Hub
        Write-Host "  Using: $selectedAlias ($($selectedHub.name))" -ForegroundColor Green
    }
    else {
        Write-Host "  Available Homey configurations:" -ForegroundColor White
        Write-Host ""
        
        $index = 1
        foreach ($item in $existingHubs) {
            $hasKey = if (Get-HomeyApiKey -Alias $item.Alias) { "✓" } else { "✗" }
            Write-Host "  [$index] $($item.Alias) - $($item.Hub.name) [$hasKey API Key]" -ForegroundColor White
            Write-Host "      IP: $($item.Hub.ip)" -ForegroundColor DarkGray
            $index++
        }
        
        Write-Host ""
        $choice = Read-Host "  Select a Homey (1-$($existingHubs.Count))"
        
        if ($choice -match '^\d+$' -and [int]$choice -ge 1 -and [int]$choice -le $existingHubs.Count) {
            $selectedAlias = $existingHubs[[int]$choice - 1].Alias
            $selectedHub = $existingHubs[[int]$choice - 1].Hub
        }
        else {
            Write-Host "  ❌ Invalid selection!" -ForegroundColor Red
            exit 1
        }
    }
    
    # Offer to rename alias
    Write-Host ""
    $rename = Read-YesNo -Prompt "  Rename '$selectedAlias' to something else?" -Default $false
    
    if ($rename) {
        $newAlias = Read-Host "  Enter new alias (e.g., 'Home', 'Cabin')"
        
        if (-not [string]::IsNullOrWhiteSpace($newAlias) -and $newAlias -ne $selectedAlias) {
            # Create new hub with new alias, copy data
            Set-HomeyHub -Alias $newAlias -IP $selectedHub.ip `
                -Name $selectedHub.name -Model $selectedHub.model -Version $selectedHub.version | Out-Null
            
            # Copy API key if exists
            $existingKey = Get-HomeyApiKey -Alias $selectedAlias
            if ($existingKey) {
                Set-HomeyApiKey -Alias $newAlias -ApiKey $existingKey
            }
            
            # Remove old alias
            Remove-HomeyHub -Alias $selectedAlias | Out-Null
            
            $selectedAlias = $newAlias
            $selectedHub = Get-HomeyHub -Alias $newAlias
            
            Write-Host "  ✅ Renamed to '$newAlias'" -ForegroundColor Green
        }
    }
}

Write-Host ""
Write-Host "  ✅ Selected: $selectedAlias" -ForegroundColor Green
Write-Host "     IP: $($selectedHub.ip)" -ForegroundColor DarkGray
Write-Host "     Name: $($selectedHub.name)" -ForegroundColor DarkGray
#endregion

#region Step 3: API Key
Write-StepHeader -Number 3 -Title "API KEY"

$apiKey = Get-HomeyApiKey -Alias $selectedAlias

if ($apiKey) {
    Write-Host "  ✅ API key already configured for '$selectedAlias'" -ForegroundColor Green
    Write-Host "     Key: $($apiKey.Substring(0, [Math]::Min(8, $apiKey.Length)))..." -ForegroundColor DarkGray
    Write-Host ""
    
    $updateKey = Read-YesNo -Prompt "  Update API key?" -Default $false
    
    if ($updateKey) {
        $apiKey = $null
    }
}

if (-not $apiKey) {
    Show-ApiKeyInstructions
    
    Write-Host "  📋 Paste your API key below (it will be stored securely):" -ForegroundColor Cyan
    Write-Host ""
    
    $inputKey = Read-Host "  API Key"
    
    if ([string]::IsNullOrWhiteSpace($inputKey)) {
        Write-Host "  ❌ API key is required!" -ForegroundColor Red
        exit 1
    }
    
    $apiKey = $inputKey
    Set-HomeyApiKey -Alias $selectedAlias -ApiKey $apiKey
    Write-Host "  ✅ API key saved securely" -ForegroundColor Green
}
#endregion

#region Step 4: Test Connection
Write-StepHeader -Number 4 -Title "TEST CONNECTION"

Write-Host "  🔌 Testing connection to $($selectedHub.ip)..." -ForegroundColor Yellow

$test = Test-HomeyConnection -IP $selectedHub.ip -ApiKey $apiKey

if ($test.Success) {
    Write-Host "  ✅ Connection successful!" -ForegroundColor Green
    Write-Host ""
    Write-Host "     Homey: $($test.Data.name)" -ForegroundColor DarkGray
    Write-Host "     Version: $($test.Data.homeyVersion)" -ForegroundColor DarkGray
    Write-Host "     Model: $($test.Data.modelName)" -ForegroundColor DarkGray
    
    # Update hub info
    Set-HomeyHub -Alias $selectedAlias -IP $selectedHub.ip `
        -Name $test.Data.name -Model $test.Data.model -Version $test.Data.homeyVersion | Out-Null
}
else {
    Write-Host "  ❌ Connection failed!" -ForegroundColor Red
    Write-Host "     Error: $($test.Error)" -ForegroundColor DarkGray
    Write-Host ""
    Write-Host "  Possible issues:" -ForegroundColor Yellow
    Write-Host "    • API key may be invalid or expired" -ForegroundColor DarkGray
    Write-Host "    • API key may lack required permissions" -ForegroundColor DarkGray
    Write-Host "    • Homey may be unreachable" -ForegroundColor DarkGray
    Write-Host ""
    
    $retry = Read-YesNo -Prompt "  Enter a new API key?" -Default $true
    
    if ($retry) {
        Show-ApiKeyInstructions
        $inputKey = Read-Host "  API Key"
        
        if (-not [string]::IsNullOrWhiteSpace($inputKey)) {
            $apiKey = $inputKey
            Set-HomeyApiKey -Alias $selectedAlias -ApiKey $apiKey
            
            $test = Test-HomeyConnection -IP $selectedHub.ip -ApiKey $apiKey
            
            if ($test.Success) {
                Write-Host "  ✅ Connection successful!" -ForegroundColor Green
            }
            else {
                Write-Host "  ❌ Still failing. Please check your API key and try again." -ForegroundColor Red
                exit 1
            }
        }
    }
    else {
        exit 1
    }
}
#endregion

#region Step 5: Export
Write-StepHeader -Number 5 -Title "EXPORT DATA"

$doExport = Read-YesNo -Prompt "  Export data from '$selectedAlias' now?" -Default $true

if ($doExport) {
    Write-Host ""
    $exportPath = Invoke-HomeyExport -Alias $selectedAlias -IP $selectedHub.ip -ApiKey $apiKey
    
    Write-Host ""
    Write-Host "  ✅ Export complete!" -ForegroundColor Green
    Write-Host "     Saved to: $exportPath" -ForegroundColor Cyan
}
#endregion

#region Summary
Write-Host ""
Write-Host "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━" -ForegroundColor Cyan
Write-Host "  🎉 SETUP COMPLETE!" -ForegroundColor Green
Write-Host "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━" -ForegroundColor Cyan
Write-Host ""
Write-Host "  Your Homey '$selectedAlias' is now configured." -ForegroundColor White
Write-Host ""
Write-Host "  Quick commands (from HomeyPshScripts folder):" -ForegroundColor Cyan
Write-Host "    Export again:  .\Run-Export.ps1 -HomeyAlias '$selectedAlias'" -ForegroundColor Yellow
Write-Host "    List hubs:     .\Run-Export.ps1 -ListHubs" -ForegroundColor Yellow
Write-Host "    Add another:   .\Run-Setup.ps1" -ForegroundColor Yellow
Write-Host "    Network scan:  .\Run-Scan.ps1" -ForegroundColor Yellow
Write-Host ""

# Check if there are other unconfigured Homeys
$allHubs = Get-AllHomeyHubs
$unconfigured = $allHubs | Where-Object { -not (Get-HomeyApiKey -Alias $_.Alias) }

if ($unconfigured.Count -gt 0) {
    Write-Host "  ⚠️ You have $($unconfigured.Count) Homey(s) without API keys:" -ForegroundColor Yellow
    foreach ($item in $unconfigured) {
        Write-Host "     • $($item.Alias)" -ForegroundColor DarkGray
    }
    Write-Host ""
    Write-Host "  Run: .\Run-Setup.ps1 -HomeyAlias '<alias>' to configure them." -ForegroundColor Cyan
    Write-Host ""
}

#endregion
