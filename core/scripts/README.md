# Scripts Directory

This directory contains all the cross-platform scripts for **Project AI Manager**, organized by platform and Redmine API version.

## Directory Structure

```
core/scripts/
├── script-manager.ps1          # Cross-platform script manager (PowerShell)
├── windows/                    # Windows-specific scripts (PowerShell)
│   ├── redmine-api.ps1        # Redmine API router for Windows
│   └── redmine/               # Versioned Redmine API scripts
│       ├── v3.4/              # Redmine 3.4+ API scripts
│       ├── v4.2/              # Redmine 4.2+ API scripts
│       └── v5.0/              # Redmine 5.0+ API scripts
└── linux/                      # Linux/macOS scripts (Bash)
    ├── redmine-api.sh         # Redmine API script for Linux/macOS
    └── manage-example-project.sh # Example project management script
```

## How It Works

### 1. Cross-Platform Script Manager
The `script-manager.ps1` automatically detects your operating system and runs the appropriate platform-specific script.

### 2. Versioned Redmine API Scripts
Each Redmine version has its own script directory with API-specific implementations:
- **v3.4**: Basic API features, issue limit: 25
- **v4.2**: Enhanced features, issue limit: 50  
- **v5.0**: Full features, issue limit: 100

### 3. Platform-Specific Scripts
- **Windows**: PowerShell scripts with .NET integration
- **Linux/macOS**: Bash scripts with curl and jq

## Usage Examples

### Windows (PowerShell)
```powershell
# Using the cross-platform manager
.\core\scripts\script-manager.ps1 -Action "get-issues" -ConfigFile "project-config.json"

# Direct Windows script usage
.\core\scripts\windows\redmine-api.ps1 -Action "get-issues" -ConfigFile "project-config.json"
```

### Linux/macOS (Bash)
```bash
# Using the cross-platform manager (from PowerShell)
pwsh core/scripts/script-manager.ps1 -Action "get-issues" -ConfigFile "project-config.json"

# Direct Linux script usage
bash core/scripts/linux/redmine-api.sh get-issues project-config.json
```

## Script Features

- **Automatic OS Detection**: Smart platform selection
- **Version Routing**: Automatic Redmine API version selection
- **Error Handling**: Comprehensive error handling and logging
- **Configuration Validation**: Automatic config file validation
- **Cross-Platform Compatibility**: Same interface across all platforms

## Dependencies

### Windows
- PowerShell 5.1+ or PowerShell Core 6.0+
- .NET Framework 4.5+

### Linux/macOS
- Bash 4.0+
- curl (for HTTP requests)
- jq (for JSON processing)
- Docker (for example project)

## Development Notes

- All scripts follow consistent naming conventions
- Error messages are standardized across platforms
- Configuration files use JSON format for cross-platform compatibility
- Scripts include comprehensive logging for debugging
