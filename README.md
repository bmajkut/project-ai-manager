# Project AI Manager

A powerful AI-driven project management assistant that integrates with various project management tools through REST APIs. Currently supports Redmine with plans for Jira, Azure DevOps, and other platforms.

## 🚀 Overview

Project AI Manager leverages Cursor AI to intelligently manage projects across different platforms. It provides automated project setup, task management, and intelligent workflow orchestration based on configurable rules and best practices.

## 🏗️ Architecture

### Core Components
- **Cursor AI**: Primary AI agent for project management assistance
- **Redmine REST API**: Interface for interacting with Redmine
- **Cross-Platform Scripts**: PowerShell (Windows) and Bash (Linux/macOS)
- **Markdown Rules**: Configuration and operational rules
- **JSON Configuration**: Project-specific settings and data exchange

### Directory Structure
```
project-ai-manager/
├── core/                          # Core system components
│   ├── rules/                     # AI operational rules
│   ├── scripts/                   # Cross-platform scripts
│   │   ├── windows/              # Windows (PowerShell) scripts
│   │   ├── linux/                # Linux/macOS (Bash) scripts
│   │   └── script-manager.ps1    # Cross-platform script manager
│   └── templates/                 # Project templates
├── projects/                      # Individual project directories
│   └── example-01/               # Learning project example
└── docs/                          # Documentation
```

## 🚀 Key Features

### Cross-Platform Support
- **Windows**: PowerShell scripts with full .NET integration
- **Linux/macOS**: Bash scripts with native Unix tools
- **Automatic OS Detection**: Smart script selection based on platform
- **Unified Interface**: Same commands work across all platforms

### Intelligent Project Management
- **Automatic Project Creation**: AI-driven project setup
- **Version Management**: Automated version creation and management
- **Task Generation**: AI-powered task creation from requirements
- **Changelog Tracking**: Automatic change documentation

### Security & Compliance
- **Project-Specific Rules**: Override global rules per project
- **Learning Mode**: Safe environment for experimentation
- **Backup & Recovery**: Automatic backup before changes
- **Audit Logging**: Complete operation tracking

## 🔄 Workflow

### Phase 1: Project Initialization
1. **Requirements Analysis**: AI analyzes user input and project requirements
2. **Configuration Creation**: Generates project-specific configuration files
3. **Structure Setup**: Creates organized project directory structure
4. **Rule Application**: Applies project-specific rules and exceptions

### Phase 2: Requirements Analysis
1. **Document Processing**: Analyzes technical specifications and requirements
2. **Project Elaboration**: Generates comprehensive project documentation
3. **User Approval**: Waits for user confirmation before proceeding

### Phase 3: Task Planning
1. **Task Generation**: Creates detailed task list with versions
2. **Description Writing**: Generates comprehensive task descriptions
3. **Final Approval**: User reviews and approves task plan

### Phase 4: Redmine Synchronization
1. **Data Validation**: Ensures data integrity before API calls
2. **API Operations**: Creates/updates tasks and versions in Redmine
3. **Verification**: Confirms successful synchronization
4. **Documentation**: Updates project changelog

## 🛠️ Technology Stack

### Core Technologies
- **PowerShell 5.1+**: Windows automation and API interaction
- **Bash 4.0+**: Linux/macOS automation and API interaction
- **Docker**: Containerized Redmine environment for learning
- **JSON**: Configuration and data exchange format
- **Markdown**: Documentation and rule definition

### Dependencies
- **Windows**: PowerShell, .NET Framework
- **Linux/macOS**: Bash, curl, jq, Docker
- **Cross-Platform**: Docker Desktop, Git

## 📋 System Requirements

### Windows
- Windows 10/11 or Windows Server 2016+
- PowerShell 5.1 or PowerShell Core 6.0+
- Docker Desktop for Windows
- Git for Windows

### Linux
- Ubuntu 18.04+, CentOS 7+, or similar
- Bash 4.0+
- Docker Engine
- curl, jq, git

### macOS
- macOS 10.14+ (Mojave)
- Bash 3.2+ (upgrade to 4.0+ recommended)
- Docker Desktop for Mac
- curl, jq, git

