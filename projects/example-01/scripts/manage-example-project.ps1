# Example Project Management Script
# Version: 1.0.0
# Author: Project AI Manager
# Function: Manage Docker environment for Example-01 learning project

param(
    [Parameter(Mandatory=$true)]
    [ValidateSet("start", "stop", "reset", "cleanup", "backup", "restore", "status")]
    [string]$Action,
    
    [Parameter(Mandatory=$false)]
    [string]$BackupFile = ""
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
}

# Funkcja do sprawdzania Docker
function Test-Docker {
    try {
        $dockerVersion = docker --version
        Write-Log "Docker dostępny: $dockerVersion"
        return $true
    }
    catch {
        Write-Log "Docker nie jest dostępny. Zainstaluj Docker Desktop." "ERROR"
        return $false
    }
}

# Funkcja do uruchamiania środowiska
function Start-Environment {
    Write-Log "Uruchamiam środowisko Example-01..."
    
    $dockerComposePath = Join-Path $PSScriptRoot "..\docker-compose.yml"
    if (!(Test-Path $dockerComposePath)) {
        throw "Plik docker-compose.yml nie istnieje: $dockerComposePath"
    }
    
    Set-Location (Split-Path $dockerComposePath)
    docker-compose up -d
    
    Write-Log "Czekam na uruchomienie Redmine..."
    Start-Sleep -Seconds 30
    
    # Sprawdź status
    $status = docker-compose ps
    Write-Log "Status kontenerów:`n$status"
    
    Write-Log "Środowisko uruchomione!"
    Write-Log "Redmine: http://localhost:3000"
    Write-Log "Adminer: http://localhost:8080"
}

# Funkcja do zatrzymywania środowiska
function Stop-Environment {
    Write-Log "Zatrzymuję środowisko Example-01..."
    
    $dockerComposePath = Join-Path $PSScriptRoot "..\docker-compose.yml"
    Set-Location (Split-Path $dockerComposePath)
    docker-compose down
    
    Write-Log "Środowisko zatrzymane!"
}

# Funkcja do resetowania środowiska
function Reset-Environment {
    Write-Log "Resetuję środowisko Example-01..."
    
    $dockerComposePath = Join-Path $PSScriptRoot "..\docker-compose.yml"
    Set-Location (Split-Path $dockerComposePath)
    
    # Zatrzymaj i usuń wszystkie dane
    docker-compose down -v
    Write-Log "Wszystkie dane zostały usunięte"
    
    # Uruchom ponownie
    docker-compose up -d
    Write-Log "Środowisko zresetowane i uruchomione!"
}

# Funkcja do pełnego cleanup Redmine
function Invoke-FullCleanup {
    Write-Log "Wykonuję pełny cleanup Redmine..."
    
    # Backup przed cleanup
    $backupDir = Join-Path $PSScriptRoot "..\backups"
    if (!(Test-Path $backupDir)) {
        New-Item -ItemType Directory -Path $backupDir -Force | Out-Null
    }
    
    $timestamp = Get-Date -Format "yyyyMMdd_HHmmss"
    $backupFile = Join-Path $backupDir "backup_before_cleanup_$timestamp.sql"
    
    # Backup bazy danych
    docker exec redmine-example-postgres pg_dump -U redmine redmine > $backupFile
    Write-Log "Backup wykonany: $backupFile"
    
    # Backup plików Redmine
    $filesBackup = Join-Path $backupDir "files_before_cleanup_$timestamp"
    docker cp redmine-example-app:/usr/src/redmine/files $filesBackup
    Write-Log "Backup plików wykonany: $filesBackup"
    
    # Teraz wykonaj cleanup przez API Redmine
    Write-Log "Wykonuję cleanup przez Redmine API..."
    
    # Pobierz wszystkie zadania i usuń je
    $configFile = Join-Path $PSScriptRoot "..\config\project-config.json"
    if (Test-Path $configFile) {
        $config = Get-Content -Path $configFile -Raw | ConvertFrom-Json
        
        # Użyj Redmine API do usunięcia wszystkich zadań
        $redmineScript = Join-Path $PSScriptRoot "..\..\..\core\scripts\redmine-api.ps1"
        if (Test-Path $redmineScript) {
            # Pobierz listę zadań
            Write-Log "Pobieram listę zadań do usunięcia..."
            & $redmineScript -Action "get-issues" -ConfigFile $configFile -OutputFile "temp_issues.json"
            
            if (Test-Path "temp_issues.json") {
                $issues = Get-Content -Path "temp_issues.json" -Raw | ConvertFrom-Json
                Write-Log "Znaleziono $($issues.Count) zadań do usunięcia"
                
                # Usuń każde zadanie (w trybie example-01 jest to dozwolone)
                foreach ($issue in $issues) {
                    Write-Log "Usuwam zadanie ID: $($issue.id) - $($issue.subject)"
                    # Tutaj można dodać wywołanie API do usunięcia zadania
                }
                
                Remove-Item "temp_issues.json" -Force
            }
        }
    }
    
    Write-Log "Pełny cleanup zakończony!"
    Write-Log "Backup dostępny w: $backupDir"
}

