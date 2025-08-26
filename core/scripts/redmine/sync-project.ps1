#!/usr/bin/env pwsh
# Sync Redmine Data Script for Project AI Manager
# Core script - for use in projects

param(
    [string]$ProjectName = ""
)

# Import common functions
. "$PSScriptRoot\..\common\redmine-common.ps1"

Write-Host "Syncing Redmine data..." -ForegroundColor Green

try {
    # Auto-detect project if not provided
    if ([string]::IsNullOrEmpty($ProjectName)) {
        $ProjectName = Get-CurrentProjectName
        if ([string]::IsNullOrEmpty($ProjectName)) {
            throw "No project name provided and could not auto-detect from current directory. Must be in a project subdirectory."
        }
        Write-Host "Auto-detected project: $ProjectName" -ForegroundColor Cyan
    }
    
    # Validate project exists
    $scriptRoot = Split-Path -Parent $PSScriptRoot
    $workspaceRoot = Split-Path -Parent (Split-Path -Parent $scriptRoot)
    $projectPath = Join-Path $workspaceRoot "projects\$ProjectName"
    if (-not (Test-Path $projectPath)) {
        throw "Project '$ProjectName' not found in projects directory."
    }
    
    # Read project configuration
    $configPath = Join-Path $projectPath "config"
    $projectConfig = Get-Content (Join-Path $configPath "project-config.json") | ConvertFrom-Json
    $redmineConfig = Get-Content (Join-Path $configPath "redmine-config.json") | ConvertFrom-Json
    
            Write-Host "Project: $($projectConfig.project_name)" -ForegroundColor Yellow
        Write-Host "API Token: $($projectConfig.redmine_api_token)" -ForegroundColor Yellow
    
    # Check if Redmine server is accessible
    Write-Host "Checking Redmine connectivity..." -ForegroundColor Yellow
    if (-not (Test-RedmineConnectivity -ApiToken $projectConfig.redmine_api_token -ProjectName $ProjectName -WorkspaceRoot $workspaceRoot)) {
        throw "Cannot connect to Redmine server. Check API token and server accessibility."
    }
    
    # Check if project exists in Redmine
    Write-Host "Checking if project exists in Redmine..." -ForegroundColor Yellow
    $redmineProject = Get-RedmineProject -ProjectName $ProjectName -ApiToken $projectConfig.redmine_api_token -WorkspaceRoot $workspaceRoot
    
    if ($null -eq $redmineProject) {
        # Create project in Redmine
        Write-Host "Creating project in Redmine..." -ForegroundColor Yellow
        $redmineProject = New-RedmineProject -ProjectName $ProjectName -Description $projectConfig.description -ApiToken $projectConfig.redmine_api_token -WorkspaceRoot $workspaceRoot
        Write-Host "Project created in Redmine with ID: $($redmineProject.id)" -ForegroundColor Green
    } else {
        Write-Host "Project already exists in Redmine with ID: $($redmineProject.id)" -ForegroundColor Green
    }
    
    # Create missing core elements
    Write-Host "Creating missing core elements..." -ForegroundColor Yellow
    $createdElements = New-RedmineCoreElements -ProjectId $redmineProject.id -ApiToken $projectConfig.redmine_api_token -WorkspaceRoot $workspaceRoot
    Write-Host "Core elements created/verified" -ForegroundColor Green
    
    # Check if tasks.json exists
    $tasksJsonPath = Join-Path $projectPath "docs\output\tasks.json"
    if (Test-Path $tasksJsonPath) {
        Write-Host "Found tasks.json, creating tasks in Redmine..." -ForegroundColor Yellow
        $tasksData = Get-Content $tasksJsonPath | ConvertFrom-Json
        $createdTasks = New-RedmineTasks -ProjectId $redmineProject.id -TasksData $tasksData -ApiToken $projectConfig.redmine_api_token
        Write-Host "Created $($createdTasks.Count) tasks in Redmine" -ForegroundColor Green
    } else {
        Write-Host "No tasks.json found. Run /generate-output-docs first to create tasks." -ForegroundColor Yellow
    }
    
    # Update configuration files
    Write-Host "Updating configuration files..." -ForegroundColor Yellow
    Update-RedmineConfiguration -ProjectName $ProjectName -RedmineProject $redmineProject -CreatedElements $createdElements
    
    Write-Host "Redmine synchronization completed successfully!" -ForegroundColor Green
    Write-Host "Summary:" -ForegroundColor Cyan
    Write-Host "   - Project ID: $($redmineProject.id)" -ForegroundColor White
    Write-Host "   - Core elements: $($createdElements.Count)" -ForegroundColor White
    if (Test-Path $tasksJsonPath) {
        Write-Host "   - Tasks created: $($createdTasks.Count)" -ForegroundColor White
    }
    
} catch {
    Write-Error "Failed to sync Redmine data: $($_.Exception.Message)"
    exit 1
}
