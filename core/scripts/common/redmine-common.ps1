# Common Redmine Functions for Project AI Manager

function Get-CurrentProjectName {
    # Get current directory and check if we're in a project subdirectory
    $currentPath = Get-Location
    $pathParts = $currentPath.Path -split '\\'
    
    # Look for 'projects' in the path
    for ($i = 0; $i -lt $pathParts.Length; $i++) {
        if ($pathParts[$i] -eq 'projects' -and $i + 1 -lt $pathParts.Length) {
            return $pathParts[$i + 1]
        }
    }
    
    return $null
}

function Test-RedmineConnectivity {
    param([string]$ApiToken, [string]$ProjectName = "", [string]$WorkspaceRoot = "")
    
    try {
        # Get Redmine URL from project config
        if ([string]::IsNullOrEmpty($WorkspaceRoot)) {
            $scriptRoot = Split-Path -Parent $PSScriptRoot
            $WorkspaceRoot = Split-Path -Parent (Split-Path -Parent $scriptRoot)
        }
        $projectPath = Join-Path $WorkspaceRoot "projects\$ProjectName"
        $redmineConfigPath = Join-Path $projectPath "config\redmine-config.json"
        
        if (-not (Test-Path $redmineConfigPath)) {
            Write-Host "   Redmine config not found" -ForegroundColor Yellow
            return $false
        }
        
        $redmineConfig = Get-Content $redmineConfigPath | ConvertFrom-Json
        $redmineUrl = $redmineConfig.redmine_url
        
        # Test connection by calling Redmine API
        $headers = @{
            'Authorization' = "Basic $ApiToken"
            'Content-Type' = 'application/json'
        }
        
        $response = Invoke-RestMethod -Uri "$redmineUrl/projects.json" -Method GET -Headers $headers -TimeoutSec 10
        Write-Host "   Successfully connected to Redmine at $redmineUrl" -ForegroundColor Green
        return $true
        
    } catch {
        Write-Host "   Failed to connect to Redmine: $($_.Exception.Message)" -ForegroundColor Yellow
        return $false
    }
}

function Get-RedmineProject {
    param([string]$ProjectName, [string]$ApiToken, [string]$WorkspaceRoot = "")
    
    try {
        # Get Redmine URL from project config
        if ([string]::IsNullOrEmpty($WorkspaceRoot)) {
            $scriptRoot = Split-Path -Parent $PSScriptRoot
            $WorkspaceRoot = Split-Path -Parent (Split-Path -Parent $scriptRoot)
        }
        $projectPath = Join-Path $WorkspaceRoot "projects\$ProjectName"
        $redmineConfigPath = Join-Path $projectPath "config\redmine-config.json"
        
        $redmineConfig = Get-Content $redmineConfigPath | ConvertFrom-Json
        $redmineUrl = $redmineConfig.redmine_url
        
        Write-Host "   Checking if project '$ProjectName' exists in Redmine..." -ForegroundColor Gray
        
        # Query Redmine API for project
        $headers = @{
            'Authorization' = "Basic $ApiToken"
            'Content-Type' = 'application/json'
        }
        
        # Try to get project by name
        $response = Invoke-RestMethod -Uri "$redmineUrl/projects.json?name=$ProjectName" -Method GET -Headers $headers -TimeoutSec 10
        
        if ($response.projects -and $response.projects.Count -gt 0) {
            $project = $response.projects[0]
            Write-Host "   Found project '$ProjectName' with ID $($project.id)" -ForegroundColor Green
            return $project
        } else {
            Write-Host "   Project '$ProjectName' not found in Redmine" -ForegroundColor Yellow
            return $null
        }
        
    } catch {
        Write-Host "   Error checking project: $($_.Exception.Message)" -ForegroundColor Yellow
        return $null
    }
}

function New-RedmineProject {
    param([string]$ProjectName, [string]$Description, [string]$ApiToken, [string]$WorkspaceRoot = "")
    
    try {
        # Get Redmine URL from project config
        if ([string]::IsNullOrEmpty($WorkspaceRoot)) {
            $scriptRoot = Split-Path -Parent $PSScriptRoot
            $WorkspaceRoot = Split-Path -Parent (Split-Path -Parent $scriptRoot)
        }
        $projectPath = Join-Path $WorkspaceRoot "projects\$ProjectName"
        $redmineConfigPath = Join-Path $projectPath "config\redmine-config.json"
        
        $redmineConfig = Get-Content $redmineConfigPath | ConvertFrom-Json
        $redmineUrl = $redmineConfig.redmine_url
        
        Write-Host "   Creating project '$ProjectName' in Redmine..." -ForegroundColor Gray
        
        # Create project via Redmine API
        $headers = @{
            'Authorization' = "Basic $ApiToken"
            'Content-Type' = 'application/json'
        }
        
        $body = @{
            project = @{
                name = $ProjectName
                description = $Description
                identifier = $ProjectName.ToLower().Replace(' ', '-').Replace('_', '-')
                is_public = $true
            }
        } | ConvertTo-Json
        
        $response = Invoke-RestMethod -Uri "$redmineUrl/projects.json" -Method POST -Headers $headers -Body $body -TimeoutSec 30
        
        Write-Host "   Project created successfully with ID $($response.project.id)" -ForegroundColor Green
        return $response.project
        
    } catch {
        Write-Host "   Error creating project: $($_.Exception.Message)" -ForegroundColor Yellow
        return $null
    }
}

