#!/usr/bin/env pwsh
# Create Project Script for Project AI Manager
# Core script - for use in projects

param(
    [Parameter(Mandatory=$true)]
    [string]$ProjectName,
    
    [Parameter(Mandatory=$true)]
    [string]$Login,
    
    [Parameter(Mandatory=$true)]
    [string]$Password,
    
    [string]$Url = "http://localhost:3000",
    [string]$Template = "default",
    [string]$Description = "",
    [string]$Type = "web-app",
    [string]$Framework = "",
    [switch]$Force
)

# Import common functions
. "$PSScriptRoot\..\common\project-common.ps1"

Write-Host "Creating new project: $ProjectName" -ForegroundColor Green

try {
    # Validate project name
    if (-not (Test-ProjectName -ProjectName $ProjectName)) {
        throw "Invalid project name: $ProjectName. Use lowercase with hyphens only."
    }
    
    # Check if project exists
    $projectPath = "..\..\projects\$ProjectName"
    if ((Test-Path $projectPath) -and -not $Force) {
        throw "Project '$ProjectName' already exists. Use --force to overwrite."
    }
    
    # Validate template
    if (-not (Test-Template -Template $Template)) {
        throw "Template '$Template' not found. Available templates: $(Get-AvailableTemplates)"
    }
    
    # Create project structure
    Write-Host "Creating project structure..." -ForegroundColor Yellow
    New-ProjectStructure -ProjectName $ProjectName -Template $Template
    
    # Generate Redmine API token using Base64 encoding
    Write-Host "Generating Redmine API token..." -ForegroundColor Yellow
    $apiToken = [Convert]::ToBase64String([System.Text.Encoding]::UTF8.GetBytes("${Login}:${Password}"))
    
    # Customize configuration with token and URL
    Write-Host "Customizing configuration..." -ForegroundColor Yellow
    Set-ProjectConfiguration -ProjectName $ProjectName -Description $Description -Type $Type -Framework $Framework -ApiToken $apiToken -RedmineUrl $Url -Login $Login -Password $Password
    
    # Generate project files
    Write-Host "Generating project files..." -ForegroundColor Yellow
    New-ProjectFiles -ProjectName $ProjectName -Template $Template -ApiToken $apiToken
    
    # Setup git repository
    Write-Host "Setting up git repository..." -ForegroundColor Yellow
    Initialize-GitRepository -ProjectPath $projectPath
    
    Write-Host "Project '$ProjectName' created successfully!" -ForegroundColor Green
    Write-Host "Location: $((Resolve-Path $projectPath).Path)" -ForegroundColor Cyan
    Write-Host "Next steps:" -ForegroundColor Yellow
    Write-Host "  1. cd projects\$ProjectName" -ForegroundColor White
    Write-Host "  2. Review configuration files" -ForegroundColor White
    Write-Host "  3. Add input documentation to docs/input/" -ForegroundColor White
    Write-Host "  4. Use /generate-output-docs to create specifications" -ForegroundColor White
    
} catch {
    Write-Error "Failed to create project: $($_.Exception.Message)"
    exit 1
}
