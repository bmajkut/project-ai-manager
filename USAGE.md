# Usage Guide - Project AI Manager

**Project AI Manager** - Complete user guide for intelligent project management

## 🚀 Getting Started

### Prerequisites
- **Windows**: PowerShell 5.1+ or PowerShell Core 6.0+
- **Linux/macOS**: Bash 4.0+, curl, jq
- **Docker**: For example project environment
- **Git**: For version control

### Installation
1. **Clone the repository**:
   ```bash
   git clone https://github.com/yourusername/project-ai-manager.git
   cd project-ai-manager
   ```

2. **Start with the example project**:
   ```bash
   cd projects/example-01
   # Windows: start-example.bat
   # Linux/macOS: ./start-example.sh
   ```

## Workflow z Cursor AI

### Faza 1: Inicjalizacja
```
Użytkownik: "Chcę utworzyć projekt 'System zarządzania zadaniami'"
Cursor AI: [Tworzy strukturę + pyta o dane Redmine]
Użytkownik: [Podaje dane]
Cursor AI: [Generuje konfigurację + potwierdza]
```

### Faza 2: Analiza wymagań
```
Użytkownik: [Dostarcza specyfikację/wymagania]
Cursor AI: [Analizuje + tworzy opracowanie]
Użytkownik: [Zatwierdza lub prosi o zmiany]
```

### Faza 3: Planowanie zadań
```
Cursor AI: [Generuje listę zadań + opisy]
Użytkownik: [Zatwierdza plan]
```

### Faza 4: Synchronizacja
```
Cursor AI: [Tworzy/aktualizuje zadania w Redmine]
Użytkownik: [Otrzymuje raport]
```

## Używanie skryptów PowerShell

### Podstawowe komendy

```powershell
# Pobierz listę projektów
.\core\scripts\redmine-api.ps1 -Action get-projects -ConfigFile projects\moj-projekt\config\project-config.json

# Pobierz zadania projektu
.\core\scripts\redmine-api.ps1 -Action get-issues -ConfigFile projects\moj-projekt\config\project-config.json

# Utwórz nowe zadanie
.\core\scripts\redmine-api.ps1 -Action create-issue -ConfigFile projects\moj-projekt\config\project-config.json -DataFile issue-data.json

# Zaktualizuj zadanie
.\core\scripts\redmine-api.ps1 -Action update-issue -ConfigFile projects\moj-projekt\config\project-config.json -DataFile update-data.json
```

### Format danych dla zadań

**issue-data.json:**
```json
{
  "subject": "Implementacja logowania użytkowników",
  "description": "## Opis funkcjonalności\nSystem logowania z walidacją...",
  "tracker_id": 1,
  "priority_id": 2,
  "estimated_hours": 8,
  "category_id": 1
}
```

**update-data.json:**
```json
{
  "id": 123,
  "description": "Dodano obsługę 2FA",
  "estimated_hours": 12
}
```

## Konfiguracja projektu

### Plik project-config.json

```json
{
  "project_info": {
    "name": "Nazwa projektu",
    "language": "pl",
    "status": "planning"
  },
  "redmine_config": {
    "url": "https://redmine.example.com",
    "api_key": "your_api_key",
    "project_id": 123,
    "version": "5.0"
  }
}
```

### Ustawienia workflow

- **auto_version_creation**: Automatyczne tworzenie wersji
- **changelog_required**: Obowiązkowy changelog
- **backup_before_changes**: Backup przed zmianami
- **max_retries**: Maksymalna liczba prób API

## Reguły bezpieczeństwa

### Co system NIGDY nie robi:
- ❌ Usuwa zadania z Redmine
- ❌ Nadpisuje opisy bez changelogu
- ❌ Modyfikuje ustawienia projektu bez potwierdzenia

### Co system zawsze robi:
- ✅ Tworzy backup przed zmianami
- ✅ Loguje wszystkie operacje
- ✅ Pyta o potwierdzenie ważnych operacji
- ✅ Dodaje changelog do zmian

## Rozwiązywanie problemów

### Błąd "API call failed"
1. Sprawdź poprawność klucza API
2. Sprawdź uprawnienia użytkownika
3. Sprawdź dostępność Redmine

### Błąd "Configuration invalid"
1. Sprawdź format pliku JSON
2. Sprawdź wymagane pola w konfiguracji
3. Sprawdź poprawność URL

### Błąd "Permission denied"
1. Sprawdź uprawnienia do katalogów
2. Sprawdź uprawnienia użytkownika PowerShell
3. Uruchom PowerShell jako administrator

## Najlepsze praktyki

### Organizacja projektów
- Używaj opisowych nazw projektów
- Grupuj powiązane projekty w podkatalogach
- Regularnie archiwizuj zakończone projekty

### Zarządzanie zadaniami
- Zawsze opisuj zmiany w changelogu
- Używaj szablonów dla typowych zadań
- Regularnie synchronizuj z Redmine

### Bezpieczeństwo
- Nie commituj kluczy API do git
- Używaj różnych kluczy dla różnych środowisk
- Regularnie rotuj klucze API

## Wsparcie i rozwój

### Repozytorium
- Kod źródłowy: [GitHub URL]
- Dokumentacja: [Wiki URL]
- Issues: [GitHub Issues URL]

### Kontakt
- Autor: [Twoje imię]
- Email: [Twój email]
- GitHub: [Twój profil]

## Changelog

- **v1.0.0** - Pierwsza wersja z podstawowymi funkcjonalnościami
- **v1.1.0** - Dodano obsługę wersji i kategorii
- **v2.0.0** - Przepisano na modułową architekturę

---

**Uwaga**: Ten system jest w fazie rozwoju. Wszystkie sugestie i zgłoszenia błędów są mile widziane!