# Funkcja do tworzenia backupu
function New-Backup {
    Write-Log "Tworzę backup środowiska Example-01..."
    
    $backupDir = Join-Path $PSScriptRoot "..\backups"
    if (!(Test-Path $backupDir)) {
        New-Item -ItemType Directory -Path $backupDir -Force | Out-Null
    }
    
    $timestamp = Get-Date -Format "yyyyMMdd_HHmmss"
    $backupFile = Join-Path $backupDir "backup_$timestamp.sql"
    
    # Backup bazy danych
    docker exec redmine-example-postgres pg_dump -U redmine redmine > $backupFile
    Write-Log "Backup bazy danych: $backupFile"
    
    # Backup plików Redmine
    $filesBackup = Join-Path $backupDir "files_$timestamp"
    docker cp redmine-example-app:/usr/src/redmine/files $filesBackup
    Write-Log "Backup plików: $filesBackup"
    
    Write-Log "Backup zakończony pomyślnie!"
}

# Funkcja do przywracania z backupu
function Restore-Backup {
    param([string]$BackupFile)
    
    if (!$BackupFile) {
        throw "Parametr BackupFile jest wymagany dla akcji restore"
    }
    
    if (!(Test-Path $BackupFile)) {
        throw "Plik backupu nie istnieje: $BackupFile"
    }
    
    Write-Log "Przywracam z backupu: $BackupFile"
    
    # Zatrzymaj Redmine
    docker-compose stop redmine
    
    # Przywróć bazę danych
    docker exec -i redmine-example-postgres psql -U redmine redmine < $BackupFile
    Write-Log "Baza danych przywrócona"
    
    # Uruchom Redmine ponownie
    docker-compose start redmine
    
    Write-Log "Przywracanie zakończone!"
}

# Funkcja do sprawdzania statusu
function Get-Status {
    Write-Log "Sprawdzam status środowiska Example-01..."
    
    $dockerComposePath = Join-Path $PSScriptRoot "..\docker-compose.yml"
    if (Test-Path $dockerComposePath) {
        Set-Location (Split-Path $dockerComposePath)
        
        $status = docker-compose ps
        Write-Log "Status kontenerów:`n$status"
        
        # Sprawdź dostępność Redmine
        try {
            $response = Invoke-WebRequest -Uri "http://localhost:3000" -TimeoutSec 5
            Write-Log "Redmine dostępny: HTTP $($response.StatusCode)"
        }
        catch {
            Write-Log "Redmine niedostępny" "WARNING"
        }
        
        # Sprawdź dostępność Adminer
        try {
            $response = Invoke-WebRequest -Uri "http://localhost:8080" -TimeoutSec 5
            Write-Log "Adminer dostępny: HTTP $($response.StatusCode)"
        }
        catch {
            Write-Log "Adminer niedostępny" "WARNING"
        }
    }
    else {
        Write-Log "Plik docker-compose.yml nie istnieje" "ERROR"
    }
}

# Główna logika
try {
    Write-Log "Example-01 Project Manager - Rozpoczynam operację: $Action"
    
    # Sprawdź Docker
    if (!(Test-Docker)) {
        exit 1
    }
    
    # Wykonaj akcję
    switch ($Action.ToLower()) {
        "start" {
            Start-Environment
        }
        "stop" {
            Stop-Environment
        }
        "reset" {
            Reset-Environment
        }
        "cleanup" {
            Invoke-FullCleanup
        }
        "backup" {
            New-Backup
        }
        "restore" {
            Restore-Backup -BackupFile $BackupFile
        }
        "status" {
            Get-Status
        }
        default {
            Write-Log "Nieznana akcja: $Action" "ERROR"
            Write-Host @"
Dostępne akcje:
- start     - Uruchom środowisko
- stop      - Zatrzymaj środowisko
- reset     - Resetuj środowisko (usuń wszystkie dane)
- cleanup   - Pełny cleanup Redmine
- backup    - Utwórz backup
- restore   - Przywróć z backupu
- status    - Sprawdź status

Przykład użycia:
.\manage-example-project.ps1 -Action start
.\manage-example-project.ps1 -Action cleanup
.\manage-example-project.ps1 -Action restore -BackupFile backup_20240824_120000.sql
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
    Write-Log "Example-01 Project Manager zakończony"
}
