# Cursor AI Commands - Project AI Manager

## Overview
This file lists all available Cursor AI commands for the Project AI Manager system.

## Available Commands

### 1. **Create Project** - `/create-project`
Creates a new project in the `projects/` directory with Redmine API token generation.
- **Usage**: `/create-project <project-name> --login <username> --password <password> [options]`
- **Purpose**: Initialize project structure, generate API token, setup configuration

### 2. **Fetch Redmine Data** - `/fetch-redmine-data`
Fetches project data from Redmine API and saves configuration.
- **Usage**: `/fetch-redmine-data [project-name]`
- **Purpose**: Get project info, trackers, statuses, priorities from Redmine

### 3. **Generate Output Documentation** - `/generate-output-docs`
Analyzes input requirements to generate specifications and task data.
- **Usage**: `/generate-output-docs [project-name]`
- **Purpose**: Create project specs, task breakdown, JSON for Redmine

### 4. **Fetch Project Tasks** - `/fetch-project-tasks`
Retrieves task list from the current project in Redmine.
- **Usage**: `/fetch-project-tasks [options]`
- **Purpose**: Display project tasks with filtering and export options

### 5. **Sync Redmine Data** - `/sync-redmine-data`
Synchronizes project data with Redmine - creates missing elements.
- **Usage**: `/sync-redmine-data [project-name]`
- **Purpose**: Ensure complete consistency between local and Redmine

## Command Categories

### Project Management
- `create-project` - Project initialization and setup

### Redmine Integration
- `fetch-redmine-data` - Data retrieval and configuration
- `fetch-project-tasks` - Task management
- `sync-redmine-data` - Data synchronization

### Documentation
- `generate-output-docs` - AI-powered documentation generation

## Auto-Detection Feature
Most commands automatically detect the current project when run from a project directory:
- Must be in a subdirectory of `projects/` directory
- Reads project configuration from `config/project-config.json`
- Uses stored API token for authentication

## Workflow Integration
Commands are designed to work together in a logical sequence:
1. **Create Project** → Initialize project structure
2. **Fetch Redmine Data** → Get Redmine configuration
3. **Generate Output Docs** → Create specifications and tasks
4. **Sync Redmine Data** → Create projects and tasks in Redmine
5. **Fetch Project Tasks** → Monitor and manage tasks

## Core Scripts Integration
All commands use Core scripts from `core/scripts/` directory:
- **Windows**: PowerShell scripts (`.ps1`)
- **Linux**: Bash scripts (`.sh`)
- **Common**: Shared functions and utilities

## Requirements
- Commands must be run from appropriate project directories
- Valid Redmine API token must be configured
- Redmine server must be accessible
- Input documentation must exist for generation commands
