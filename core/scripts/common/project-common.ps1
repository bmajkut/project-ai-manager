# Common Project Functions for Project AI Manager

function Test-ProjectName {
    param([string]$ProjectName)
    if ($ProjectName -match '^[a-z0-9-]+$') { return $true }
    return $false
}

function Test-Template {
    param([string]$Template)
    $templates = @("default", "web-app", "mobile-app", "api", "library", "redmine")
    return $templates -contains $Template
}

function Get-AvailableTemplates {
    return @("default", "web-app", "mobile-app", "api", "library", "redmine") -join ", "
}

function New-ProjectStructure {
    param([string]$ProjectName, [string]$Template)
    
    $scriptRoot = Split-Path -Parent $PSScriptRoot
    $workspaceRoot = Split-Path -Parent (Split-Path -Parent $scriptRoot)
    $projectPath = Join-Path $workspaceRoot "projects\$ProjectName"
    
    Write-Host "Project path: $projectPath" -ForegroundColor Cyan
    
    New-Item -ItemType Directory -Path $projectPath -Force | Out-Null
    
    $dirs = @("config", "docs\input", "docs\output", "data", "src", "tests")
    foreach ($dir in $dirs) {
        $fullPath = Join-Path $projectPath $dir
        New-Item -ItemType Directory -Path $fullPath -Force | Out-Null
    }
    
    Write-Host "Created directory structure" -ForegroundColor Green
}

function Set-ProjectConfiguration {
    param([string]$ProjectName, [string]$Description, [string]$Type, [string]$Framework, [string]$ApiToken, [string]$RedmineUrl, [string]$Login, [string]$Password)
    
    $scriptRoot = Split-Path -Parent $PSScriptRoot
    $workspaceRoot = Split-Path -Parent (Split-Path -Parent $scriptRoot)
    $projectPath = Join-Path $workspaceRoot "projects\$ProjectName"
    $configPath = Join-Path $projectPath "config"
    
    # Create project configuration
    $projectConfig = @{
        project_name = $ProjectName
        description = $Description
        type = $Type
        framework = $Framework
        created_date = (Get-Date).ToString("yyyy-MM-dd HH:mm:ss")
        created_by = "Cursor AI Manager"
        version = "1.0.0"
        redmine_api_token = $ApiToken
    } | ConvertTo-Json -Depth 3
    
    $projectConfig | Out-File -FilePath (Join-Path $configPath "project-config.json") -Encoding UTF8
    
    # Create Redmine configuration
    $redmineConfig = @{
        project_name = $ProjectName
        api_token = $ApiToken
        redmine_url = $RedmineUrl
        created_date = (Get-Date).ToString("yyyy-MM-dd HH:mm:ss")
        status = "initialized"
    } | ConvertTo-Json -Depth 3
    
    $redmineConfig | Out-File -FilePath (Join-Path $configPath "redmine-config.json") -Encoding UTF8
    
    # Create credentials file from template
    $templatePath = Join-Path $workspaceRoot "core\templates\credentials.env"
    if (Test-Path $templatePath) {
        $credentialsTemplate = Get-Content $templatePath -Raw
        $credentials = $credentialsTemplate -replace "your_username_here", $Login -replace "your_password_here", $Password -replace "your_api_token_here", $ApiToken -replace "http://localhost:3000", $RedmineUrl
        $credentials | Out-File -FilePath (Join-Path $projectPath "credentials.env") -Encoding UTF8
    } else {
        # Fallback if template not found
        $credentials = @"
# Redmine Credentials
REDMINE_URL=$RedmineUrl
REDMINE_USERNAME=$Login
REDMINE_PASSWORD=$Password
REDMINE_API_TOKEN=$ApiToken
"@
        $credentials | Out-File -FilePath (Join-Path $projectPath "credentials.env") -Encoding UTF8
    }
    
    Write-Host "Created configuration files and credentials" -ForegroundColor Green
}

function New-ProjectFiles {
    param([string]$ProjectName, [string]$Template, [string]$ApiToken)
    
    $scriptRoot = Split-Path -Parent $PSScriptRoot
    $workspaceRoot = Split-Path -Parent (Split-Path -Parent $scriptRoot)
    $projectPath = Join-Path $workspaceRoot "projects\$ProjectName"
    
    $readme = "# $ProjectName`n`n## Overview`n$Description`n`n## Project Type`n$Template`n`n## Structure`n- config/ - Project configuration`n- docs/input/ - Input requirements`n- docs/output/ - Generated specifications`n- data/ - Project data`n- src/ - Source code`n- tests/ - Tests`n`n## Getting Started`n1. Review configuration in config/`n2. Add input documentation to docs/input/`n3. Use AI Manager commands to generate specifications`n4. Use Core scripts for Redmine integration"
    
    $readme | Out-File -FilePath (Join-Path $projectPath "README.md") -Encoding UTF8
    
    $cursorRules = "# Cursor AI Rules for $ProjectName`n`n## Project Context`nThis is a project-specific configuration file for $ProjectName.`n`n## AI Manager Integration`n- Use Core scripts for all operations`n- Generate documentation via AI analysis`n- Integrate with Redmine for task management`n- Follow established project patterns`n`n## Project Type`n$Template`n`n## Available Commands`n- /generate-output-docs - Generate project specifications`n- /fetch-redmine-tasks - Fetch tasks from Redmine`n- /create-redmine-tasks - Create tasks in Redmine`n`n## Notes`n- All business logic is in Core scripts`n- This file contains only project-specific rules`n- Follow Core/Projects separation principle"
    
    $cursorRules | Out-File -FilePath (Join-Path $projectPath ".cursorrules") -Encoding UTF8
    
    $gitignore = "# Project-specific ignores`ndata/*.db`ndata/*.log`ndata/temp/`.env.local`n*.tmp`n*.cache"
    
    $gitignore | Out-File -FilePath (Join-Path $projectPath ".gitignore") -Encoding UTF8
    
    Write-Host "Created project files" -ForegroundColor Green
}



function Initialize-GitRepository {
    param([string]$ProjectPath)
    
    try {
        Push-Location $ProjectPath
        git init | Out-Null
        git add . | Out-Null
        git commit -m "Initial project setup via AI Manager" | Out-Null
        Write-Host "Initialized git repository" -ForegroundColor Green
    } catch {
        Write-Host "Git initialization failed: $($_.Exception.Message)" -ForegroundColor Yellow
    } finally {
        Pop-Location
    }
}
