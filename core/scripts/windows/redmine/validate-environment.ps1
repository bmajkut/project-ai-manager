# Redmine Environment Validator
# Core Script for Project AI Manager
# Purpose: Validate Redmine environment completeness

param(
    [Parameter(Mandatory=$true)]
    [string]$ConfigFile,
    
    [Parameter(Mandatory=$false)]
    [string]$OutputDir = "docs/output"
)

# Import common functions
. "$PSScriptRoot\..\..\common\redmine-common.ps1"

function Test-RedmineEnvironment {
    param(
        [object]$Config,
        [string]$AuthHeader
    )
    
    $validationResults = @{
        ProjectExists = $false
        ProjectId = $null
        MissingStatuses = @()
        MissingTrackers = @()
        MissingPriorities = @()
        MissingVersions = @()
        UserActionsRequired = @()
    }
    
    Write-Log "Starting Redmine environment validation..." "INFO"
    
    # 1. Check if project exists
    try {
        $projectName = $Config.project_info.name
        $projects = Get-RedmineData -Endpoint "/projects.json" -AuthHeader $AuthHeader
        
        if ($projects.projects) {
            $project = $projects.projects | Where-Object { $_.name -eq $projectName }
            if ($project) {
                $validationResults.ProjectExists = $true
                $validationResults.ProjectId = $project.id
                Write-Log "Project '$projectName' found (ID: $($project.id))" "SUCCESS"
            } else {
                Write-Log "Project '$projectName' not found" "WARNING"
                $validationResults.UserActionsRequired += "Create project '$projectName' in Redmine"
            }
        }
    }
    catch {
        Write-Log "Failed to check project existence: $($_.Exception.Message)" "ERROR"
        $validationResults.UserActionsRequired += "Check Redmine connectivity and permissions"
    }
    
    # 2. Check issue statuses
    try {
        $statuses = Get-RedmineData -Endpoint "/issue_statuses.json" -AuthHeader $AuthHeader
        $requiredStatuses = @("New", "In Progress", "Resolved", "Closed")
        
        foreach ($requiredStatus in $requiredStatuses) {
            if ($statuses.issue_statuses.name -notcontains $requiredStatus) {
                $validationResults.MissingStatuses += $requiredStatus
            }
        }
        
        if ($validationResults.MissingStatuses.Count -gt 0) {
            Write-Log "Missing issue statuses: $($validationResults.MissingStatuses -join ', ')" "WARNING"
            $validationResults.UserActionsRequired += "Create missing issue statuses: $($validationResults.MissingStatuses -join ', ')"
        } else {
            Write-Log "All required issue statuses are present" "SUCCESS"
        }
    }
    catch {
        Write-Log "Failed to check issue statuses: $($_.Exception.Message)" "ERROR"
        $validationResults.UserActionsRequired += "Check Redmine permissions for issue statuses"
    }
    
    # 3. Check trackers
    try {
        $trackers = Get-RedmineData -Endpoint "/trackers.json" -AuthHeader $AuthHeader
        $requiredTrackers = @("Task", "Bug", "Feature")
        
        foreach ($requiredTracker in $requiredTrackers) {
            if ($trackers.trackers.name -notcontains $requiredTracker) {
                $validationResults.MissingTrackers += $requiredTracker
            }
        }
        
        if ($validationResults.MissingTrackers.Count -gt 0) {
            Write-Log "Missing trackers: $($validationResults.MissingTrackers -join ', ')" "WARNING"
            $validationResults.UserActionsRequired += "Create missing trackers: $($validationResults.MissingTrackers -join ', ')"
        } else {
            Write-Log "All required trackers are present" "SUCCESS"
        }
    }
    catch {
        Write-Log "Failed to check trackers: $($_.Exception.Message)" "ERROR"
        $validationResults.UserActionsRequired += "Check Redmine permissions for trackers"
    }
    
    # 4. Check issue priorities
    try {
        $priorities = Get-RedmineData -Endpoint "/enumerations.json?type=IssuePriority" -AuthHeader $AuthHeader
        $requiredPriorities = @("Low", "Normal", "High")
        
        foreach ($requiredPriority in $requiredPriorities) {
            if ($priorities.issue_priorities.name -notcontains $requiredPriority) {
                $validationResults.MissingPriorities += $requiredPriority
            }
        }
        
        if ($validationResults.MissingPriorities.Count -gt 0) {
            Write-Log "Missing issue priorities: $($validationResults.MissingPriorities -join ', ')" "WARNING"
            $validationResults.UserActionsRequired += "Create missing issue priorities: $($validationResults.MissingPriorities -join ', ')"
        } else {
            Write-Log "All required issue priorities are present" "SUCCESS"
        }
    }
    catch {
        Write-Log "Failed to check issue priorities: $($_.Exception.Message)" "ERROR"
        $validationResults.UserActionsRequired += "Check Redmine permissions for issue priorities"
    }
    
    # 5. Check versions if project exists
    if ($validationResults.ProjectExists) {
        try {
            $versions = Get-RedmineData -Endpoint "/projects/$($validationResults.ProjectId)/versions.json" -AuthHeader $AuthHeader
            
            if (-not $versions.versions -or $versions.versions.Count -eq 0) {
                Write-Log "No versions found for project" "WARNING"
                $validationResults.UserActionsRequired += "Create versions for project '$projectName'"
            } else {
                Write-Log "Project has $($versions.versions.Count) versions" "SUCCESS"
            }
        }
        catch {
            Write-Log "Failed to check project versions: $($_.Exception.Message)" "ERROR"
            $validationResults.UserActionsRequired += "Check project version permissions"
        }
    }
    
    return $validationResults
}

