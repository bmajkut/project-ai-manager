# Redmine API Router Script
# Version: 1.0.0
# Author: Project AI Manager
# Function: Routes to appropriate Redmine API version script

param(
    [Parameter(Mandatory=$true)]
    [string]$Action,
    
    [Parameter(Mandatory=$false)]
    [string]$ConfigFile = "project-config.json",
    
    [Parameter(Mandatory=$false)]
    [string]$DataFile = "",
    
    [Parameter(Mandatory=$false)]
    [string]$OutputFile = ""
)

# Function for logging
function Write-Log {
    param(
        [string]$Message,
        [string]$Level = "INFO"
    )
    
    $timestamp = Get-Date -Format "yyyy-MM-dd HH:mm:ss"
    $logMessage = "[$timestamp] [$Level] $Message"
    
    switch ($Level) {
        "ERROR" { Write-Host $logMessage -ForegroundColor Red }
        "WARNING" { Write-Host $logMessage -ForegroundColor Yellow }
        "SUCCESS" { Write-Host $logMessage -ForegroundColor Green }
        default { Write-Host $logMessage -ForegroundColor White }
    }
}

# Function to load configuration
function Load-Config {
    param([string]$ConfigPath)
    
    if (!(Test-Path $ConfigPath)) {
        throw "Configuration file not found: $ConfigPath"
    }
    
    try {
        $config = Get-Content $ConfigPath | ConvertFrom-Json
        return $config
    }
    catch {
        throw "Failed to parse configuration file: $($_.Exception.Message)"
    }
}

# Function to determine Redmine version
function Get-RedmineVersion {
    param([object]$Config)
    
    if ($Config.redmine_config.version) {
        return $Config.redmine_config.version
    }
    
    Write-Log "No version in configuration, using default v5.0" "WARNING"
    return "5.0"
}

# Function to map version to directory
function Map-VersionToDirectory {
    param([string]$Version)
    
    if ($Version -match "^5\.") {
        return "v5.0"
    }
    elseif ($Version -match "^4\.") {
        return "v4.2"
    }
    elseif ($Version -match "^3\.") {
        return "v3.4"
    }
    else {
        return "v5.0"  # Default
    }
}

# Function to run appropriate script
function Invoke-RedmineScript {
    param(
        [string]$VersionDir,
        [string]$Action,
        [string]$ConfigFile,
        [string]$DataFile,
        [string]$OutputFile
    )
    
    $scriptPath = Join-Path $PSScriptRoot $VersionDir "redmine-api.ps1"
    
    if (!(Test-Path $scriptPath)) {
        throw "Script for version $VersionDir does not exist: $scriptPath"
    }
    
    Write-Log "Starting script for version $VersionDir"
    
    $params = @{
        Action = $Action
        ConfigFile = $ConfigFile
    }
    
    if ($DataFile) {
        $params.DataFile = $DataFile
    }
    
    if ($OutputFile) {
        $params.OutputFile = $OutputFile
    }
    
    & $scriptPath @params
}

# Main execution
try {
    Write-Log "Redmine API Router started"
    
    # Load configuration
    $config = Load-Config -ConfigPath $ConfigFile
    
    # Get Redmine version
    $redmineVersion = Get-RedmineVersion -Config $config
    Write-Log "Detected Redmine version: $redmineVersion"
    
    # Map to directory
    $versionDir = Map-VersionToDirectory -Version $redmineVersion
    
    # Execute appropriate script
    Invoke-RedmineScript -VersionDir $versionDir -Action $Action -ConfigFile $ConfigFile -DataFile $DataFile -OutputFile $OutputFile
    
    Write-Log "Router completed successfully"
}
catch {
    Write-Log "Critical error: $($_.Exception.Message)" "ERROR"
    exit 1
}
