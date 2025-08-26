# Create Project

Creates a new project in the `projects/` directory and initializes it with configuration files and directories based on templates from `core/templates/`.

## Purpose
- Create project directory structure
- Initialize configuration files
- Generate Redmine API token using provided credentials
- Save token in project configuration

## Usage
```
/create-project <project-name> --login <username> --password <password> [options]
```

## Examples
- `/create-project my-web-app --login admin --password secret123`
- `/create-project ecommerce-api --login admin --password secret123 --url=http://localhost:3000 --template=api --framework=nodejs`
- `/create-project mobile-app --login admin --password secret123 --url=https://redmine.company.com --template=mobile --description="Cross-platform mobile application"`

## Required Parameters
- `project-name`: Name of the project to create
- `--login`: Redmine username for API token generation
- `--password`: Redmine password for API token generation

## Optional Parameters
- `--url`: Redmine server URL (default: http://localhost:3000)
- `--template`: Template to use (default: default)
- `--description`: Project description
- `--type`: Project type (web-app, mobile-app, api, etc.)
- `--framework`: Technology framework (react, vue, django, etc.)

## What Gets Created
- Project directory structure (`projects/<project-name>/`)
- Configuration files (`config/project-config.json`, `config/redmine-config.json`)
- Credentials file (`credentials.env`) with Redmine login data
- Documentation directories (`docs/input/`, `docs/output/`)
- Source code directories (`src/`, `tests/`)
- README and project rules
- Redmine API token generated from Base64 encoding of credentials

## Workflow
1. Validate project name and check if exists
2. Create project directory structure
3. Generate Redmine API token using Base64 encoding of credentials
4. Create project configuration files with token and URL
5. Save credentials securely in `credentials.env` file
6. Initialize git repository
7. Report success with next steps

## Core Scripts Used
- `core/scripts/project/create-project.ps1` (Windows)
- `core/scripts/project/create-project.sh` (Linux)
