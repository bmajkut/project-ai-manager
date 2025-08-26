#!/usr/bin/env pwsh
# Redmine Example 01 - Start Script (PowerShell)
# This script starts the Redmine learning environment and automatically seeds data

# Colors for output
$Green = "Green"
$Yellow = "Yellow"
$Red = "Red"
$Cyan = "Cyan"

function Write-Info {
    param([string]$Message)
    Write-Host "[INFO] $Message" -ForegroundColor $Cyan
}

function Write-Success {
    param([string]$Message)
    Write-Host "[SUCCESS] $Message" -ForegroundColor $Green
}

function Write-Warning {
    param([string]$Message)
    Write-Host "[WARNING] $Message" -ForegroundColor $Yellow
}

function Write-Error {
    param([string]$Message)
    Write-Host "[ERROR] $Message" -ForegroundColor $Red
}

# Check if Docker is running
function Test-Docker {
    try {
        docker version | Out-Null
        return $true
    }
    catch {
        return $false
    }
}

# Check if Docker Compose is available
function Test-DockerCompose {
    try {
        docker-compose version | Out-Null
        return $true
    }
    catch {
        return $false
    }
}

# Generate API token for Redmine using Core script
function Start-TokenGeneration {
    Write-Info "Starting API token generation using Core script..."
    
    $coreScript = Join-Path $PSScriptRoot "..\..\core\scripts\windows\redmine\generate-api-token.ps1"
    $configFile = Join-Path $PSScriptRoot "config\config.json"
    
    if (Test-Path $coreScript) {
        try {
            Write-Info "Running Core token generation script: $coreScript"
            Write-Info "Config file: $configFile"
            
            & $coreScript -ConfigFile $configFile -CredentialsFile (Join-Path $PSScriptRoot "config\credentials.env")
            if ($LASTEXITCODE -eq 0) {
                Write-Success "API token generated successfully using Core script!"
                return $true
            } else {
                Write-Warning "Token generation completed with warnings"
                return $true
            }
        }
        catch {
            Write-Error "Error running Core token generation script: $($_.Exception.Message)"
            return $false
        }
    } else {
        Write-Error "Core token generation script not found: $coreScript"
        return $false
    }
}

# Main execution
Write-Host "=== Redmine Example 01 - Start Script ===" -ForegroundColor $Green
Write-Host "Starting Redmine learning environment..." -ForegroundColor $Cyan
Write-Host ""

# Check prerequisites
if (-not (Test-Docker)) {
    Write-Error "Docker is not running or not installed. Please start Docker Desktop."
    Read-Host "Press Enter to exit"
    exit 1
}

if (-not (Test-DockerCompose)) {
    Write-Error "Docker Compose is not available. Please install Docker Compose."
    Read-Host "Press Enter to exit"
    exit 1
}

Write-Success "Docker and Docker Compose are available"

# Create data directories if they don't exist
if (-not (Test-Path "data/postgres")) {
    Write-Info "Creating data directories..."
    New-Item -ItemType Directory -Path "data/postgres" -Force | Out-Null
    Write-Success "Data directories created"
}

# Start Docker services
Write-Info "Starting Docker services..."
try {
    docker-compose up -d
    if ($LASTEXITCODE -eq 0) {
        Write-Success "Docker services started successfully"
    } else {
        Write-Error "Failed to start Docker services"
        exit 1
    }
}
catch {
    Write-Error "Error starting Docker services: $($_.Exception.Message)"
    exit 1
}

# Wait for services to be ready
Write-Info "Waiting for services to start..."
$waitCount = 0
$maxWait = 20  # Maximum 10 minutes (20 * 30 seconds)

do {
    Start-Sleep -Seconds 30
    $waitCount++
    
    try {
        $response = Invoke-WebRequest -Uri "http://localhost:3000" -Method GET -TimeoutSec 5 -ErrorAction Stop
        if ($response.StatusCode -eq 200) {
            Write-Success "Redmine is now accessible!"
            break
        }
    }
    catch {
        if ($waitCount -ge $maxWait) {
            Write-Warning "Redmine is taking longer than expected to start"
            Write-Info "You can check the status with: docker-compose ps"
            Write-Info "View logs with: docker-compose logs -f redmine"
            break
        }
        Write-Info "Still waiting for Redmine to start... ($($waitCount * 30)s)"
    }
} while ($waitCount -lt $maxWait)

# Display service status
Write-Info "Service status:"
docker-compose ps

Write-Host ""
Write-Success "Redmine learning environment is ready!"
Write-Host ""

# Generate API token
Write-Info "Starting API token generation process..."
$tokenSuccess = Start-TokenGeneration

if ($tokenSuccess) {
    Write-Host ""
    Write-Success "Environment setup completed successfully!"
    Write-Host ""
    Write-Host "Access URLs:" -ForegroundColor $Yellow
    Write-Host "  Redmine: http://localhost:3000" -ForegroundColor $Cyan
    Write-Host "  Adminer: http://localhost:8080" -ForegroundColor $Cyan
    Write-Host ""
    Write-Host "Default credentials:" -ForegroundColor $Yellow
    Write-Host "  Username: admin" -ForegroundColor $Cyan
    Write-Host "  Password: Zaq1xsw@" -ForegroundColor $Cyan
    Write-Host ""
    Write-Host "What's ready:" -ForegroundColor $Yellow
    Write-Host "  ✅ Redmine application running" -ForegroundColor $Cyan
    Write-Host "  ✅ API token generated" -ForegroundColor $Cyan
    Write-Host "  ✅ Configuration files updated" -ForegroundColor $Cyan
    Write-Host "  ✅ Ready for AI integration testing" -ForegroundColor $Cyan
} else {
    Write-Host ""
    Write-Warning "Environment started but token generation failed"
    Write-Host "You can run token generation manually: .\..\..\core\scripts\windows\redmine\generate-api-token.ps1 -ConfigFile config\config.json" -ForegroundColor $Yellow
}

Write-Host ""
Write-Host "Useful commands:" -ForegroundColor $Yellow
Write-Host "  View logs: docker-compose logs -f" -ForegroundColor $Cyan
Write-Host "  Stop services: docker-compose down" -ForegroundColor $Cyan
Write-Host "  Restart: docker-compose restart" -ForegroundColor $Cyan
Write-Host "  Manual token generation: .\..\..\core\scripts\windows\redmine\generate-api-token.ps1 -ConfigFile config\config.json" -ForegroundColor $Cyan

Read-Host "Press Enter to exit"
