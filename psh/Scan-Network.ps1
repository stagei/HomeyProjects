<#
.SYNOPSIS
    Scans the local network for all devices and identifies Homey devices.

.DESCRIPTION
    This script scans your local network to discover all active devices,
    identifies known device types (Homey, Hue, routers, etc.),
    and saves results to a JSON file.

.EXAMPLE
    .\Scan-Network.ps1
    .\Scan-Network.ps1 -OutputFile "my-network.json"
#>

[CmdletBinding()]
param(
    [Parameter(Mandatory = $false)]
    [string]$OutputFile = "network-scan.json"
)

function Write-Banner {
    Write-Host ""
    Write-Host "╔════════════════════════════════════════════════════════╗" -ForegroundColor Cyan
    Write-Host "║           NETWORK SCANNER - Device Discovery           ║" -ForegroundColor Cyan
    Write-Host "╚════════════════════════════════════════════════════════╝" -ForegroundColor Cyan
    Write-Host ""
}

function Get-LocalNetworkInfo {
    Write-Host "🔍 Detecting local network configuration..." -ForegroundColor Yellow
    
    $adapter = Get-NetIPConfiguration | Where-Object { 
        $_.IPv4DefaultGateway -ne $null -and 
        $_.NetAdapter.Status -eq "Up" 
    } | Select-Object -First 1
    
    if (-not $adapter) {
        return $null
    }
    
    $ip = $adapter.IPv4Address.IPAddress
    $gateway = $adapter.IPv4DefaultGateway.NextHop
    $prefix = $adapter.IPv4Address.PrefixLength
    $mac = (Get-NetAdapter -InterfaceIndex $adapter.InterfaceIndex).MacAddress
    
    $ipParts = $ip.Split('.')
    $networkBase = "$($ipParts[0]).$($ipParts[1]).$($ipParts[2])"
    
    Write-Host "  Adapter: $($adapter.InterfaceAlias)" -ForegroundColor White
    Write-Host "    Local IP: $ip" -ForegroundColor DarkGray
    Write-Host "    Gateway: $gateway" -ForegroundColor DarkGray
    Write-Host "    Network: $networkBase.0/$prefix" -ForegroundColor DarkGray
    
    return @{
        AdapterName = $adapter.InterfaceAlias
        LocalIP = $ip
        Gateway = $gateway
        MAC = $mac
        NetworkBase = $networkBase
        PrefixLength = $prefix
    }
}

function Test-TcpPort {
    param(
        [string]$IP,
        [int]$Port,
        [int]$Timeout = 500
    )
    
    try {
        $client = New-Object System.Net.Sockets.TcpClient
        $result = $client.BeginConnect($IP, $Port, $null, $null)
        $success = $result.AsyncWaitHandle.WaitOne($Timeout, $false)
        $client.Close()
        return $success
    }
    catch {
        return $false
    }
}

function Get-DeviceType {
    param(
        [string]$IP,
        [string]$Hostname,
        [string]$WebContent,
        [string]$ServerHeader
    )
    
    # Check hostname patterns
    if ($Hostname -match "chromecast") { return "Google Chromecast" }
    if ($Hostname -match "audiocast") { return "Audio Streaming Device" }
    if ($Hostname -match "homey") { return "Athom Homey" }
    if ($Hostname -match "RT-AX|ASUS|router") { return "ASUS Router" }
    
    # Check web content
    if ($WebContent) {
        if ($WebContent -match "hue personal wireless lighting") { return "Philips Hue Bridge" }
        if ($WebContent -match "Main_Login\.asp") { return "ASUS Router/AP" }
        if ($WebContent -match "homey|athom") { return "Athom Homey" }
        if ($WebContent -match "sonos") { return "Sonos Speaker" }
        if ($WebContent -match "ikea|tradfri") { return "IKEA Gateway" }
    }
    
    return $null
}

function Check-IsHomey {
    param([string]$IP)
    
    foreach ($protocol in @("http", "https")) {
        try {
            $apiUrl = "$($protocol)://$IP/api/manager/system"
            $response = Invoke-RestMethod -Uri $apiUrl -Method Get -TimeoutSec 2 -ErrorAction Stop
            
            if ($response.homeyVersion -or $response.name -or $response.model) {
                return @{
                    IsHomey = $true
                    Info = @{
                        Name = $response.name
                        Version = $response.homeyVersion
                        Model = $response.model
                        ModelName = $response.modelName
                        CloudId = $response.cloudId
                    }
                }
            }
        }
        catch {}
    }
    
    return @{ IsHomey = $false; Info = $null }
}

function Get-WebServerInfo {
    param([string]$IP)
    
    try {
        $response = Invoke-WebRequest -Uri "http://$IP" -TimeoutSec 3 -UseBasicParsing -ErrorAction Stop
        
        $server = $response.Headers["Server"]
        $title = ""
        if ($response.Content -match "<title>([^<]+)</title>") {
            $title = $Matches[1]
        }
        
        return @{
            HasWeb = $true
            Server = $server
            Title = $title
            Content = $response.Content
        }
    }
    catch {
        return @{ HasWeb = $false; Server = $null; Title = $null; Content = $null }
    }
}

