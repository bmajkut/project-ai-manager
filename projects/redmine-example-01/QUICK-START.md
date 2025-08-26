# Quick Start Guide - Redmine Example 01

## Overview
This is a learning environment for Redmine project management system with AI integration capabilities. It provides a complete Redmine setup with PostgreSQL database and is designed for testing AI-powered task generation from project specifications.

## Prerequisites
- Docker Desktop installed and running
- Docker Compose available
- Git (for cloning the repository)

## Quick Start

### 1. Start the Environment
Choose your platform:

**Windows:**
```cmd
start-example.bat
```

**PowerShell:**
```powershell
.\start-example.ps1
```

**Linux/macOS:**
```bash
chmod +x start-example.sh
./start-example.sh
```

### 2. Wait for Services
The script will:
- Start PostgreSQL database
- Start Redmine application
- Start Adminer (database management)
- Wait for all services to be ready

### 3. Access Redmine
- **URL:** http://localhost:3000
- **Username:** admin
- **Password:** Zaq1xsw@

### 4. Generate API Token
The system will automatically generate an API token for the admin user using Core scripts:

**PowerShell:**
```powershell
.\..\..\core\scripts\windows\redmine\generate-api-token.ps1 -ConfigFile config\config.json -CredentialsFile config\credentials.env
```

**Bash:**
```bash
./../../core/scripts/linux/redmine/generate-api-token.sh config/credentials.env "" "" "" config/config.json
```

**Note:** Make sure to copy `credentials.env.template` to `credentials.env` and fill in your actual credentials before running the script.

This will:
- Connect to Redmine using admin credentials
- Generate a new API token
- Update `redmine-config.json` automatically
- Configure the project for AI integration

### 5. Prepare for AI Integration
1. Place your project specifications in `docs/input/`
2. The system will generate tasks based on your documentation
3. Generated reports will appear in `docs/output/`
4. API data will be cached in `data/redmine-api/`

## What Gets Created
The system automatically discovers:
- **Existing Project** - "redmine-example" (ID: 6)
- **Available Trackers** - Task, Bug, Feature
- **Issue Priorities** - Low, Normal, High, Urgent
- **Issue Statuses** - New, In Progress, Resolved, Closed
- **API Token** - Generated for admin user

## Directory Structure
```
projects/redmine-example-01/
├── config/                    # Project configuration
├── data/                      # Data storage (not in git)
│   ├── postgres/             # PostgreSQL database
│   └── redmine-api/          # Redmine API cache
├── docs/                      # Documentation
│   ├── input/                # Project specifications
│   └── output/               # Generated reports
├── config/                    # Configuration files
│   ├── project-config.json   # Project configuration
│   └── redmine-config.json   # Redmine configuration (auto-generated)
└── docker-compose.yml         # Container configuration
```

## Data Persistence
- **Database:** `./data/postgres/` (PostgreSQL data files)
- **API Cache:** `./data/redmine-api/` (Redmine API responses)

Your data will persist between container restarts.

## Useful Commands

### View Service Status
```bash
docker-compose ps
```

### View Logs
```bash
# All services
docker-compose logs -f

# Specific service
docker-compose logs -f redmine
docker-compose logs -f postgres
```

### Stop Services
```bash
docker-compose down
```

### Restart Services
```bash
docker-compose restart
```

### Clean Start (removes all data)
```bash
docker-compose down -v
docker-compose up -d
```

## Next Steps
1. **Explore Redmine** - Familiarize yourself with the interface
2. **Add Project Specs** - Place requirements in `docs/input/`
3. **Test AI Integration** - Generate tasks from specifications
4. **Review Output** - Check generated reports in `docs/output/`
5. **Customize Workflow** - Adapt to your project needs

## Troubleshooting

### Redmine Not Accessible
1. Check if containers are running: `docker-compose ps`
2. View logs: `docker-compose logs redmine`
3. Ensure port 3000 is not used by another application

### Database Connection Issues
1. Check PostgreSQL logs: `docker-compose logs postgres`
2. Verify database credentials in docker-compose.yml
3. Check if PostgreSQL container is healthy

### Permission Issues (Linux/macOS)
```bash
sudo chown -R $USER:$USER data/
```

## Support
If you encounter issues:
1. Check the logs first
2. Verify Docker is running
3. Ensure ports are available
4. Check system resources (memory, disk space)
