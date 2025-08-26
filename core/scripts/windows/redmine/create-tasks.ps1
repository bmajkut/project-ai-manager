# Redmine Task Creator
# Core Script for Project AI Manager
# Purpose: Create tasks from JSON data

param(
    [Parameter(Mandatory=$true)]
    [string]$ConfigFile,
    
    [Parameter(Mandatory=$true)]
    [string]$TasksFile,
    
    [Parameter(Mandatory=$false)]
    [string]$OutputDir = "docs/output"
)

# Import common functions
. "$PSScriptRoot\..\common\redmine-common.ps1"

function Load-TasksData {
    param([string]$TasksPath)
    
    if (!(Test-Path $TasksPath)) {
        throw "Tasks file not found: $TasksPath"
    }
    
    try {
        $tasksData = Get-Content $TasksPath | ConvertFrom-Json
        return $tasksData
    }
    catch {
        throw "Failed to parse tasks file: $($_.Exception.Message)"
    }
}

function Validate-TasksData {
    param([object]$TasksData)
    
    # Validate project section
    $requiredProjectFields = @("name", "identifier")
    Validate-JsonSchema -Data $TasksData.project -RequiredFields $requiredProjectFields
    
    # Validate versions section
    if ($TasksData.versions) {
        foreach ($version in $TasksData.versions) {
            $requiredVersionFields = @("name", "description")
            Validate-JsonSchema -Data $version -RequiredFields $requiredVersionFields
        }
    }
    
    # Validate tasks section
    if (-not $TasksData.tasks) {
        throw "No tasks found in tasks data"
    }
    
    $requiredTaskFields = @("subject", "description", "tracker", "priority", "estimated_hours")
    foreach ($task in $TasksData.tasks) {
        Validate-JsonSchema -Data $task -RequiredFields $requiredTaskFields
    }
    
    Write-Log "Tasks data validation passed" "SUCCESS"
}

function Create-RedmineVersion {
    param(
        [object]$Version,
        [int]$ProjectId,
        [string]$AuthHeader,
        [string]$BaseUrl
    )
    
    try {
        $versionData = @{
            version = @{
                name = $Version.name
                description = $Version.description
                status = "open"
            }
        }
        
        if ($Version.due_date) {
            $versionData.version.due_date = $Version.due_date
        }
        
        $response = Invoke-RedmineAction -Endpoint "/projects/$ProjectId/versions.json" -AuthHeader $AuthHeader -Method "POST" -Body $versionData -BaseUrl $BaseUrl
        
        Write-Log "Created version '$($Version.name)' (ID: $($response.version.id))" "SUCCESS"
        return $response.version
    }
    catch {
        Write-Log "Failed to create version '$($Version.name)': $($_.Exception.Message)" "ERROR"
        return $null
    }
}

function Create-RedmineTask {
    param(
        [object]$Task,
        [int]$ProjectId,
        [object]$VersionMap,
        [string]$AuthHeader,
        [string]$BaseUrl
    )
    
    try {
        # Get required Redmine elements
        $tracker = Get-RedmineTracker -TrackerName $Task.tracker -AuthHeader $AuthHeader -BaseUrl $BaseUrl
        if (-not $tracker) {
            throw "Tracker '$($Task.tracker)' not found"
        }
        
        $status = Get-RedmineStatus -StatusName "New" -AuthHeader $AuthHeader -BaseUrl $BaseUrl
        if (-not $status) {
            throw "Status 'New' not found"
        }
        
        $priority = Get-RedminePriority -PriorityName $Task.priority -AuthHeader $AuthHeader -BaseUrl $BaseUrl
        if (-not $priority) {
            throw "Priority '$($Task.priority)' not found"
        }
        
        # Prepare task data
        $taskData = @{
            issue = @{
                project_id = $ProjectId
                subject = $Task.subject
                description = Format-RedmineDescription -Description $Task.description
                tracker_id = $tracker.id
                status_id = $status.id
                priority_id = $priority.id
                estimated_hours = $Task.estimated_hours
            }
        }
        
        # Add version if specified
        if ($Task.version -and $VersionMap.ContainsKey($Task.version)) {
            $taskData.issue.fixed_version_id = $VersionMap[$Task.version]
        }
        
        # Add start date if specified
        if ($Task.start_date) {
            $taskData.issue.start_date = $Task.start_date
        }
        
        # Add due date if specified
        if ($Task.due_date) {
            $taskData.issue.due_date = $Task.due_date
        }
        
        # Create task
        $response = Invoke-RedmineAction -Endpoint "/issues.json" -AuthHeader $AuthHeader -Method "POST" -Body $taskData -BaseUrl $BaseUrl
        
        Write-Log "Created task '$($Task.subject)' (ID: $($response.issue.id))" "SUCCESS"
        
        # Log operation
        Write-OperationLog -Operation "Create Task" -Details "Task '$($Task.subject)' created with ID $($response.issue.id)" -Status "SUCCESS"
        
        return $response.issue
    }
    catch {
        Write-Log "Failed to create task '$($Task.subject)': $($_.Exception.Message)" "ERROR"
        Write-OperationLog -Operation "Create Task" -Details "Task '$($Task.subject)' creation failed: $($_.Exception.Message)" -Status "ERROR"
        return $null
    }
}