function Scan-Network {
    param([hashtable]$NetworkInfo)
    
    $networkBase = $NetworkInfo.NetworkBase
    
    Write-Host "`n🔎 Scanning network $networkBase.0/24..." -ForegroundColor Yellow
    
    $devices = @()
    $startTime = Get-Date
    
    # Phase 1: Ping sweep to populate ARP cache
    Write-Host "`n  Phase 1: ARP Discovery (pinging network)..." -ForegroundColor Cyan
    
    $total = 254
    for ($i = 1; $i -le 254; $i++) {
        $ip = "$networkBase.$i"
        
        if ($i % 25 -eq 0) {
            Write-Progress -Activity "Pinging network" -Status "$ip ($i/$total)" -PercentComplete (($i / $total) * 100)
        }
        
        $ping = New-Object System.Net.NetworkInformation.Ping
        try { $ping.Send($ip, 50) | Out-Null } catch {}
        $ping.Dispose()
    }
    Write-Progress -Activity "Pinging network" -Completed
    
    # Phase 2: Read ARP cache
    Write-Host "  Phase 2: Reading ARP cache..." -ForegroundColor Cyan
    
    $arpEntries = Get-NetNeighbor -AddressFamily IPv4 | Where-Object {
        $_.State -in @("Reachable", "Stale", "Permanent") -and
        $_.IPAddress -like "$networkBase.*" -and
        $_.IPAddress -ne "$networkBase.255"
    }
    
    Write-Host "    Found $($arpEntries.Count) devices" -ForegroundColor Green
    
    # Phase 3: Gather device details
    Write-Host "  Phase 3: Analyzing devices..." -ForegroundColor Cyan
    
    $total = $arpEntries.Count
    $current = 0
    
    foreach ($entry in $arpEntries) {
        $current++
        $ip = $entry.IPAddress
        $mac = $entry.LinkLayerAddress
        
        Write-Progress -Activity "Analyzing devices" -Status "$ip ($current/$total)" -PercentComplete (($current / $total) * 100)
        
        # Resolve hostname
        $hostname = "Unknown"
        try { $hostname = ([System.Net.Dns]::GetHostEntry($ip)).HostName } catch {}
        
        # Check for web server
        $hasWeb = Test-TcpPort -IP $ip -Port 80
        $webInfo = @{ HasWeb = $false; Server = $null; Title = $null; Content = $null }
        
        if ($hasWeb) {
            $webInfo = Get-WebServerInfo -IP $ip
        }
        
        # Check if Homey
        $homeyCheck = @{ IsHomey = $false; Info = $null }
        if ($hostname -match "homey" -or $hasWeb) {
            $homeyCheck = Check-IsHomey -IP $ip
        }
        
        # Determine device type
        $deviceType = Get-DeviceType -IP $ip -Hostname $hostname -WebContent $webInfo.Content -ServerHeader $webInfo.Server
        
        if ($homeyCheck.IsHomey) {
            $deviceType = "Athom Homey"
        }
        
        # Check additional ports
        $openPorts = @()
        if ($hasWeb) { $openPorts += 80 }
        if (Test-TcpPort -IP $ip -Port 443) { $openPorts += 443 }
        if (Test-TcpPort -IP $ip -Port 22) { $openPorts += 22 }
        
        $device = @{
            IP = $ip
            MAC = $mac
            Hostname = $hostname
            Type = $deviceType
            OpenPorts = $openPorts
            WebServer = $webInfo.Server
            WebTitle = $webInfo.Title
            IsHomey = $homeyCheck.IsHomey
            HomeyInfo = $homeyCheck.Info
        }
        
        $devices += $device
    }
    
    Write-Progress -Activity "Analyzing devices" -Completed
    
    $elapsed = (Get-Date) - $startTime
    Write-Host "  ✅ Scan complete in $([math]::Round($elapsed.TotalSeconds, 1)) seconds" -ForegroundColor Green
    
    # Sort by IP
    $devices = $devices | Sort-Object { 
        $parts = $_.IP.Split('.')
        [int]$parts[0] * 16777216 + [int]$parts[1] * 65536 + [int]$parts[2] * 256 + [int]$parts[3]
    }
    
    return $devices
}

# Main execution
Write-Banner

# Get network info
$networkInfo = Get-LocalNetworkInfo

if (-not $networkInfo) {
    Write-Host "❌ No active network adapters found!" -ForegroundColor Red
    exit 1
}

# Scan network
$devices = Scan-Network -NetworkInfo $networkInfo

# Build results
$homeyDevices = @($devices | Where-Object { $_.IsHomey -eq $true })
$identifiedDevices = @($devices | Where-Object { $_.Type -ne $null })

$results = @{
    ScanTime = (Get-Date).ToString("o")
    Network = @{
        Adapter = $networkInfo.AdapterName
        LocalIP = $networkInfo.LocalIP
        Gateway = $networkInfo.Gateway
        Range = "$($networkInfo.NetworkBase).0/$($networkInfo.PrefixLength)"
    }
    DeviceCount = $devices.Count
    IdentifiedCount = $identifiedDevices.Count
    Devices = $devices
    HomeyDevices = $homeyDevices
}

