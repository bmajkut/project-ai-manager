# Redmine API Script for Redmine 4.2+
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

# Funkcja do logowania
function Write-Log {
    param(
        [string]$Message,
        [string]$Level = "INFO"
    )
    
    $timestamp = Get-Date -Format "yyyy-MM-dd HH:mm:ss"
    $logMessage = "[$timestamp] [$Level] $Message"
    
    Write-Host $logMessage
    
    # Zapisz do pliku logów
    $logFile = "logs\operations.log"
    if (!(Test-Path "logs")) {
        New-Item -ItemType Directory -Path "logs" -Force | Out-Null
    }
    Add-Content -Path $logFile -Value $logMessage
}

# Funkcja do wczytywania konfiguracji
function Load-Config {
    param([string]$ConfigPath)
    
    try {
        if (!(Test-Path $ConfigPath)) {
            throw "Plik konfiguracyjny nie istnieje: $ConfigPath"
        }
        
        $config = Get-Content -Path $ConfigPath -Raw | ConvertFrom-Json
        Write-Log "Konfiguracja załadowana z: $ConfigPath"
        return $config
    }
    catch {
        Write-Log "Błąd podczas ładowania konfiguracji: $($_.Exception.Message)" "ERROR"
        exit 1
    }
}

# Funkcja do walidacji konfiguracji
function Test-Config {
    param($Config)
    
    $required = @("redmine_config", "project_info")
    foreach ($field in $required) {
        if (!$Config.$field) {
            throw "Brak wymaganego pola w konfiguracji: $field"
        }
    }
    
    $redmine = $Config.redmine_config
    if (!$redmine.url -or !$redmine.api_key -or !$redmine.project_id) {
        throw "Niekompletna konfiguracja Redmine"
    }
    
    Write-Log "Konfiguracja zwalidowana pomyślnie"
}

# Funkcja do wykonywania zapytań API (Redmine 4.2 compatible)
function Invoke-RedmineAPI {
    param(
        [string]$Method,
        [string]$Endpoint,
        [string]$Body = "",
        [hashtable]$Headers = @{}
    )
    
    $config = $script:Config
    $baseUrl = $config.redmine_config.url.TrimEnd('/')
    $apiKey = $config.redmine_config.api_key
    
    $uri = "$baseUrl$Endpoint"
    
    # Domyślne nagłówki dla Redmine 4.2
    $defaultHeaders = @{
        "X-Redmine-API-Key" = $apiKey
        "Content-Type" = "application/json"
        "Accept" = "application/json"
    }
    
    # Połącz nagłówki
    $allHeaders = $defaultHeaders + $Headers
    
    try {
        $params = @{
            Uri = $uri
            Method = $Method
            Headers = $allHeaders
            TimeoutSec = 30
        }
        
        if ($Body) {
            $params.Body = $Body
        }
        
        Write-Log "Wykonuję $Method $uri (Redmine 4.2)"
        $response = Invoke-RestMethod @params
        
        Write-Log "API call zakończony pomyślnie"
        return $response
    }
    catch {
        $errorMsg = "Błąd API: $($_.Exception.Message)"
        if ($_.Exception.Response) {
            $errorMsg += " (HTTP $($_.Exception.Response.StatusCode))"
        }
        Write-Log $errorMsg "ERROR"
        throw $errorMsg
    }
}

# Funkcja do pobierania projektów (Redmine 4.2)
function Get-RedmineProjects {
    try {
        $response = Invoke-RedmineAPI -Method "GET" -Endpoint "/projects.json"
        return $response.projects
    }
    catch {
        Write-Log "Nie udało się pobrać listy projektów" "ERROR"
        return @()
    }
}

# Funkcja do pobierania zadań projektu (Redmine 4.2)
function Get-RedmineIssues {
    param([int]$ProjectId)
    
    try {
        # Redmine 4.2 może mieć inne limity
        $endpoint = "/issues.json?project_id=$ProjectId&limit=50"
        $response = Invoke-RedmineAPI -Method "GET" -Endpoint $endpoint
        return $response.issues
    }
    catch {
        Write-Log "Nie udało się pobrać zadań dla projektu $ProjectId" "ERROR"
        return @()
    }
}

# Funkcja do tworzenia zadania (Redmine 4.2)
function New-RedmineIssue {
    param([hashtable]$IssueData)
    
    try {
        $body = @{
            issue = $IssueData
        } | ConvertTo-Json -Depth 10
        
        $response = Invoke-RedmineAPI -Method "POST" -Endpoint "/issues.json" -Body $body
        Write-Log "Zadanie utworzone pomyślnie: $($response.issue.id)"
        return $response.issue
    }
    catch {
        Write-Log "Nie udało się utworzyć zadania" "ERROR"
        throw
    }
}

