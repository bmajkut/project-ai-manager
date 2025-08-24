# Redmine API Script for Redmine 5.0+
# Version: 1.0.0
# Author: Project AI Manager
# Function: Redmine API interactions via REST API

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

# Function to load configuration
function Load-Config {
    param([string]$ConfigPath)
    
    if (!(Test-Path $ConfigPath)) {
        throw "Configuration file not found: $ConfigPath"
    }
    
    try {
        $config = Get-Content $ConfigPath | ConvertFrom-Json
        return $config
    }
    catch {
        throw "Failed to parse configuration file: $($_.Exception.Message)"
    }
}

# Function to validate configuration
function Validate-Config {
    param([object]$Config)
    
    if (!$Config.redmine_config.url) {
        throw "Redmine URL is required in configuration"
    }
    
    if (!$Config.redmine_config.api_key) {
        throw "API key is required in configuration"
    }
    
    if (!$Config.redmine_config.project_id) {
        throw "Project ID is required in configuration"
    }
    
    Write-Log "Configuration validated successfully"
}

# Function to execute API calls
function Invoke-RedmineAPI {
    param(
        [string]$Method,
        [string]$Endpoint,
        [object]$Body = $null,
        [object]$Config
    )
    
    $headers = @{
        "X-Redmine-API-Key" = $Config.redmine_config.api_key
        "Content-Type" = "application/json"
    }
    
    $uri = "$($Config.redmine_config.url)$Endpoint"
    
    try {
        if ($Body) {
            $jsonBody = $Body | ConvertTo-Json -Depth 10
            $response = Invoke-RestMethod -Uri $uri -Method $Method -Headers $headers -Body $jsonBody
        }
        else {
            $response = Invoke-RestMethod -Uri $uri -Method $Method -Headers $headers
        }
        
        Write-Log "API call completed successfully"
        return $response
    }
    catch {
        Write-Log "API call failed: $($_.Exception.Message)" "ERROR"
        throw
    }
}

# Function to get projects
function Get-Projects {
    param([object]$Config)
    
    try {
        $response = Invoke-RedmineAPI -Method "GET" -Endpoint "/projects.json" -Config $Config
        return $response.projects
    }
    catch {
        Write-Log "Failed to get projects list" "ERROR"
        throw
    }
}

# Function to get project issues
function Get-ProjectIssues {
    param(
        [object]$Config,
        [int]$Limit = 100
    )
    
    try {
        $endpoint = "/issues.json?project_id=$($Config.redmine_config.project_id)&limit=$Limit"
        $response = Invoke-RedmineAPI -Method "GET" -Endpoint $endpoint -Config $Config
        return $response.issues
    }
    catch {
        Write-Log "Failed to get issues for project $($Config.redmine_config.project_id)" "ERROR"
        throw
    }
}

# Function to create issue
function New-Issue {
    param(
        [object]$Config,
        [object]$IssueData
    )
    
    try {
        $body = @{
            issue = $IssueData
        }
        
        $response = Invoke-RedmineAPI -Method "POST" -Endpoint "/issues.json" -Body $body -Config $Config
        
        if ($response.issue) {
            Write-Log "Issue created successfully: $($response.issue.id)"
            return $response.issue
        }
        else {
            Write-Log "Failed to create issue" "ERROR"
            throw "Invalid response from API"
        }
    }
    catch {
        Write-Log "Failed to create issue" "ERROR"
        throw
    }
}

# Function to update issue
function Update-Issue {
    param(
        [object]$Config,
        [int]$IssueId,
        [object]$UpdateData
    )
    
    try {
        $body = @{
            issue = $UpdateData
        }
        
        $endpoint = "/issues/$IssueId.json"
        $response = Invoke-RedmineAPI -Method "PUT" -Endpoint $endpoint -Body $body -Config $Config
        
        Write-Log "Issue $IssueId updated successfully"
        return $response
    }
    catch {
        Write-Log "Failed to update issue $IssueId" "ERROR"
        throw
    }
}

