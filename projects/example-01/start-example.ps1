# Example-01 Project Starter
# Redmine Learning Project

Write-Host ""
Write-Host "========================================" -ForegroundColor Cyan
Write-Host "Example-01 - Redmine Learning Project" -ForegroundColor Cyan
Write-Host "========================================" -ForegroundColor Cyan
Write-Host ""

# Check if Docker is running
try {
    $dockerVersion = docker --version
    Write-Host "Docker is available: $dockerVersion" -ForegroundColor Green
}
catch {
    Write-Host "ERROR: Docker is not running or not installed!" -ForegroundColor Red
    Write-Host "Please start Docker Desktop and try again." -ForegroundColor Yellow
    Read-Host "Press Enter to exit"
    exit 1
}

Write-Host "Starting environment..." -ForegroundColor Yellow
Write-Host ""

# Start the environment
try {
    & "$PSScriptRoot\scripts\manage-example-project.ps1" -Action start
    
    if ($LASTEXITCODE -eq 0) {
        Write-Host ""
        Write-Host "========================================" -ForegroundColor Green
        Write-Host "Environment started successfully!" -ForegroundColor Green
        Write-Host "========================================" -ForegroundColor Green
        Write-Host ""
        Write-Host "Redmine: http://localhost:3000" -ForegroundColor Cyan
        Write-Host "Adminer: http://localhost:8080" -ForegroundColor Cyan
        Write-Host ""
        Write-Host "Default credentials:" -ForegroundColor Yellow
        Write-Host "- Redmine: admin/admin" -ForegroundColor White
        Write-Host "- Adminer: redmine/redmine123" -ForegroundColor White
        Write-Host ""
        
        $openBrowser = Read-Host "Open Redmine in browser? (y/n)"
        if ($openBrowser -eq "y" -or $openBrowser -eq "Y") {
            Start-Process "http://localhost:3000"
        }
    }
    else {
        Write-Host ""
        Write-Host "ERROR: Failed to start environment!" -ForegroundColor Red
        Write-Host "Check the logs above for details." -ForegroundColor Yellow
    }
}
catch {
    Write-Host ""
    Write-Host "ERROR: Exception occurred while starting environment!" -ForegroundColor Red
    Write-Host "Details: $($_.Exception.Message)" -ForegroundColor Red
}

Write-Host ""
Write-Host "========================================" -ForegroundColor Cyan
Write-Host "Example-01 Project Starter completed" -ForegroundColor Cyan
Write-Host "========================================" -ForegroundColor Cyan
Read-Host "Press Enter to exit"