# Funkcja do aktualizacji zadania (Redmine 4.2)
function Update-RedmineIssue {
    param(
        [int]$IssueId,
        [hashtable]$UpdateData
    )
    
    try {
        # Pobierz aktualne zadanie
        $currentIssue = Invoke-RedmineAPI -Method "GET" -Endpoint "/issues/$IssueId.json"
        
        # Dodaj changelog jeśli jest wymagany
        if ($UpdateData.description -and $currentIssue.issue.description) {
            $changelog = "`n`n## Changelog`n- $(Get-Date -Format 'yyyy-MM-dd HH:mm'): $($UpdateData.description)"
            $UpdateData.description = $currentIssue.issue.description + $changelog
        }
        
        $body = @{
            issue = $UpdateData
        } | ConvertTo-Json -Depth 10
        
        $response = Invoke-RedmineAPI -Method "PUT" -Endpoint "/issues/$IssueId.json" -Body $body
        Write-Log "Zadanie $IssueId zaktualizowane pomyślnie"
        return $response
    }
    catch {
        Write-Log "Nie udało się zaktualizować zadania $IssueId" "ERROR"
        throw
    }
}

# Funkcja do tworzenia wersji (Redmine 4.2)
function New-RedmineVersion {
    param([hashtable]$VersionData)
    
    try {
        $body = @{
            version = $VersionData
        } | ConvertTo-Json -Depth 5
        
        $response = Invoke-RedmineAPI -Method "POST" -Endpoint "/versions.json" -Body $body
        Write-Log "Wersja utworzona pomyślnie: $($response.version.id)"
        return $response.version
    }
    catch {
        Write-Log "Nie udało się utworzyć wersji" "ERROR"
        throw
    }
}

# Główna logika skryptu
try {
    Write-Log "Rozpoczynam Redmine API Assistant (Redmine 4.2)"
    
    # Wczytaj konfigurację
    $script:Config = Load-Config -ConfigPath $ConfigFile
    Test-Config -Config $script:Config
    
    # Wykonaj akcję
    switch ($Action.ToLower()) {
        "get-projects" {
            $projects = Get-RedmineProjects
            if ($OutputFile) {
                $projects | ConvertTo-Json -Depth 10 | Out-File -FilePath $OutputFile -Encoding UTF8
                Write-Log "Lista projektów zapisana do: $OutputFile"
            } else {
                $projects | Format-Table -Property id, name, identifier, status
            }
        }
        
        "get-issues" {
            $projectId = $script:Config.redmine_config.project_id
            $issues = Get-RedmineIssues -ProjectId $projectId
            if ($OutputFile) {
                $issues | ConvertTo-Json -Depth 10 | Out-File -FilePath $OutputFile -Encoding UTF8
                Write-Log "Lista zadań zapisana do: $OutputFile"
            } else {
                $issues | Format-Table -Property id, subject, status, priority, assigned_to
            }
        }
        
        "create-issue" {
            if (!$DataFile) {
                throw "Parametr DataFile jest wymagany dla akcji create-issue"
            }
            
            if (!(Test-Path $DataFile)) {
                throw "Plik z danymi nie istnieje: $DataFile"
            }
            
            $issueData = Get-Content -Path $DataFile -Raw | ConvertFrom-Json
            $newIssue = New-RedmineIssue -IssueData $issueData
            
            if ($OutputFile) {
                $newIssue | ConvertTo-Json -Depth 10 | Out-File -FilePath $OutputFile -Encoding UTF8
                Write-Log "Nowe zadanie zapisane do: $OutputFile"
            }
        }
        
        "update-issue" {
            if (!$DataFile) {
                throw "Parametr DataFile jest wymagany dla akcji update-issue"
            }
            
            if (!(Test-Path $DataFile)) {
                throw "Plik z danymi nie istnieje: $DataFile"
            }
            
            $updateData = Get-Content -Path $DataFile -Raw | ConvertFrom-Json
            $issueId = $updateData.id
            $updateData.Remove("id")
            
            Update-RedmineIssue -IssueId $issueId -UpdateData $updateData
        }
        
        "create-version" {
            if (!$DataFile) {
                throw "Parametr DataFile jest wymagany dla akcji create-version"
            }
            
            if (!(Test-Path $DataFile)) {
                throw "Plik z danymi nie istnieje: $DataFile"
            }
            
            $versionData = Get-Content -Path $DataFile -Raw | ConvertFrom-Json
            $newVersion = New-RedmineVersion -VersionData $versionData
            
            if ($OutputFile) {
                $newVersion | ConvertTo-Json -Depth 10 | Out-File -FilePath $OutputFile -Encoding UTF8
                Write-Log "Nowa wersja zapisana do: $OutputFile"
            }
        }
        
        default {
            Write-Log "Nieznana akcja: $Action" "ERROR"
            Write-Host @"
Dostępne akcje:
- get-projects    - Pobierz listę projektów
- get-issues      - Pobierz zadania projektu
- create-issue    - Utwórz nowe zadanie
- update-issue    - Zaktualizuj istniejące zadanie
- create-version  - Utwórz nową wersję

Przykład użycia:
.\redmine-api.ps1 -Action get-projects -ConfigFile project-config.json
.\redmine-api.ps1 -Action create-issue -ConfigFile project-config.json -DataFile issue-data.json

Uwaga: Ten skrypt jest kompatybilny z Redmine 4.2+
"@
            exit 1
        }
    }
    
    Write-Log "Operacja zakończona pomyślnie"
}
catch {
    Write-Log "Błąd krytyczny: $($_.Exception.Message)" "CRITICAL"
    exit 1
}
finally {
    Write-Log "Redmine API Assistant (Redmine 4.2) zakończony"
}
