# Redmine Example 01 Learning Project

**Redmine Example 01 Learning Project** - Complete demonstration environment for learning Redmine AI Assistant with automatic seeding

## 🚀 Overview

This project provides a fully automated Redmine learning environment that includes:
- **Docker-based Redmine 5.0** with PostgreSQL
- **Automatic seeding** of users, projects, and sample data
- **Cross-platform startup scripts** (Windows, Linux, macOS)
- **Complete sample project** with issues, versions, and categories
- **Ready-to-use credentials** for immediate testing

## 🌱 Automatic Seeding

The system automatically creates:

### 👥 Users
- **Admin User**: `admin` / `admin123` (Full permissions)
- **Regular User**: `user` / `user123` (Standard permissions)

### 📁 Project
- **Redmine Learning Project** with identifier `redmine-learning`
- **Public project** accessible to all users
- **All modules enabled** (Issues, Wiki, Repository, Documents, Time Tracking)

### 🏷️ Trackers
- **Feature**: New features and enhancements
- **Bug**: Technical issues and problems
- **Support**: Support requests and questions
- **Documentation**: Documentation improvements

### 📊 Issue Statuses
- **New** (Default)
- **In Progress**
- **Resolved**
- **Closed**

### ⭐ Priorities
- **Low**
- **Normal** (Default)
- **High**
- **Urgent**

### 📋 Versions
- **v1.0.0**: First version - basic functionality
- **v1.1.0**: Second version - extended functionality

### 📂 Categories
- **Feature**: Main system functionality
- **Bug**: Technical issues and problems
- **Support**: Support and maintenance tasks
- **Documentation**: Documentation tasks

### 📝 Sample Issues
- **Implement user authentication system** (Feature, High priority)
- **Fix login page responsive design** (Bug, Normal priority)
- **Create API documentation** (Documentation, Normal priority)

### 🔧 Custom Fields
- **Learning Level**: List field with Beginner/Intermediate/Advanced options

### 📚 Wiki Pages
- **Welcome page** with project overview and getting started guide

## 🚀 Quick Start

### Prerequisites
- **Docker Desktop** running
- **Git** for cloning the repository

### 1. Start the Environment

#### Windows
```batch
cd projects/redmine-example-01
start-example.bat
```

#### PowerShell
```powershell
cd projects/redmine-example-01
.\start-example.ps1
```

#### Linux/macOS
```bash
cd projects/redmine-example-01
chmod +x start-example.sh
./start-example.sh
```

### 2. Wait for Seeding
The system will automatically:
1. Start PostgreSQL and Redmine containers
2. Wait for services to be healthy
3. Seed the database with sample data
4. Display completion message with credentials

### 3. Access Redmine
- **URL**: http://localhost:3000
- **Admin**: admin / admin123
- **User**: user / user123

## 🛠️ Architecture

### Core/Projects Architecture
This project follows the **Core/Projects** architecture where:
- **Core** (`core/`): Contains all reusable scripts, utilities, and templates
- **Projects** (`projects/`): Contain only project-specific configuration and data

### Docker Services
- **postgres**: PostgreSQL 13 database
- **redmine**: Redmine 5.0 application
- **adminer**: Database management interface

### Redmine Integration
The project uses Core scripts for Redmine operations:
1. **Environment Validation**: `core/scripts/windows/redmine/validate-environment.ps1`
2. **Task Creation**: `core/scripts/windows/redmine/create-tasks.ps1`
3. **Common Functions**: `core/scripts/windows/common/redmine-common.ps1`

### Data Flow
```
Input Docs → AI Analysis → tasks.md + tasks.json → Core Scripts → Redmine
```

### Seeding Process
1. **Database Initialization**: Ensures database is ready
2. **User Creation**: Creates admin and regular users
3. **Project Setup**: Creates learning project with all modules
4. **Data Population**: Adds trackers, statuses, priorities, versions
5. **Sample Content**: Creates issues, categories, and wiki pages
6. **Custom Fields**: Adds learning-specific custom fields

## 📁 Project Structure

```
projects/redmine-example-01/
├── config/                     # Project configuration
│   ├── project-config.json    # Redmine AI Assistant config
│   └── project-rules.md       # Project-specific rules
├── docs/                      # Documentation
│   ├── input/                 # Input documentation
│   ├── output/                # Output specifications
│   └── redmine-api/           # Redmine API data
├── data/                      # Data volumes
│   ├── postgres/              # PostgreSQL data
│   └── redmine-api/           # Redmine API data
├── docker-compose.yml         # Docker services configuration
├── start-example.bat          # Windows startup script
├── start-example.ps1          # PowerShell startup script
├── start-example.sh           # Linux/macOS startup script
└── README.md                  # This file
```

**Note**: This project follows the Core/Projects architecture. All Redmine integration scripts are located in `core/scripts/` and should be used from there.

## 🔧 Configuration

### Project Configuration
The `config/project-config.json` file contains:
- **Redmine API settings** for AI Assistant integration
- **Project rules** and permissions
- **Workflow settings** and automation preferences

