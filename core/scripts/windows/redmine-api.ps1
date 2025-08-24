# Redmine API Router Script
# Version: 1.0.0
# Author: Project AI Manager
# Function: Routes to appropriate Redmine API version script

param(
    [Parameter(Mandatory=$true)]
    [string]$Action,
    
    [Parameter(Mandatory=$false)]
    [string]$ConfigFile = "project-config.json",
    
    [Parameter(Mutable=$false)]
    [string]$DataFile = "",
    
    [Parameter(Mutable=$false)]
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

# Funkcja do określania wersji Redmine
function Get-RedmineVersion {
    param($Config)
    
    $version = $Config.redmine_config.version
    if (!$version) {
        Write-Log "Brak wersji w konfiguracji, używam domyślnej v5.0" "WARNING"
        return "5.0"
    }
    
    return $version
}

# Funkcja do mapowania wersji na katalog
function Map-VersionToDirectory {
    param([string]$Version)
    
    $majorVersion = [version]::Parse($Version)
    
    if ($majorVersion.Major -ge 5) {
        return "v5.0"
    }
    elseif ($majorVersion.Major -eq 4) {
        return "v4.2"
    }
    else {
        return "v3.4"
    }
}

# Funkcja do uruchamiania odpowiedniego skryptu
function Invoke-RedmineScript {
    param(
        [string]$VersionDir,
        [string]$Action,
        [string]$ConfigFile,
        [string]$DataFile,
        [string]$OutputFile
    )
    
    $scriptPath = Join-Path $PSScriptRoot "redmine\$VersionDir\redmine-api.ps1"
    
    if (!(Test-Path $scriptPath)) {
        throw "Skrypt dla wersji $VersionDir nie istnieje: $scriptPath"
    }
    
    Write-Log "Uruchamiam skrypt dla wersji $VersionDir"
    
    # Buduj parametry
    $params = @{
        Action = $Action
        ConfigFile = $ConfigFile
    }
    
    if ($DataFile) {
        $params.DataFile = $DataFile
    }
    
    if ($OutputFile) {
        $params.OutputFile = $OutputFile
    }
    
    # Uruchom skrypt
    & $scriptPath @params
}

# Główna logika
try {
    Write-Log "Rozpoczynam Redmine API Router"
    
    # Wczytaj konfigurację
    $config = Load-Config -ConfigPath $ConfigFile
    
    # Określ wersję Redmine
    $redmineVersion = Get-RedmineVersion -Config $config
    Write-Log "Wykryta wersja Redmine: $redmineVersion"
    
    # Mapuj wersję na katalog
    $versionDir = Map-VersionToDirectory -Version $redmineVersion
    Write-Log "Używam skryptu z katalogu: $versionDir"
    
    # Uruchom odpowiedni skrypt
    Invoke-RedmineScript -VersionDir $versionDir -Action $Action -ConfigFile $ConfigFile -DataFile $DataFile -OutputFile $OutputFile
    
    Write-Log "Router zakończony pomyślnie"
}
catch {
    Write-Log "Błąd krytyczny: $($_.Exception.Message)" "CRITICAL"
    exit 1
}
