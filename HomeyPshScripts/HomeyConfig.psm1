<#
.SYNOPSIS
    Homey Configuration Module - Manages config and secure credentials
#>

$script:ConfigFileName = "homey-config.json"
$script:CredentialFileName = "homey-credentials.xml"

function Get-HomeyConfigPath {
    return Join-Path $PSScriptRoot $script:ConfigFileName
}

function Get-HomeyCredentialPath {
    return Join-Path $PSScriptRoot $script:CredentialFileName
}

function Get-HomeyExportPath {
    param(
        [Parameter(Mandatory = $true)]
        [string]$HomeyAlias
    )
    
    $basePath = Join-Path $PSScriptRoot "_hubExport"
    $userPath = Join-Path $basePath $env:USERNAME
    $homeyPath = Join-Path $userPath $HomeyAlias
    
    if (-not (Test-Path $homeyPath)) {
        New-Item -ItemType Directory -Path $homeyPath -Force | Out-Null
    }
    
    return $homeyPath
}

function Get-HomeyConfig {
    $configPath = Get-HomeyConfigPath
    
    if (Test-Path $configPath) {
        $json = Get-Content $configPath -Raw | ConvertFrom-Json
        return $json
    }
    
    # Return default config structure
    return [PSCustomObject]@{
        homeys = [PSCustomObject]@{}
    }
}

function Save-HomeyConfig {
    param(
        [Parameter(Mandatory = $true)]
        [object]$Config
    )
    
    $configPath = Get-HomeyConfigPath
    $Config | ConvertTo-Json -Depth 10 | Set-Content -Path $configPath -Encoding UTF8
    Write-Host "  📝 Config saved to: $configPath" -ForegroundColor Green
}

function Get-HomeyHub {
    param(
        [Parameter(Mandatory = $true)]
        [string]$Alias
    )
    
    $config = Get-HomeyConfig
    
    if ($config.homeys.PSObject.Properties.Name -contains $Alias) {
        return $config.homeys.$Alias
    }
    
    return $null
}

function Set-HomeyHub {
    param(
        [Parameter(Mandatory = $true)]
        [string]$Alias,
        
        [Parameter(Mandatory = $false)]
        [string]$IP,
        
        [Parameter(Mandatory = $false)]
        [string]$Name,
        
        [Parameter(Mandatory = $false)]
        [string]$CloudId,
        
        [Parameter(Mandatory = $false)]
        [string]$Model,
        
        [Parameter(Mandatory = $false)]
        [string]$Version
    )
    
    $config = Get-HomeyConfig
    
    # Ensure homeys property exists as hashtable-like object
    if (-not $config.homeys) {
        $config | Add-Member -NotePropertyName "homeys" -NotePropertyValue ([PSCustomObject]@{}) -Force
    }
    
    # Get or create hub entry
    $hub = $null
    if ($config.homeys.PSObject.Properties.Name -contains $Alias) {
        $hub = $config.homeys.$Alias
    }
    else {
        $hub = [PSCustomObject]@{
            ip = ""
            name = ""
            cloudId = ""
            model = ""
            version = ""
            lastExport = $null
        }
        $config.homeys | Add-Member -NotePropertyName $Alias -NotePropertyValue $hub -Force
    }
    
    # Update provided values
    if ($IP) { $hub.ip = $IP }
    if ($Name) { $hub.name = $Name }
    if ($CloudId) { $hub.cloudId = $CloudId }
    if ($Model) { $hub.model = $Model }
    if ($Version) { $hub.version = $Version }
    
    Save-HomeyConfig -Config $config
    
    return $hub
}

function Remove-HomeyHub {
    param(
        [Parameter(Mandatory = $true)]
        [string]$Alias
    )
    
    $config = Get-HomeyConfig
    
    if ($config.homeys.PSObject.Properties.Name -contains $Alias) {
        $config.homeys.PSObject.Properties.Remove($Alias)
        Save-HomeyConfig -Config $config
        Write-Host "  🗑️ Removed hub: $Alias" -ForegroundColor Yellow
        return $true
    }
    
    return $false
}

function Get-AllHomeyHubs {
    $config = Get-HomeyConfig
    $hubs = @()
    
    foreach ($prop in $config.homeys.PSObject.Properties) {
        $hubs += [PSCustomObject]@{
            Alias = $prop.Name
            Hub = $prop.Value
        }
    }
    
    return $hubs
}

#region Secure Credentials

function Get-HomeyCredentials {
    $credPath = Get-HomeyCredentialPath
    
    if (Test-Path $credPath) {
        try {
            $creds = Import-Clixml -Path $credPath
            return $creds
        }
        catch {
            Write-Host "  ⚠️ Could not load credentials: $($_.Exception.Message)" -ForegroundColor Yellow
            return $null
        }
    }
    
    return $null
}