## 🚀 Quick Start

### 1. Clone Repository
```bash
git clone https://github.com/yourusername/redmine-ai.git
cd redmine-ai
```

### 2. Start Learning Environment
```bash
# Windows
cd projects/example-01
start-example.bat

# Linux/macOS
cd projects/example-01
chmod +x start-example.sh
./start-example.sh
```

### 3. Test Redmine AI Assistant
```bash
# Windows
.\core\scripts\script-manager.ps1 -Action get-projects -ConfigFile config\project-config.json

# Linux/macOS
bash core/scripts/linux/redmine-api.sh -a get-projects -c config/project-config.json
```

## 📚 Documentation

### Core Documentation
- **[Cursor AI Rules](core/rules/cursor-ai-rules.md)**: Operational rules and guidelines
- **[Script Manager](core/scripts/script-manager.ps1)**: Cross-platform script management
- **[Project Templates](core/templates/)**: Standard project templates

### Project Documentation
- **[Example-01](projects/example-01/README.md)**: Learning project with full documentation
- **[Quick Start](projects/example-01/QUICK-START.md)**: 5-minute setup guide
- **[Project Rules](projects/example-01/config/project-rules.md)**: Project-specific rules

### User Guides
- **[Usage Guide](USAGE.md)**: Comprehensive user instructions
- **[Development Notes](DEVELOPMENT_NOTES.md)**: Technical implementation details

## 🔧 Configuration

### Project Configuration
Each project has its own configuration file (`project-config.json`) that includes:
- **Project Information**: Name, description, language, status
- **System Configuration**: Target platforms, OS detection settings
- **Redmine Configuration**: API URL, keys, project ID, version
- **Project Rules**: Custom rules and exceptions
- **Workflow Settings**: Automation preferences

### Cross-Platform Settings
```json
{
  "system_config": {
    "target_platforms": ["Windows", "Linux", "macOS"],
    "auto_detect_os": true,
    "fallback_platform": "Windows",
    "script_manager": "core/scripts/script-manager.ps1"
  }
}
```

## 🎓 Learning Project

The **Example-01** project provides a safe learning environment where users can:
- ✅ **Experiment Safely**: Full permissions in learning mode
- ✅ **Test All Features**: Complete functionality testing
- ✅ **Practice Workflows**: Real-world scenario practice
- ✅ **Learn Best Practices**: Follow established patterns

## 🔒 Security Features

### Production Safety
- **No Data Loss**: Automatic backup before changes
- **Change Tracking**: Complete changelog for all modifications
- **User Approval**: Required confirmation for critical operations
- **Audit Logging**: Full operation history

### Learning Mode Exceptions
- **Full Cleanup**: Allowed in learning projects only
- **Issue Deletion**: Permitted for practice purposes
- **Project Reset**: Safe environment restoration
- **Backup Management**: Automatic backup and recovery

## 🚀 Development & Distribution

### Repository Strategy
- **Public Repository**: Core system and documentation
- **Private Notes**: Development notes and internal documentation
- **GitHub Releases**: Versioned releases with artifacts
- **Documentation**: Comprehensive user and developer guides

### Contribution Guidelines
- **Code Standards**: PowerShell and Bash best practices
- **Documentation**: English language requirement
- **Testing**: Cross-platform validation
- **Security**: No sensitive data in public repository

## 📞 Support & Community

### Getting Help
- **Documentation**: Comprehensive guides and examples
- **Example Project**: Working demonstration environment
- **Troubleshooting**: Common issues and solutions
- **Best Practices**: Recommended workflows and patterns

### Contributing
- **Feature Requests**: Submit via GitHub Issues
- **Bug Reports**: Detailed problem descriptions
- **Code Contributions**: Follow established patterns
- **Documentation**: Help improve user guides

## 📄 License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.

## 👨‍💻 Author

**Bartosz Majkut** - Initial work and ongoing development

## 🙏 Acknowledgments

- Redmine community for the excellent project management platform
- Cursor AI team for the powerful AI coding assistant
- Docker community for containerization tools
- Open source contributors and testers

---

**Project AI Manager** - Intelligent project management across multiple platforms
