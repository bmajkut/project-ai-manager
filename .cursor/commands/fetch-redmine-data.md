# Fetch Redmine Data

Fetches project data from Redmine API and saves trackers, statuses, and priorities in project configuration.

## Purpose
- Fetch project information from Redmine if it exists
- Retrieve available trackers, statuses, and priorities
- Save Redmine configuration data to project config
- Update project configuration with Redmine project details

## Usage
```
/fetch-redmine-data [project-name]
```

## Examples
- `/fetch-redmine-data` (auto-detects project from current directory)
- `/fetch-redmine-data my-project` (explicit project name)

## Auto-Detection
If no project name is provided, the command automatically detects the current project:
- Must be in a subdirectory of `projects/` directory
- Reads project name from `config/project-config.json`
- Uses stored API token for authentication

## What Gets Fetched
- **Project Information**: Name, ID, description, homepage
- **Trackers**: Available issue trackers (bug, feature, task, support)
- **Statuses**: Available issue statuses (new, in progress, resolved, closed)
- **Priorities**: Available issue priorities (low, normal, high, urgent)
- **Custom Fields**: Project-specific custom fields
- **Members**: Project members and roles

## Output Files
- `config/redmine-config.json` - Redmine project configuration
- `config/project-config.json` - Updated with Redmine project ID

## Workflow
1. Auto-detect project from current directory or use provided name
2. Read project configuration and API token
3. Connect to Redmine API
4. Fetch project data, trackers, statuses, priorities
5. Save configuration to project files
6. Report fetched data summary

## Core Scripts Used
- `core/scripts/redmine/fetch-project-data.ps1` (Windows)
- `core/scripts/redmine/fetch-project-data.sh` (Linux)
- `core/scripts/common/redmine-common.ps1` (Common functions)

## Requirements
- Must be in project directory or provide project name
- Project must have valid Redmine API token
- Redmine server must be accessible
