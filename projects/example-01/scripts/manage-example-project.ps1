# Example Project Management Script
# Version: 1.0.0
# Author: Project AI Manager
# Function: Manage Docker environment for Example-01 learning project

param(
    [Parameter(Mandatory=$true)]
    [string]$Action,
    
    [Parameter(Mandatory=$false)]
    [string]$BackupFile = ""
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

# Function to check Docker
function Test-Docker {
    try {
        $dockerVersion = docker --version
        if ($LASTEXITCODE -eq 0) {
            Write-Log "Docker is available: $dockerVersion"
            return $true
        }
        else {
            Write-Log "Docker is not working properly" "ERROR"
            return $false
        }
    }
    catch {
        Write-Log "Docker is not installed or not in PATH" "ERROR"
        return $false
    }
}

# Function to start environment
function Start-Environment {
    Write-Log "Starting Example-01 learning environment..."
    
    try {
        # Check if containers are already running
        $running = docker-compose ps --services --filter "status=running" 2>$null
        if ($running) {
            Write-Log "Environment is already running" "WARNING"
            return
        }
        
        # Start the environment
        Write-Log "Starting Docker Compose services..."
        docker-compose up -d
        
        if ($LASTEXITCODE -eq 0) {
            Write-Log "Environment started successfully!" "SUCCESS"
            Write-Log "Redmine: http://localhost:3000 (admin/admin)"
            Write-Log "Adminer: http://localhost:8080 (redmine/redmine123)"
            Write-Log "PostgreSQL: localhost:5432 (redmine/redmine123)"
        }
        else {
            Write-Log "Failed to start environment" "ERROR"
            throw "Docker Compose failed to start"
        }
    }
    catch {
        Write-Log "Error starting environment: $($_.Exception.Message)" "ERROR"
        throw
    }
}

# Function to stop environment
function Stop-Environment {
    Write-Log "Stopping Example-01 learning environment..."
    
    try {
        docker-compose down
        if ($LASTEXITCODE -eq 0) {
            Write-Log "Environment stopped successfully" "SUCCESS"
        }
        else {
            Write-Log "Failed to stop environment" "ERROR"
        }
    }
    catch {
        Write-Log "Error stopping environment: $($_.Exception.Message)" "ERROR"
    }
}

# Function to reset environment
function Reset-Environment {
    Write-Log "Resetting Example-01 learning environment..."
    
    try {
        # Stop and remove everything
        docker-compose down -v --remove-orphans
        if ($LASTEXITCODE -eq 0) {
            Write-Log "Environment reset successfully" "SUCCESS"
        }
        else {
            Write-Log "Failed to reset environment" "ERROR"
        }
    }
    catch {
        Write-Log "Error resetting environment: $($_.Exception.Message)" "ERROR"
    }
}

# Function to perform full cleanup
function Invoke-FullCleanup {
    Write-Log "Performing full cleanup of Redmine data..."
    
    try {
        # Stop environment
        docker-compose down
        
        # Remove all containers, networks, and volumes
        docker-compose down -v --remove-orphans
        docker system prune -f
        
        # Remove any remaining data
        if (Test-Path "backups") {
            Remove-Item "backups\*" -Recurse -Force
        }
        
        Write-Log "Full cleanup completed!"
        
        # Start fresh environment
        Start-Environment
    }
    catch {
        Write-Log "Error during cleanup: $($_.Exception.Message)" "ERROR"
        throw
    }
}

# Function to create backup
function New-Backup {
    Write-Log "Creating backup of Example-01 environment..."
    
    try {
        # Create backups directory if it doesn't exist
        if (!(Test-Path "backups")) {
            New-Item -ItemType Directory -Path "backups" -Force | Out-Null
        }
        
        $timestamp = Get-Date -Format "yyyyMMdd_HHmmss"
        $backupFile = "backups\backup_$timestamp.sql"
        
        # Create database backup
        docker exec redmine-example-postgres pg_dump -U redmine redmine > $backupFile
        
        if ($LASTEXITCODE -eq 0) {
            Write-Log "Backup completed successfully!" "SUCCESS"
            Write-Log "Backup saved to: $backupFile"
        }
        else {
            Write-Log "Failed to create backup" "ERROR"
        }
    }
    catch {
        Write-Log "Error creating backup: $($_.Exception.Message)" "ERROR"
        throw
    }
}

# Function to restore from backup
function Restore-Backup {
    param([string]$BackupFile)
    
    if (!$BackupFile) {
        throw "BackupFile parameter is required for restore action"
    }
    
    if (!(Test-Path $BackupFile)) {
        throw "Backup file not found: $BackupFile"
    }
    
    Write-Log "Restoring from backup: $BackupFile"
    
    try {
        # Stop environment
        docker-compose down
        
        # Start PostgreSQL only
        docker-compose up -d postgres
        
        # Wait for PostgreSQL to be ready
        Start-Sleep -Seconds 10
        
        # Restore database
        Get-Content $BackupFile | docker exec -i redmine-example-postgres psql -U redmine -d redmine
        
        if ($LASTEXITCODE -eq 0) {
            Write-Log "Backup restored successfully!" "SUCCESS"
            
            # Start full environment
            docker-compose up -d
        }
        else {
            Write-Log "Failed to restore backup" "ERROR"
        }
    }
    catch {
        Write-Log "Error restoring backup: $($_.Exception.Message)" "ERROR"
        throw
    }
}

# Function to check status
function Get-Status {
    Write-Log "Checking Example-01 environment status..."
    
    try {
        $status = docker-compose ps
        Write-Host $status
        
        # Check if services are healthy
        $healthy = docker-compose ps --services --filter "status=running" 2>$null
        if ($healthy) {
            Write-Log "All services are running" "SUCCESS"
        }
        else {
            Write-Log "Some services are not running" "WARNING"
        }
    }
    catch {
        Write-Log "Error checking status: $($_.Exception.Message)" "ERROR"
    }
}

# Function to view logs
function Get-Logs {
    param([string]$Service = "")
    
    Write-Log "Getting logs for Example-01 environment..."
    
    try {
        if ($Service) {
            docker-compose logs $Service
        }
        else {
            docker-compose logs
        }
    }
    catch {
        Write-Log "Error getting logs: $($_.Exception.Message)" "ERROR"
    }
}

# Main execution
try {
    Write-Log "Example-01 Project Manager started"
    
    # Check Docker availability
    if (!(Test-Docker)) {
        Write-Log "Docker is required but not available" "ERROR"
        exit 1
    }
    
    # Execute requested action
    switch ($Action.ToLower()) {
        "start" {
            Start-Environment
        }
        
        "stop" {
            Stop-Environment
        }
        
        "reset" {
            Reset-Environment
        }
        
        "cleanup" {
            Invoke-FullCleanup
        }
        
        "backup" {
            New-Backup
        }
        
        "restore" {
            Restore-Backup -BackupFile $BackupFile
        }
        
        "status" {
            Get-Status
        }
        
        "logs" {
            Get-Logs
        }
        
        default {
            Write-Host @"
Example-01 Project Manager - Available Actions:

start     - Start the learning environment
stop      - Stop the learning environment
reset     - Reset environment (remove all data)
cleanup   - Full cleanup and restart
backup    - Create database backup
restore   - Restore from backup file
status    - Check environment status
logs      - View environment logs

Examples:
  .\manage-example-project.ps1 -Action start
  .\manage-example-project.ps1 -Action backup
  .\manage-example-project.ps1 -Action restore -BackupFile backups\backup_20240824_120000.sql
"@
        }
    }
    
    Write-Log "Operation completed successfully"
}
catch {
    Write-Log "Critical error: $($_.Exception.Message)" "ERROR"
    exit 1
}
finally {
    Write-Log "Example-01 Project Manager completed"
}