### Docker Configuration
- **Ports**: Redmine (3000), Adminer (8080), PostgreSQL (5432)
- **Volumes**: Persistent data storage
- **Networks**: Isolated container communication
- **Health Checks**: Automatic service monitoring

## 🎯 Learning Objectives

### Basic Redmine Usage
- **User Management**: Create and manage users
- **Project Administration**: Configure projects and modules
- **Issue Tracking**: Create, assign, and track issues
- **Version Management**: Plan and track project versions
- **Wiki System**: Create and maintain documentation

### Core Scripts Usage
- **Environment Validation**: Check Redmine readiness before task creation
- **Task Creation**: Use JSON data to create tasks via Core scripts
- **Error Handling**: Understand how Core scripts handle validation and errors
- **Logging**: Review operation logs and summaries generated by Core scripts

### Advanced Features
- **Custom Fields**: Extend issue tracking with custom data
- **Workflow Management**: Configure issue status transitions
- **Permission System**: Understand role-based access control
- **API Integration**: Use REST API for automation
- **AI Assistant**: Test Cursor AI integration

## 🚨 Troubleshooting

### Using Core Scripts

#### 1. Validate Redmine Environment
```powershell
# From project directory
.\core\scripts\windows\redmine\validate-environment.ps1 -ConfigFile project-config.json
```

This will:
- Check if project exists in Redmine
- Validate required elements (statuses, trackers, priorities)
- Generate `docs/output/redmine-setup-required.md` if manual setup is needed

#### 2. Create Tasks from JSON
```powershell
# From project directory
.\core\scripts\windows\redmine\create-tasks.ps1 -ConfigFile project-config.json -TasksFile docs/output/tasks.json
```

This will:
- Create tasks from the JSON data
- Assign tasks to appropriate versions
- Generate `docs/output/task-creation-summary.md` with results

#### 3. Check Generated Files
- `docs/output/redmine-setup-required.md`: Manual setup instructions
- `docs/output/task-creation-summary.md`: Task creation results
- `redmine-operations.log`: Detailed operation log

### Common Issues

#### Seeding Timeout
```bash
# Check seeding service logs
docker-compose logs seed-redmine

# Restart seeding service
docker-compose restart seed-redmine
```

#### Database Connection Issues
```bash
# Check PostgreSQL status
docker-compose logs postgres

# Verify database connectivity
docker-compose exec postgres pg_isready -U redmine -d redmine
```

#### Redmine Not Starting
```bash
# Check Redmine logs
docker-compose logs redmine

# Verify service health
docker-compose ps
```

### Reset Environment
```bash
# Stop and remove all containers and volumes
docker-compose down -v

# Start fresh
docker-compose up -d
```

## 🔒 Security Notes

### Development Environment
- **Default passwords** are for learning purposes only
- **Database exposed** on localhost for development
- **No production data** should be used

### Production Considerations
- **Change default passwords** immediately
- **Use environment variables** for sensitive data
- **Restrict network access** to necessary ports
- **Regular backups** of database and files
- **SSL/TLS encryption** for web access

## 📚 Additional Resources

### Project Documentation
- **`docs/input/project-specification.md`**: Complete project specification for fine collection system
- **`docs/output/project-specification.md`**: Detailed output specification with task breakdown
- **`docs/output/tasks.json`**: Structured task data for Core scripts
- **`docs/output/redmine-setup-required.md`**: Manual setup instructions (generated by Core scripts)
- **`docs/output/task-creation-summary.md`**: Task creation results (generated by Core scripts)

### Redmine Documentation
- [Redmine Official Guide](https://www.redmine.org/projects/redmine/wiki/Guide)
- [Redmine API Documentation](https://www.redmine.org/projects/redmine/wiki/Rest_api)
- [Redmine Plugin Development](https://www.redmine.org/projects/redmine/wiki/Plugin_Tutorial)

### Docker Resources
- [Docker Compose Documentation](https://docs.docker.com/compose/)
- [PostgreSQL Docker Image](https://hub.docker.com/_/postgres)
- [Redmine Docker Image](https://hub.docker.com/_/redmine)

## 🤝 Contributing

### Development
1. **Fork the repository**
2. **Create feature branch**
3. **Make changes** and test thoroughly
4. **Submit pull request** with description

### Testing
- **Cross-platform testing** on Windows, Linux, macOS
- **Docker compatibility** with different versions
- **Core scripts validation** with various Redmine versions
- **JSON schema validation** for task data
- **Error handling testing** for various failure scenarios

## 📄 License

This project is part of **Project AI Manager** and is licensed under the MIT License.

## 👨‍💻 Author

**Bartosz Majkut** - Initial work and ongoing development

## 🔄 Migration from Old Architecture

### What Changed
- **Removed**: Project-specific Redmine scripts
- **Added**: Core scripts for Redmine operations
- **New**: JSON-based task data format
- **New**: Environment validation workflow

### Benefits of New Architecture
- **Reusability**: Core scripts can be used across multiple projects
- **Maintainability**: Single source of truth for Redmine operations
- **Consistency**: Standardized approach across all projects
- **Separation**: Clear distinction between Core functionality and project data

---

**Redmine Example 01 Learning Project** - Your complete Redmine learning environment! 🚀
