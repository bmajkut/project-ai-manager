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

## Workflow with Cursor AI

### 1. First Run

1. **Open Cursor AI** in the `project-ai-manager` directory
2. **Describe your project** - explain what you want to do
3. **Provide Redmine data**:
   - Redmine URL
   - API key
   - Project ID
   - Language (en)
4. **Cursor AI will create** project structure automatically

### 2. Project Structure

After initialization you'll get:
```
projects/[project-name]-[date]/
├── config/project-config.json    # Configuration
├── specs/                        # Specifications
├── requirements/                 # Requirements
├── tasks/                        # Tasks
├── docs/                         # Documentation
└── changelog/                    # Change history
```

## Configuration

### Project Configuration File

Each project has its own `project-config.json`:

```json
{
  "project_info": {
    "name": "Project Name",
    "description": "Project description",
    "language": "en",
    "status": "planning"
  },
  "redmine_config": {
    "version": "5.0",
    "url": "https://redmine.example.com",
    "api_key": "your_api_key",
    "project_id": 123
  },
  "workflow_config": {
    "auto_backup": true,
    "require_approval": true,
    "changelog_required": true,
    "auto_version_creation": true
  }
}
```

### Workflow Settings

- **auto_backup**: Automatic backup before changes
- **require_approval**: User approval required for critical operations
- **changelog_required**: Changelog required for task updates
- **auto_version_creation**: Automatic version creation

## Script Usage

### Basic Operations

```powershell
# Get projects list
.\core\scripts\script-manager.ps1 -Action "get-projects" -ConfigFile "config\project-config.json"

# Get project issues
.\core\scripts\script-manager.ps1 -Action "get-issues" -ConfigFile "config\project-config.json"

# Create new issue
.\core\scripts\script-manager.ps1 -Action "create-issue" -ConfigFile "config\project-config.json" -DataFile "tasks\new-issue.json"
```

### Available Actions

- **get-projects**: Get list of all projects
- **get-issues**: Get issues for specific project
- **create-issue**: Create new issue
- **update-issue**: Update existing issue
- **create-version**: Create new version
- **get-versions**: Get project versions

## Project Management

### Creating New Projects

1. **Describe requirements** to Cursor AI
2. **Review generated structure**
3. **Approve project setup**
4. **Start working with tasks**

### Task Management

- **Task creation**: AI generates comprehensive descriptions
- **Version management**: Automatic version creation
- **Changelog**: Required for all updates
- **Backup**: Automatic before changes

### Safety Features

- **No data loss**: Automatic backup before changes
- **User approval**: Required for critical operations
- **Change tracking**: Complete changelog for all modifications
- **Audit logging**: Full operation history

## Learning Project

The **Example-01** project provides a safe environment for:

- ✅ **Safe experimentation** with all features
- ✅ **Complete functionality testing**
- ✅ **Real-world scenario practice**
- ✅ **Best practices learning**

## Troubleshooting

### Common Issues

- **API connection errors**: Check Redmine URL and API key
- **Permission denied**: Verify project access rights
- **Script errors**: Check PowerShell execution policy

### Getting Help

- **Documentation**: Comprehensive guides and examples
- **Example project**: Working demonstration environment
- **GitHub Issues**: Report bugs and request features

## Development Notes

### System Requirements

- **Windows**: PowerShell 5.1+, .NET Framework 4.5+
- **Linux/macOS**: Bash 4.0+, curl, jq, Docker
- **Cross-platform**: Docker Desktop, Git

### Architecture

- **Cross-platform scripts**: PowerShell (Windows) + Bash (Linux/macOS)
- **Versioned API support**: Redmine 3.4, 4.2, 5.0+
- **Modular design**: Easy to extend and customize
- **Rule-based system**: Configurable safety and workflow rules

## Version History

- **v1.0.0** - First version with basic features
- **v1.1.0** - Added version and category support
- **v1.2.0** - Cross-platform script support
- **v1.3.0** - Enhanced documentation and examples

## Support

**Note**: This system is under development. All suggestions and bug reports are welcome!
