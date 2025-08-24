# Cross-Platform Script Manager
# Version: 1.0.0
# Author: Project AI Manager
# Function: Automatically detects OS and runs appropriate scripts

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

# Function to detect operating system
function Get-OperatingSystem {
    if ($IsWindows -or $env:OS -eq "Windows_NT") {
        return "Windows"
    }
    elseif ($IsLinux) {
        return "Linux"
    }
    elseif ($IsMacOS) {
        return "macOS"
    }
    else {
        # Fallback detection
        $os = [System.Environment]::OSVersion
        if ($os.Platform -eq [System.PlatformID]::Win32NT) {
            return "Windows"
        }
        elseif ($os.Platform -eq [System.PlatformID]::Unix) {
            return "Linux"
        }
        else {
            return "Unknown"
        }
    }
}

# Function to get script extension based on OS
function Get-ScriptExtension {
    param([string]$OS)
    
    switch ($OS) {
        "Windows" { return ".ps1" }
        "Linux" { return ".sh" }
        "macOS" { return ".sh" }
        default { return ".ps1" }
    }
}

# Function to get script directory based on OS
function Get-ScriptDirectory {
    param([string]$OS)
    
    switch ($OS) {
        "Windows" { return "windows" }
        "Linux" { return "linux" }
        "macOS" { return "linux" }
        default { return "windows" }
    }
}

# Function to run script based on OS
function Invoke-PlatformScript {
    param(
        [string]$OS,
        [string]$ScriptPath,
        [hashtable]$Parameters
    )
    
    switch ($OS) {
        "Windows" {
            # Run PowerShell script
            & $ScriptPath @Parameters
        }
        "Linux" {
            # Run Bash script
            bash $ScriptPath @Parameters
        }
        "macOS" {
            # Run Bash script
            bash $ScriptPath @Parameters
        }
        default {
            throw "Unsupported operating system: $OS"
        }
    }
}

# Function to check if script exists for current OS
function Test-PlatformScript {
    param(
        [string]$ScriptName,
        [string]$OS
    )
    
    $scriptDir = Get-ScriptDirectory -OS $OS
    $scriptExt = Get-ScriptExtension -OS $OS
    $scriptPath = Join-Path $PSScriptRoot $scriptDir "$ScriptName$scriptExt"
    
    return Test-Path $scriptPath
}

# Function to get script path for current OS
function Get-PlatformScriptPath {
    param(
        [string]$ScriptName,
        [string]$OS
    )
    
    $scriptDir = Get-ScriptDirectory -OS $OS
    $scriptExt = Get-ScriptExtension -OS $OS
    $scriptPath = Join-Path $PSScriptRoot $scriptDir "$ScriptName$scriptExt"
    
    if (!(Test-Path $scriptPath)) {
        throw "Script not found for $OS: $scriptPath"
    }
    
    return $scriptPath
}

# Main logic
try {
    $currentOS = Get-OperatingSystem
    Write-Host "Detected operating system: $currentOS" -ForegroundColor Green
    
    # Check if we have scripts for this OS
    if (!(Test-PlatformScript -ScriptName "redmine-api" -OS $currentOS)) {
        Write-Host "Warning: No scripts found for $currentOS, falling back to Windows scripts" -ForegroundColor Yellow
        $currentOS = "Windows"
    }
    
    # Get the appropriate script path
    $scriptPath = Get-PlatformScriptPath -ScriptName "redmine-api" -OS $currentOS
    Write-Host "Using script: $scriptPath" -ForegroundColor Cyan
    
    # Build parameters
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
    
    # Run the platform-specific script
    Write-Host "Executing $currentOS script with action: $Action" -ForegroundColor Cyan
    Invoke-PlatformScript -OS $currentOS -ScriptPath $scriptPath -Parameters $params
    
    Write-Host "Script execution completed successfully" -ForegroundColor Green
}
catch {
    Write-Host "Critical error: $($_.Exception.Message)" -ForegroundColor Red
    exit 1
}
finally {
    Write-Host "Cross-platform script manager completed" -ForegroundColor Cyan
}