function New-RedmineCoreElements {
    param([int]$ProjectId, [string]$ApiToken, [string]$WorkspaceRoot = "")
    
    try {
        # Get Redmine URL from project config
        if ([string]::IsNullOrEmpty($WorkspaceRoot)) {
            $scriptRoot = Split-Path -Parent $PSScriptRoot
            $WorkspaceRoot = Split-Path -Parent (Split-Path -Parent $scriptRoot)
        }
        $projectPath = Join-Path $WorkspaceRoot "projects\$ProjectName"
        $redmineConfigPath = Join-Path $projectPath "config\redmine-config.json"
        
        $redmineConfig = Get-Content $redmineConfigPath | ConvertFrom-Json
        $redmineUrl = $redmineConfig.redmine_url
        
        Write-Host "   Creating core elements for project ID $ProjectId..." -ForegroundColor Gray
        
        $elements = @()
        
        # Get existing trackers, statuses, and priorities from Redmine
        $headers = @{
            'Authorization' = "Basic $ApiToken"
            'Content-Type' = 'application/json'
        }
        
        # Get trackers
        try {
            $trackersResponse = Invoke-RestMethod -Uri "$redmineUrl/trackers.json" -Method GET -Headers $headers -TimeoutSec 10
            foreach ($tracker in $trackersResponse.trackers) {
                $elements += @{ type = "tracker"; name = $tracker.name; id = $tracker.id }
            }
            Write-Host "   Retrieved $($trackersResponse.trackers.Count) trackers" -ForegroundColor Green
        } catch {
            Write-Host "   Warning: Could not retrieve trackers: $($_.Exception.Message)" -ForegroundColor Yellow
        }
        
        # Get issue statuses
        try {
            $statusesResponse = Invoke-RestMethod -Uri "$redmineUrl/issue_statuses.json" -Method GET -Headers $headers -TimeoutSec 10
            foreach ($status in $statusesResponse.issue_statuses) {
                $elements += @{ type = "status"; name = $status.name; id = $status.id }
            }
            Write-Host "   Retrieved $($statusesResponse.issue_statuses.Count) statuses" -ForegroundColor Green
        } catch {
            Write-Host "   Warning: Could not retrieve statuses: $($_.Exception.Message)" -ForegroundColor Yellow
        }
        
        # Get priorities
        try {
            $prioritiesResponse = Invoke-RestMethod -Uri "$redmineUrl/enumerations.json?type=IssuePriority" -Method GET -Headers $headers -TimeoutSec 10
            foreach ($priority in $prioritiesResponse.issue_priorities) {
                $elements += @{ type = "priority"; name = $priority.name; id = $priority.id }
            }
            Write-Host "   Retrieved $($prioritiesResponse.issue_priorities.Count) priorities" -ForegroundColor Green
        } catch {
            Write-Host "   Warning: Could not retrieve priorities: $($_.Exception.Message)" -ForegroundColor Yellow
        }
        
        return $elements
    } catch {
        Write-Host "   Error creating core elements: $($_.Exception.Message)" -ForegroundColor Yellow
        return @()
    }
}

function New-RedmineTasks {
    param([int]$ProjectId, [object]$TasksData, [string]$ApiToken)
    
    try {
        # For now, create mock tasks
        # In real implementation, this would create tasks via Redmine API
        Write-Host "   Creating tasks for project ID $ProjectId..." -ForegroundColor Gray
        
        $createdTasks = @()
        
        if ($TasksData.tasks) {
            foreach ($task in $TasksData.tasks) {
                $createdTask = @{
                    id = Get-Random -Minimum 10000 -Maximum 99999
                    subject = $task.subject
                    description = $task.description
                    tracker_id = 3  # task tracker
                    status_id = 1   # new status
                    priority_id = 2 # normal priority
                    project_id = $ProjectId
                }
                $createdTasks += $createdTask
            }
        }
        
        return $createdTasks
    } catch {
        Write-Host "   Error creating tasks: $($_.Exception.Message)" -ForegroundColor Yellow
        return @()
    }
}

function Update-RedmineConfiguration {
    param([string]$ProjectName, [object]$RedmineProject, [array]$CreatedElements)
    
    try {
        $scriptRoot = Split-Path -Parent $PSScriptRoot
        $workspaceRoot = Split-Path -Parent (Split-Path -Parent $scriptRoot)
        $projectPath = Join-Path $workspaceRoot "projects\$ProjectName"
        $configPath = Join-Path $projectPath "config"
        $redmineConfigPath = Join-Path $configPath "redmine-config.json"
        
        # Read existing config
        $redmineConfig = Get-Content $redmineConfigPath | ConvertFrom-Json
        
        # Create new config object with updated data
        $updatedConfig = @{
            api_token = $redmineConfig.api_token
            status = "synchronized"
            redmine_url = $redmineConfig.redmine_url
            project_name = $redmineConfig.project_name
            created_date = $redmineConfig.created_date
            redmine_project_id = $RedmineProject.id
            last_sync = (Get-Date).ToString("yyyy-MM-dd HH:mm:ss")
            core_elements = $CreatedElements
        }
        
        # Save updated config
        $updatedConfig | ConvertTo-Json -Depth 5 | Out-File -FilePath $redmineConfigPath -Encoding UTF8
        
        Write-Host "   Updated redmine-config.json" -ForegroundColor Green
    } catch {
        Write-Host "   Error updating configuration: $($_.Exception.Message)" -ForegroundColor Yellow
    }
}