function Write-UserActionList {
    param(
        [object]$ValidationResults,
        [string]$OutputDir
    )
    
    if ($ValidationResults.UserActionsRequired.Count -eq 0) {
        Write-Log "No user actions required - environment is ready" "SUCCESS"
        return
    }
    
    # Ensure output directory exists
    if (-not (Test-Path $OutputDir)) {
        New-Item -ItemType Directory -Path $OutputDir -Force | Out-Null
    }
    
    $actionListPath = Join-Path $OutputDir "redmine-setup-required.md"
    
    $markdownContent = @"
# Redmine Setup Required

## Environment Validation Results

The following elements are missing or require manual setup in Redmine:

## Missing Elements

"@
    
    if ($ValidationResults.MissingStatuses.Count -gt 0) {
        $markdownContent += @"

### 1. Issue Statuses
"@
        foreach ($status in $ValidationResults.MissingStatuses) {
            $markdownContent += @"
- [ ] $status
"@
        }
        $markdownContent += @"

**Action:** Go to Administration → Issue Statuses and create missing statuses
"@
    }
    
    if ($ValidationResults.MissingTrackers.Count -gt 0) {
        $markdownContent += @"

### 2. Trackers
"@
        foreach ($tracker in $ValidationResults.MissingTrackers) {
            $markdownContent += @"
- [ ] $tracker
"@
        }
        $markdownContent += @"

**Action:** Go to Administration → Trackers and create missing trackers
"@
    }
    
    if ($ValidationResults.MissingPriorities.Count -gt 0) {
        $markdownContent += @"

### 3. Issue Priorities
"@
        foreach ($priority in $ValidationResults.MissingPriorities) {
            $markdownContent += @"
- [ ] $priority
"@
        }
        $markdownContent += @"

**Action:** Go to Administration → Enumerations → Issue Priorities and create missing priorities
"@
    }
    
    if (-not $ValidationResults.ProjectExists) {
        $markdownContent += @"

### 4. Project
- [ ] Create project '$($Config.project_info.name)'

**Action:** Create project manually in Redmine or use project creation script
"@
    }
    
    if ($ValidationResults.UserActionsRequired.Count -gt 0) {
        $markdownContent += @"

## Other Actions Required
"@
        foreach ($action in $ValidationResults.UserActionsRequired) {
            $markdownContent += @"
- $action
"@
        }
    }
    
    $markdownContent += @"

## After Setup
1. Run the validation script again: `.\core\scripts\windows\redmine\validate-environment.ps1 -ConfigFile project-config.json`
2. Verify all elements are present
3. Proceed with task creation

## Manual Setup Instructions

### Creating Issue Statuses
1. Go to Administration → Issue Statuses
2. Click "New status"
3. Enter name (e.g., "New", "In Progress")
4. Set color and default status if needed
5. Click "Create"

### Creating Trackers
1. Go to Administration → Trackers  
2. Click "New tracker"
3. Enter name (e.g., "Task", "Bug", "Feature")
4. Set description and default status
5. Click "Create"

### Creating Issue Priorities
1. Go to Administration → Enumerations → Issue Priorities
2. Click "New priority"
3. Enter name (e.g., "Low", "Normal", "High")
4. Set color and default priority if needed
5. Click "Create"

### Creating Project
1. Go to Projects → New project
2. Enter project name and identifier
3. Set description and other details
4. Enable required trackers
5. Click "Create"
"@
    
    try {
        $markdownContent | Out-File -FilePath $actionListPath -Encoding UTF8
        Write-Log "User action list written to: $actionListPath" "SUCCESS"
    }
    catch {
        Write-Log "Failed to write user action list: $($_.Exception.Message)" "ERROR"
    }
}

# Main execution
try {
    Write-Log "Redmine Environment Validator started" "INFO"
    
    # Load configuration
    $config = Load-ProjectConfig -ConfigPath $ConfigFile
    
    # Get Redmine connection details
    $redmineConfig = $config.redmine_config
    $authHeader = Get-BasicAuthHeader -Username $redmineConfig.username -Password $redmineConfig.password
    
    # Test connection
    Write-Log "Testing Redmine connection..." "INFO"
    $testResponse = Get-RedmineData -Endpoint "/projects.json" -AuthHeader $authHeader
    if (-not $testResponse) {
        throw "Failed to connect to Redmine"
    }
    Write-Log "Redmine connection successful" "SUCCESS"
    
    # Validate environment
    $validationResults = Test-RedmineEnvironment -Config $config -AuthHeader $authHeader
    
    # Generate user action list if needed
    Write-UserActionList -ValidationResults $validationResults -OutputDir $OutputDir
    
    # Summary
    Write-Log "Environment validation completed" "INFO"
    Write-Log "Project exists: $($validationResults.ProjectExists)" "INFO"
    Write-Log "Missing statuses: $($validationResults.MissingStatuses.Count)" "INFO"
    Write-Log "Missing trackers: $($validationResults.MissingTrackers.Count)" "INFO"
    Write-Log "Missing priorities: $($validationResults.MissingPriorities.Count)" "INFO"
    Write-Log "User actions required: $($validationResults.UserActionsRequired.Count)" "INFO"
    
    if ($validationResults.UserActionsRequired.Count -eq 0) {
        Write-Log "Environment is ready for task creation!" "SUCCESS"
        exit 0
    } else {
        Write-Log "Manual setup required. Check: $OutputDir\redmine-setup-required.md" "WARNING"
        exit 1
    }
}
catch {
    Write-Log "Critical error: $($_.Exception.Message)" "ERROR"
    exit 1
}