# Function to create version
function New-Version {
    param(
        [object]$Config,
        [object]$VersionData
    )
    
    try {
        $body = @{
            version = $VersionData
        }
        
        $response = Invoke-RedmineAPI -Method "POST" -Endpoint "/projects/$($Config.redmine_config.project_id)/versions.json" -Body $body -Config $Config
        
        if ($response.version) {
            Write-Log "Version created successfully: $($response.version.id)"
            return $response.version
        }
        else {
            Write-Log "Failed to create version" "ERROR"
            throw "Invalid response from API"
        }
    }
    catch {
        Write-Log "Failed to create version" "ERROR"
        throw
    }
}

# Function to save data to file
function Save-DataToFile {
    param(
        [object]$Data,
        [string]$FilePath
    )
    
    try {
        $jsonData = $Data | ConvertTo-Json -Depth 10
        Set-Content -Path $FilePath -Value $jsonData -Encoding UTF8
        Write-Log "Data saved to: $FilePath"
    }
    catch {
        Write-Log "Failed to save data to file: $($_.Exception.Message)" "ERROR"
        throw
    }
}

# Main execution
try {
    Write-Log "Redmine API Script (v5.0) started"
    
    # Load and validate configuration
    $config = Load-Config -ConfigPath $ConfigFile
    Validate-Config -Config $config
    
    # Execute requested action
    switch ($Action.ToLower()) {
        "get-projects" {
            $projects = Get-Projects -Config $config
            if ($OutputFile) {
                Save-DataToFile -Data $projects -FilePath $OutputFile
            }
            else {
                $projects | ConvertTo-Json -Depth 10
            }
        }
        
        "get-issues" {
            $issues = Get-ProjectIssues -Config $config
            if ($OutputFile) {
                Save-DataToFile -Data $issues -FilePath $OutputFile
            }
            else {
                $issues | ConvertTo-Json -Depth 10
            }
        }
        
        "create-issue" {
            if (!$DataFile) {
                throw "DataFile parameter is required for create-issue action"
            }
            
            if (!(Test-Path $DataFile)) {
                throw "Data file not found: $DataFile"
            }
            
            $issueData = Get-Content $DataFile | ConvertFrom-Json
            $newIssue = New-Issue -Config $config -IssueData $issueData
            
            if ($OutputFile) {
                Save-DataToFile -Data $newIssue -FilePath $OutputFile
            }
            else {
                $newIssue | ConvertTo-Json -Depth 10
            }
        }
        
        "update-issue" {
            if (!$DataFile) {
                throw "DataFile parameter is required for update-issue action"
            }
            
            if (!(Test-Path $DataFile)) {
                throw "Data file not found: $DataFile"
            }
            
            $updateData = Get-Content $DataFile | ConvertFrom-Json
            
            if (!$updateData.id) {
                throw "Issue ID is required in update data"
            }
            
            $result = Update-Issue -Config $config -IssueId $updateData.id -UpdateData $updateData
            
            if ($OutputFile) {
                Save-DataToFile -Data $result -FilePath $OutputFile
            }
            else {
                $result | ConvertTo-Json -Depth 10
            }
        }
        
        "create-version" {
            if (!$DataFile) {
                throw "DataFile parameter is required for create-version action"
            }
            
            if (!(Test-Path $DataFile)) {
                throw "Data file not found: $DataFile"
            }
            
            $versionData = Get-Content $DataFile | ConvertFrom-Json
            $newVersion = New-Version -Config $config -VersionData $versionData
            
            if ($OutputFile) {
                Save-DataToFile -Data $newVersion -FilePath $OutputFile
            }
            else {
                $newVersion | ConvertTo-Json -Depth 10
            }
        }
        
        default {
            throw "Unknown action: $Action. Supported actions: get-projects, get-issues, create-issue, update-issue, create-version"
        }
    }
    
    Write-Log "Operation completed successfully"
}
catch {
    Write-Log "Critical error: $($_.Exception.Message)" "ERROR"
    exit 1
}
finally {
    Write-Log "Redmine API Script completed"
}