function Process-TasksCreation {
    param(
        [object]$TasksData,
        [string]$AuthHeader,
        [string]$BaseUrl
    )
    
    $results = @{
        ProjectId = $null
        VersionsCreated = @()
        TasksCreated = @()
        Errors = @()
    }
    
    try {
        # 1. Get or create project
        $project = Get-RedmineProject -ProjectName $TasksData.project.name -AuthHeader $AuthHeader -BaseUrl $BaseUrl
        
        if (-not $project) {
            Write-Log "Project '$($TasksData.project.name)' not found. Please create it manually or use project creation script." "WARNING"
            $results.Errors += "Project '$($TasksData.project.name)' not found"
            return $results
        }
        
        $results.ProjectId = $project.id
        Write-Log "Using existing project '$($TasksData.project.name)' (ID: $($project.id))" "INFO"
        
        # 2. Create versions if specified
        $versionMap = @{}
        if ($TasksData.versions) {
            Write-Log "Processing versions..." "INFO"
            
            foreach ($version in $TasksData.versions) {
                $existingVersion = Get-RedmineVersion -VersionName $version.name -ProjectId $project.id -AuthHeader $AuthHeader -BaseUrl $BaseUrl
                
                if ($existingVersion) {
                    Write-Log "Version '$($version.name)' already exists (ID: $($existingVersion.id))" "INFO"
                    $versionMap[$version.name] = $existingVersion.id
                } else {
                    $createdVersion = Create-RedmineVersion -Version $version -ProjectId $project.id -AuthHeader $AuthHeader -BaseUrl $BaseUrl
                    if ($createdVersion) {
                        $versionMap[$version.name] = $createdVersion.id
                        $results.VersionsCreated += $createdVersion
                    }
                }
            }
        }
        
        # 3. Create tasks
        Write-Log "Processing tasks..." "INFO"
        
        foreach ($task in $TasksData.tasks) {
            $createdTask = Create-RedmineTask -Task $task -ProjectId $project.id -VersionMap $versionMap -AuthHeader $AuthHeader -BaseUrl $BaseUrl
            
            if ($createdTask) {
                $results.TasksCreated += $createdTask
            } else {
                $results.Errors += "Failed to create task '$($task.subject)'"
            }
        }
        
        return $results
    }
    catch {
        $errorMessage = $_.Exception.Message
        Write-Log "Error during task creation: $errorMessage" "ERROR"
        $results.Errors += $errorMessage
        return $results
    }
}

function Write-ResultsSummary {
    param(
        [object]$Results,
        [string]$OutputDir
    )
    
    # Ensure output directory exists
    if (-not (Test-Path $OutputDir)) {
        New-Item -ItemType Directory -Path $OutputDir -Force | Out-Null
    }
    
    $summaryPath = Join-Path $OutputDir "task-creation-summary.md"
    
    $markdownContent = @"
# Task Creation Summary

## Results

- **Project ID:** $($Results.ProjectId)
- **Versions Created:** $($Results.VersionsCreated.Count)
- **Tasks Created:** $($Results.TasksCreated.Count)
- **Errors:** $($Results.Errors.Count)

## Created Versions

"@
    
    if ($Results.VersionsCreated.Count -gt 0) {
        foreach ($version in $Results.VersionsCreated) {
            $markdownContent += @"
- **$($version.name)** (ID: $($version.id)) - $($version.description)
"@
        }
    } else {
        $markdownContent += @"
No new versions were created.
"@
    }
    
    $markdownContent += @"

## Created Tasks

"@
    
    if ($Results.TasksCreated.Count -gt 0) {
        foreach ($task in $Results.TasksCreated) {
            $markdownContent += @"
- **$($task.subject)** (ID: $($task.id)) - $($task.estimated_hours)h
"@
        }
    } else {
        $markdownContent += @"
No tasks were created.
"@
    }
    
    if ($Results.Errors.Count -gt 0) {
        $markdownContent += @"

## Errors

"@
        foreach ($error in $Results.Errors) {
            $markdownContent += @"
- $error
"@
        }
    }
    
    try {
        $markdownContent | Out-File -FilePath $summaryPath -Encoding UTF8
        Write-Log "Results summary written to: $summaryPath" "SUCCESS"
    }
    catch {
        Write-Log "Failed to write results summary: $($_.Exception.Message)" "ERROR"
    }
}

# Main execution
try {
    Write-Log "Redmine Task Creator started" "INFO"
    
    # Load configuration
    $config = Load-ProjectConfig -ConfigPath $ConfigFile
    $redmineConfig = $config.redmine_config
    
    # Load tasks data
    $tasksData = Load-TasksData -TasksPath $TasksFile
    
    # Validate tasks data
    Validate-TasksData -TasksData $tasksData
    
    # Get Redmine connection details
    $authHeader = Get-BasicAuthHeader -Username $redmineConfig.username -Password $redmineConfig.password
    $baseUrl = $redmineConfig.url
    
    # Test connection
    Write-Log "Testing Redmine connection..." "INFO"
    if (-not (Test-RedmineConnection -AuthHeader $authHeader -BaseUrl $baseUrl)) {
        throw "Failed to connect to Redmine at $baseUrl"
    }
    Write-Log "Redmine connection successful" "SUCCESS"
    
    # Process task creation
    $results = Process-TasksCreation -TasksData $tasksData -AuthHeader $authHeader -BaseUrl $baseUrl
    
    # Write results summary
    Write-ResultsSummary -Results $results -OutputDir $OutputDir
    
    # Final summary
    Write-Log "Task creation completed" "INFO"
    Write-Log "Project ID: $($results.ProjectId)" "INFO"
    Write-Log "Versions created: $($results.VersionsCreated.Count)" "INFO"
    Write-Log "Tasks created: $($Results.TasksCreated.Count)" "INFO"
    Write-Log "Errors: $($results.Errors.Count)" "INFO"
    
    if ($results.Errors.Count -eq 0) {
        Write-Log "All tasks created successfully!" "SUCCESS"
        exit 0
    } else {
        Write-Log "Task creation completed with errors. Check summary for details." "WARNING"
        exit 1
    }
}
catch {
    Write-Log "Critical error: $($_.Exception.Message)" "ERROR"
    exit 1
}
