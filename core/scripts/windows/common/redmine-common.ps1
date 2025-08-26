# Redmine Common Functions
# Core Script for Project AI Manager
# Purpose: Shared functions for Redmine operations

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
        "INFO" { Write-Host $logMessage -ForegroundColor White }
        default { Write-Host $logMessage -ForegroundColor White }
    }
}

function Load-ProjectConfig {
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

function Get-BasicAuthHeader {
    param(
        [string]$Username,
        [string]$Password
    )
    
            $credentials = "${Username}:${Password}"
    $bytes = [System.Text.Encoding]::UTF8.GetBytes($credentials)
    $encoded = [Convert]::ToBase64String($bytes)
    return $encoded
}

function Get-RedmineData {
    param(
        [string]$Endpoint,
        [string]$AuthHeader,
        [string]$BaseUrl = ""
    )
    
    if (-not $BaseUrl) {
        $BaseUrl = "http://localhost:3000"
    }
    
    try {
        $response = Invoke-RestMethod -Uri "$BaseUrl$Endpoint" -Headers @{
            "Authorization" = "Basic $AuthHeader"
            "Content-Type" = "application/json"
        } -Method Get -ErrorAction Stop
        
        return $response
    }
    catch {
        $errorMessage = $_.Exception.Message
        if ($_.Exception.Response) {
            $statusCode = $_.Exception.Response.StatusCode
            $errorMessage = "HTTP ${statusCode}: ${errorMessage}"
        }
        throw "Failed to get data from ${Endpoint}: ${errorMessage}"
    }
}

function Invoke-RedmineAction {
    param(
        [string]$Endpoint,
        [string]$AuthHeader,
        [string]$Method = "GET",
        [object]$Body = $null,
        [string]$BaseUrl = ""
    )
    
    if (-not $BaseUrl) {
        $BaseUrl = "http://localhost:3000"
    }
    
    $headers = @{
        "Authorization" = "Basic $AuthHeader"
        "Content-Type" = "application/json"
    }
    
    $params = @{
        Uri = "$BaseUrl$Endpoint"
        Headers = $headers
        Method = $Method
        ErrorAction = "Stop"
    }
    
    if ($Body) {
        $params.Body = $Body | ConvertTo-Json -Depth 10
    }
    
    try {
        $response = Invoke-RestMethod @params
        return $response
    }
    catch {
        $errorMessage = $_.Exception.Message
        if ($_.Exception.Response) {
            $statusCode = $_.Exception.Response.StatusCode
            $errorMessage = "HTTP ${statusCode}: ${errorMessage}"
        }
        throw "Failed to ${Method} data to ${Endpoint}: ${errorMessage}"
    }
}

function Test-RedmineConnection {
    param(
        [string]$AuthHeader,
        [string]$BaseUrl = ""
    )
    
    try {
        $response = Get-RedmineData -Endpoint "/projects.json" -AuthHeader $AuthHeader -BaseUrl $BaseUrl
        return $true
    }
    catch {
        return $false
    }
}

function Get-RedmineProject {
    param(
        [string]$ProjectName,
        [string]$AuthHeader,
        [string]$BaseUrl = ""
    )
    
    try {
        $projects = Get-RedmineData -Endpoint "/projects.json" -AuthHeader $AuthHeader -BaseUrl $BaseUrl
        
        if ($projects.projects) {
            $project = $projects.projects | Where-Object { $_.name -eq $ProjectName }
            return $project
        }
        
        return $null
    }
    catch {
        throw "Failed to get project '$ProjectName': $($_.Exception.Message)"
    }
}

function Get-RedmineVersion {
    param(
        [string]$VersionName,
        [int]$ProjectId,
        [string]$AuthHeader,
        [string]$BaseUrl = ""
    )
    
    try {
        $versions = Get-RedmineData -Endpoint "/projects/$ProjectId/versions.json" -AuthHeader $AuthHeader -BaseUrl $BaseUrl
        
        if ($versions.versions) {
            $version = $versions.versions | Where-Object { $_.name -eq $VersionName }
            return $version
        }
        
        return $null
    }
    catch {
        throw "Failed to get version '${VersionName}' for project ${ProjectId}: $($_.Exception.Message)"
    }
}

function Get-RedmineTracker {
    param(
        [string]$TrackerName,
        [string]$AuthHeader,
        [string]$BaseUrl = ""
    )
    
    try {
        $trackers = Get-RedmineData -Endpoint "/trackers.json" -AuthHeader $AuthHeader -BaseUrl $BaseUrl
        
        if ($trackers.trackers) {
            $tracker = $trackers.trackers | Where-Object { $_.name -eq $TrackerName }
            return $tracker
        }
        
        return $null
    }
    catch {
        throw "Failed to get tracker '$TrackerName': $($_.Exception.Message)"
    }
}

function Get-RedmineStatus {
    param(
        [string]$StatusName,
        [string]$AuthHeader,
        [string]$BaseUrl = ""
    )
    
    try {
        $statuses = Get-RedmineData -Endpoint "/issue_statuses.json" -AuthHeader $AuthHeader -BaseUrl $BaseUrl
        
        if ($statuses.issue_statuses) {
            $status = $statuses.issue_statuses | Where-Object { $_.name -eq $StatusName }
            return $status
        }
        
        return $null
    }
    catch {
        throw "Failed to get status '$StatusName': $($_.Exception.Message)"
    }
}

function Get-RedminePriority {
    param(
        [string]$PriorityName,
        [string]$AuthHeader,
        [string]$BaseUrl = ""
    )
    
    try {
        $priorities = Get-RedmineData -Endpoint "/enumerations.json?type=IssuePriority" -AuthHeader $AuthHeader -BaseUrl $BaseUrl
        
        if ($priorities.issue_priorities) {
            $priority = $priorities.issue_priorities | Where-Object { $_.name -eq $PriorityName }
            return $priority
        }
        
        return $null
    }
    catch {
        throw "Failed to get priority '$PriorityName': $($_.Exception.Message)"
    }
}

function Validate-JsonSchema {
    param(
        [object]$Data,
        [string[]]$RequiredFields
    )
    
    $missingFields = @()
    
    foreach ($field in $RequiredFields) {
        if (-not $Data.PSObject.Properties.Name.Contains($field)) {
            $missingFields += $field
        }
    }
    
    if ($missingFields.Count -gt 0) {
        throw "Missing required fields: $($missingFields -join ', ')"
    }
    
    return $true
}

function Format-RedmineDescription {
    param([string]$Description)
    
    # Convert markdown to Redmine-compatible format
    $formatted = $Description -replace '\*\*(.*?)\*\*', '*\1*'  # Bold to italic
    $formatted = $formatted -replace '\n', "\r\n"  # Ensure proper line breaks
    
    return $formatted
}

function Write-OperationLog {
    param(
        [string]$Operation,
        [string]$Details,
        [string]$Status,
        [string]$LogFile = "redmine-operations.log"
    )
    
    $timestamp = Get-Date -Format "yyyy-MM-dd HH:mm:ss"
    $logEntry = "[$timestamp] $Operation - $Status - $Details"
    
    try {
        $logEntry | Out-File -FilePath $LogFile -Append -Encoding UTF8
    }
    catch {
        Write-Log "Failed to write to operation log: $($_.Exception.Message)" "WARNING"
    }
}
