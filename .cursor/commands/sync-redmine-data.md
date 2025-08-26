# Sync Redmine Data

Synchronizes project data with Redmine - creates projects and tasks if they don't exist, based on project configuration and generated documentation.

## Purpose
- Check if project exists in Redmine, create if missing
- Create missing trackers, statuses, priorities in Redmine
- Create tasks from generated documentation if not already in Redmine
- Synchronize project configuration with Redmine state
- Ensure complete data consistency between local and Redmine

## Usage
```
/sync-redmine-data [project-name]
```

## Examples
- `/sync-redmine-data` (auto-detects project from current directory)
- `/sync-redmine-data my-project` (explicit project name)

## Auto-Detection
If no project name is provided, the command automatically detects the current project:
- Must be in a subdirectory of `projects/` directory
- Reads project name from `config/project-config.json`
- Uses stored API token for authentication

## What Gets Synchronized

### 1. Project Creation
- If project doesn't exist in Redmine, creates it
- Sets project name, description, homepage
- Configures project modules and trackers

### 2. Core Elements
- **Trackers**: Creates missing trackers (bug, feature, task, support)
- **Statuses**: Creates missing statuses (new, in progress, resolved, closed)
- **Priorities**: Creates missing priorities (low, normal, high, urgent)
- **Custom Fields**: Sets up project-specific custom fields

### 3. Task Creation
- Reads `docs/output/tasks.json` for task definitions
- Creates tasks in Redmine if they don't exist
- Sets task properties, dependencies, and assignments
- Creates versions/milestones as needed

### 4. Configuration Update
- Updates `config/redmine-config.json` with Redmine state
- Records created elements and their IDs
- Updates project configuration with Redmine project ID

## Workflow
1. Auto-detect project from current directory or use provided name
2. Check if project exists in Redmine
3. Create project if missing
4. Create missing core elements (trackers, statuses, priorities)
5. Read generated task data from `docs/output/tasks.json`
6. Create missing tasks in Redmine
7. Update project configuration files
8. Report synchronization results

## Prerequisites
- Project must have valid Redmine API token
- `docs/output/tasks.json` must exist (run `/generate-output-docs` first)
- Redmine server must be accessible with admin privileges

## Core Scripts Used
- `core/scripts/redmine/sync-project.ps1` (Windows)
- `core/scripts/redmine/sync-project.sh` (Linux)
- `core/scripts/redmine/create-tasks.ps1` (Task creation)
- `core/scripts/common/redmine-common.ps1` (Common functions)

## Output
- **Success**: Project and tasks synchronized with Redmine
- **Created**: List of newly created elements
- **Updated**: List of updated configurations
- **Errors**: Any issues encountered during synchronization