# Save to JSON
$outputPath = Join-Path $PSScriptRoot $OutputFile
$results | ConvertTo-Json -Depth 10 | Set-Content -Path $outputPath -Encoding UTF8

Write-Host "`n📄 Results saved to: $outputPath" -ForegroundColor Green

# Display results
Write-Host "`n" -NoNewline
Write-Host "════════════════════════════════════════════════════════" -ForegroundColor Cyan
Write-Host "                    SCAN RESULTS                        " -ForegroundColor Cyan
Write-Host "════════════════════════════════════════════════════════" -ForegroundColor Cyan

Write-Host "`n  Network: $($networkInfo.NetworkBase).0/24" -ForegroundColor White
Write-Host "  Total devices: $($devices.Count)" -ForegroundColor White
Write-Host "  Identified: $($identifiedDevices.Count)" -ForegroundColor White

# Device table
Write-Host "`n  ┌─────────────────┬───────────────────┬────────────────────────────────┐" -ForegroundColor DarkGray
Write-Host "  │ IP Address      │ MAC Address       │ Device / Hostname              │" -ForegroundColor DarkGray
Write-Host "  ├─────────────────┼───────────────────┼────────────────────────────────┤" -ForegroundColor DarkGray

foreach ($dev in $devices) {
    $ipCol = $dev.IP.PadRight(15)
    $macCol = $dev.MAC.PadRight(17)
    
    $nameCol = if ($dev.Type) { 
        $dev.Type 
    } elseif ($dev.Hostname -ne "Unknown") { 
        $dev.Hostname 
    } else { 
        "(Unknown)" 
    }
    $nameCol = $nameCol.Substring(0, [Math]::Min(30, $nameCol.Length)).PadRight(30)
    
    $color = if ($dev.IsHomey) { "Green" } 
             elseif ($dev.Type) { "Yellow" } 
             else { "DarkGray" }
    
    $marker = if ($dev.IsHomey) { " 🏠" } else { "" }
    
    Write-Host "  │ $ipCol │ $macCol │ $nameCol │$marker" -ForegroundColor $color
}

Write-Host "  └─────────────────┴───────────────────┴────────────────────────────────┘" -ForegroundColor DarkGray

# Homey section
Write-Host "`n" -NoNewline
Write-Host "════════════════════════════════════════════════════════" -ForegroundColor Cyan
Write-Host "                   HOMEY DETECTION                      " -ForegroundColor Cyan
Write-Host "════════════════════════════════════════════════════════" -ForegroundColor Cyan

if ($homeyDevices.Count -gt 0) {
    Write-Host "`n  🏠 FOUND $($homeyDevices.Count) HOMEY DEVICE(S)!" -ForegroundColor Green
    
    foreach ($homey in $homeyDevices) {
        Write-Host "`n  ────────────────────────────────────────" -ForegroundColor DarkGray
        Write-Host "    IP Address: $($homey.IP)" -ForegroundColor White
        Write-Host "    MAC: $($homey.MAC)" -ForegroundColor DarkGray
        
        if ($homey.HomeyInfo) {
            Write-Host "    Name: $($homey.HomeyInfo.Name)" -ForegroundColor Cyan
            Write-Host "    Model: $($homey.HomeyInfo.ModelName)" -ForegroundColor DarkGray
            Write-Host "    Version: $($homey.HomeyInfo.Version)" -ForegroundColor DarkGray
        }
        
        Write-Host "`n    ✅ Export data with:" -ForegroundColor Green
        Write-Host "       .\Export-Homey.ps1 -HomeyIP '$($homey.IP)' -HomeyName 'MyHomey'" -ForegroundColor Yellow
    }
}
else {
    Write-Host "`n  ⚠️  No Homey devices detected on this network." -ForegroundColor Yellow
    Write-Host ""
    Write-Host "  Possible reasons:" -ForegroundColor DarkGray
    Write-Host "    • Homey is on a different network/location" -ForegroundColor DarkGray
    Write-Host "    • Homey requires API authentication" -ForegroundColor DarkGray
    Write-Host "    • Homey is offline" -ForegroundColor DarkGray
    
    # Suggest web devices
    $webDevices = @($devices | Where-Object { $_.OpenPorts -contains 80 -and -not $_.Type })
    if ($webDevices.Count -gt 0) {
        Write-Host "`n  💡 Unidentified devices with web interfaces:" -ForegroundColor Cyan
        foreach ($dev in $webDevices) {
            Write-Host "     • http://$($dev.IP)" -ForegroundColor Yellow
        }
    }
}

# Smart home devices summary
$smartHomeDevices = @($devices | Where-Object { $_.Type -match "Hue|Chromecast|Sonos|IKEA" })
if ($smartHomeDevices.Count -gt 0) {
    Write-Host "`n  🔌 Other smart home devices found:" -ForegroundColor Cyan
    foreach ($dev in $smartHomeDevices) {
        Write-Host "     • $($dev.Type) at $($dev.IP)" -ForegroundColor DarkGray
    }
}

Write-Host "`n"
