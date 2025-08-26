# Generate Output Documentation

Analyzes input requirements and specifications to generate output documentation with task descriptions and JSON data for Redmine integration.

## Purpose
- Analyze input documentation (requirements, specs, user stories)
- Generate comprehensive project specification
- Create task breakdown with versions
- Generate JSON data for Redmine task creation
- Prepare testing instructions and dependencies

## Usage
```
/generate-output-docs [project-name]
```

## Examples
- `/generate-output-docs` (auto-detects project from current directory)
- `/generate-output-docs my-project` (explicit project name)

## Auto-Detection
If no project name is provided, the command automatically detects the current project:
- Must be in a subdirectory of `projects/` directory
- Reads project name from `config/project-config.json`
- Analyzes files in `docs/input/` directory

## Input Files Analyzed
- `docs/input/project-requirements.md` - Project requirements
- `docs/input/technical-specs.md` - Technical specifications
- `docs/input/user-stories.md` - User stories and use cases
- `docs/input/business-rules.md` - Business logic and rules

## Generated Output
- `docs/output/project-specification.md` - Comprehensive project analysis
- `docs/output/tasks.md` - Task list with descriptions and dependencies
- `docs/output/tasks.json` - Structured JSON for Redmine integration

## Task Analysis Includes
- **Solution Proposals**: Technology recommendations and approaches
- **Dependencies**: Task relationships and prerequisites
- **Technologies**: Required tools, frameworks, and libraries
- **Testing Instructions**: What to test and how to test it
- **Version Planning**: Milestone-based task organization

## Workflow
1. Auto-detect project from current directory or use provided name
2. Read and analyze input documentation files
3. Generate comprehensive project specification
4. Create detailed task breakdown with versions
5. Generate JSON data structure for Redmine
6. Save all output files to `docs/output/`
7. Report generation results and next steps

## Core Scripts Used
- `core/scripts/docs/generate-specification.ps1` (Windows)
- `core/scripts/docs/generate-specification.sh` (Linux)
- `core/scripts/docs/ai-analyzer.ps1` (AI analysis engine)

## Requirements
- Must be in project directory or provide project name
- Input documentation must exist in `docs/input/`
- Files must be in Markdown format
