# Generate API Token Script for Redmine
# Core script - for use in projects

param(
    [Parameter(Mandatory=$true)]
    [string]$ConfigFile,
    
    [string]$CredentialsFile = "",
    [string]$RedmineUrl = "",
    [string]$Username = "",
    [string]$Password = ""
)

# Import common functions
$commonScript = Join-Path $PSScriptRoot "..\common\redmine-common.ps1"
if (Test-Path $commonScript) {
    . $commonScript
} else {
    Write-Error "Common functions not found: $commonScript"
    exit 1
}

function Load-Credentials {
    param([string]$CredentialsFile)
    
    if (-not (Test-Path $CredentialsFile)) {
        throw "Credentials file not found: $CredentialsFile"
    }
    
    try {
        $credentials = @{}
        Get-Content $CredentialsFile | ForEach-Object {
            if ($_ -match '^([^=]+)=(.*)$') {
                $credentials[$matches[1]] = $matches[2]
            }
        }
        
        # Validate required fields
        $required = @('REDMINE_USERNAME', 'REDMINE_PASSWORD', 'REDMINE_URL')
        foreach ($field in $required) {
            if (-not $credentials.ContainsKey($field)) {
                throw "Missing required credential: $field"
            }
        }
        
        return $credentials
    }
    catch {
        throw "Failed to load credentials: $($_.Exception.Message)"
    }
}

function Get-BasicAuthHeader {
    param([string]$Username, [string]$Password)
    $credentials = "${Username}:${Password}"
    $bytes = [System.Text.Encoding]::UTF8.GetBytes($credentials)
    return [Convert]::ToBase64String($bytes)
}

function Get-UserInfo {
    param([string]$RedmineUrl, [string]$AuthHeader)
    
    try {
        $headers = @{
            "Authorization" = "Basic $AuthHeader"
            "Content-Type" = "application/json"
        }
        
        $response = Invoke-RestMethod -Uri "$RedmineUrl/users/current.json" -Headers $headers -Method Get
        return $response.user
    }
    catch {
        Write-Error "Error getting user info: $_"
        return $null
    }
}

function Create-ApiToken {
    param([string]$RedmineUrl, [string]$AuthHeader, [string]$Username)
    
    try {
        $headers = @{
            "Authorization" = "Basic $AuthHeader"
            "Content-Type" = "application/json"
        }
        
        $body = @{
            "key" = @{
                "name" = "AI Manager Token"
                "user_id" = 1
            }
        } | ConvertTo-Json
        
        $response = Invoke-RestMethod -Uri "$RedmineUrl/users/1/api_keys.json" -Headers $headers -Method Post -Body $body
        return $response.api_key.key
    }
    catch {
        Write-Error "Error creating API token: $_"
        return $null
    }
}

function Update-RedmineConfig {
    param([string]$ConfigFile, [string]$ApiToken)
    
    try {
        $config = Get-Content $ConfigFile | ConvertFrom-Json
        $config.redmine.api_token = $ApiToken
        $config.last_updated = (Get-Date).ToString("yyyy-MM-ddTHH:mm:ssZ")
        
        $config | ConvertTo-Json -Depth 10 | Set-Content $ConfigFile
        Write-Host "Updated $ConfigFile with API token" -ForegroundColor Green
        return $true
    }
    catch {
        Write-Error "Error updating config file: $_"
        return $false
    }
}

# Main execution
Write-Host "=== Redmine API Token Generator (Core) ===" -ForegroundColor Cyan
Write-Host "Config File: $ConfigFile" -ForegroundColor Yellow

# Load credentials
if ($CredentialsFile -and (Test-Path $CredentialsFile)) {
    Write-Host "Loading credentials from: $CredentialsFile" -ForegroundColor Yellow
    $credentials = Load-Credentials -CredentialsFile $CredentialsFile
    $RedmineUrl = $credentials['REDMINE_URL']
    $Username = $credentials['REDMINE_USERNAME']
    $Password = $credentials['REDMINE_PASSWORD']
} elseif ($RedmineUrl -and $Username -and $Password) {
    Write-Host "Using provided credentials" -ForegroundColor Yellow
} else {
    Write-Error "Either provide CredentialsFile or all three: RedmineUrl, Username, Password"
    exit 1
}

Write-Host "Redmine URL: $RedmineUrl" -ForegroundColor Yellow
Write-Host "Username: $Username" -ForegroundColor Yellow

# Validate config file
if (-not (Test-Path $ConfigFile)) {
    Write-Error "Config file not found: $ConfigFile"
    exit 1
}

# Get authentication header
$authHeader = Get-BasicAuthHeader -Username $Username -Password $Password

# Get user info to verify connection
Write-Host "`nVerifying connection..." -ForegroundColor Yellow
$userInfo = Get-UserInfo -RedmineUrl $RedmineUrl -AuthHeader $authHeader

if ($userInfo) {
    Write-Host "Connected successfully as: $($userInfo.firstname) $($userInfo.lastname)" -ForegroundColor Green
    Write-Host "User ID: $($userInfo.id)" -ForegroundColor Green
    
    # Create API token
    Write-Host "`nCreating API token..." -ForegroundColor Yellow
    $apiToken = Create-ApiToken -RedmineUrl $RedmineUrl -AuthHeader $authHeader -Username $Username
    
    if ($apiToken) {
        Write-Host "API token created successfully!" -ForegroundColor Green
        Write-Host "Token: $apiToken" -ForegroundColor Green
        
        # Update config file
        if (Update-RedmineConfig -ConfigFile $ConfigFile -ApiToken $apiToken) {
            Write-Host "`nConfiguration updated successfully!" -ForegroundColor Green
            Write-Host "Project is ready for Core script usage" -ForegroundColor Green
        } else {
            Write-Warning "Config file update failed"
        }
    } else {
        Write-Error "Failed to create API token"
        exit 1
    }
} else {
    Write-Error "Failed to connect to Redmine. Check URL and credentials."
    exit 1
}