function Set-HomeyCredentials {
    param(
        [Parameter(Mandatory = $false)]
        [string]$AthomEmail,
        
        [Parameter(Mandatory = $false)]
        [SecureString]$AthomPassword,
        
        [Parameter(Mandatory = $false)]
        [SecureString]$AthomToken,
        
        [Parameter(Mandatory = $false)]
        [hashtable]$ApiKeys  # Alias -> SecureString API Key
    )
    
    $credPath = Get-HomeyCredentialPath
    
    # Load existing or create new
    $creds = Get-HomeyCredentials
    if (-not $creds) {
        $creds = @{
            AthomEmail = ""
            AthomPassword = $null
            AthomToken = $null
            ApiKeys = @{}
        }
    }
    
    # Update provided values
    if ($AthomEmail) { $creds.AthomEmail = $AthomEmail }
    if ($AthomPassword) { $creds.AthomPassword = $AthomPassword }
    if ($AthomToken) { $creds.AthomToken = $AthomToken }
    if ($ApiKeys) {
        foreach ($key in $ApiKeys.Keys) {
            $creds.ApiKeys[$key] = $ApiKeys[$key]
        }
    }
    
    # Export using DPAPI (user-specific encryption)
    $creds | Export-Clixml -Path $credPath -Force
    Write-Host "  🔐 Credentials saved securely to: $credPath" -ForegroundColor Green
}

function Set-HomeyApiKey {
    param(
        [Parameter(Mandatory = $true)]
        [string]$Alias,
        
        [Parameter(Mandatory = $true)]
        [string]$ApiKey
    )
    
    $secureKey = ConvertTo-SecureString -String $ApiKey -AsPlainText -Force
    Set-HomeyCredentials -ApiKeys @{ $Alias = $secureKey }
    Write-Host "  🔑 API key saved for: $Alias" -ForegroundColor Green
}

function Get-HomeyApiKey {
    param(
        [Parameter(Mandatory = $true)]
        [string]$Alias
    )
    
    $creds = Get-HomeyCredentials
    
    if ($creds -and $creds.ApiKeys -and $creds.ApiKeys.ContainsKey($Alias)) {
        $secureKey = $creds.ApiKeys[$Alias]
        # Convert SecureString back to plain text
        $bstr = [System.Runtime.InteropServices.Marshal]::SecureStringToBSTR($secureKey)
        try {
            return [System.Runtime.InteropServices.Marshal]::PtrToStringAuto($bstr)
        }
        finally {
            [System.Runtime.InteropServices.Marshal]::ZeroFreeBSTR($bstr)
        }
    }
    
    return $null
}

function Get-AthomCredential {
    $creds = Get-HomeyCredentials
    
    if (-not $creds -or -not $creds.AthomEmail) {
        return $null
    }
    
    $result = @{
        Email = $creds.AthomEmail
        Password = $null
        Token = $null
    }
    
    if ($creds.AthomPassword) {
        $bstr = [System.Runtime.InteropServices.Marshal]::SecureStringToBSTR($creds.AthomPassword)
        try {
            $result.Password = [System.Runtime.InteropServices.Marshal]::PtrToStringAuto($bstr)
        }
        finally {
            [System.Runtime.InteropServices.Marshal]::ZeroFreeBSTR($bstr)
        }
    }
    
    if ($creds.AthomToken) {
        $bstr = [System.Runtime.InteropServices.Marshal]::SecureStringToBSTR($creds.AthomToken)
        try {
            $result.Token = [System.Runtime.InteropServices.Marshal]::PtrToStringAuto($bstr)
        }
        finally {
            [System.Runtime.InteropServices.Marshal]::ZeroFreeBSTR($bstr)
        }
    }
    
    return $result
}

function Set-AthomCredential {
    param(
        [Parameter(Mandatory = $true)]
        [string]$Email,
        
        [Parameter(Mandatory = $false)]
        [string]$Password,
        
        [Parameter(Mandatory = $false)]
        [string]$Token
    )
    
    $securePassword = if ($Password) { ConvertTo-SecureString -String $Password -AsPlainText -Force } else { $null }
    $secureToken = if ($Token) { ConvertTo-SecureString -String $Token -AsPlainText -Force } else { $null }
    
    Set-HomeyCredentials -AthomEmail $Email -AthomPassword $securePassword -AthomToken $secureToken
}

#endregion

# Export module members
Export-ModuleMember -Function @(
    'Get-HomeyConfigPath',
    'Get-HomeyCredentialPath',
    'Get-HomeyExportPath',
    'Get-HomeyConfig',
    'Save-HomeyConfig',
    'Get-HomeyHub',
    'Set-HomeyHub',
    'Remove-HomeyHub',
    'Get-AllHomeyHubs',
    'Get-HomeyCredentials',
    'Set-HomeyCredentials',
    'Set-HomeyApiKey',
    'Get-HomeyApiKey',
    'Get-AthomCredential',
    'Set-AthomCredential'
)
