# Generate Output Documentation Command

Generates output documentation (specifications, task lists, etc.) from input documentation using AI analysis.

## 🎯 Purpose

Automate the generation of project specifications and task breakdowns from input requirements.

## 📝 Usage

```
/generate-output-docs <project-name> [options]
```

## 🔧 Parameters

### Required
- **`project-name`** - Name of the project in the `projects/` directory

### Optional
- **`--input-file`** - Specific input file to process (default: auto-detect)
- **`--output-type`** - Type of output to generate (spec, tasks, both)
- **`--template`** - Template to use for generation
- **`--force`** - Overwrite existing output files
- **`--preview`** - Show preview without saving files

## 🔄 Workflow

1. **Validate** project exists and has input documentation
2. **Analyze** input files for requirements and specifications
3. **Generate** output documentation based on analysis
4. **Validate** generated content for completeness
5. **Save** output files to appropriate directories
6. **Report** generation results and any issues

## 📋 Examples

### Generate All Output Documentation
```
/generate-output-docs my-project
```

### Generate Specific Output Type
```
/generate-output-docs my-project --output-type=tasks
```

### Generate from Specific Input File
```
/generate-output-docs my-project --input-file=docs/input/requirements.md
```

### Preview Generated Content
```
/generate-output-docs my-project --preview
```

## 📁 Input/Output Structure

```
projects/my-project/
├── docs/
│   ├── input/                          # Input files
│   │   ├── project-requirements.md     # Project requirements
│   │   ├── technical-specs.md         # Technical specifications
│   │   └── user-stories.md            # User stories
│   └── output/                         # Generated files
│       ├── project-specification.md    # Generated specification
│       ├── tasks.md                    # Task list in Markdown
│       └── tasks.json                  # Task data in JSON
```

## 📊 Generated Content Types

### 1. Project Specification
- **File**: `docs/output/project-specification.md`
- **Content**: Detailed project analysis, task breakdown, version planning
- **Format**: Structured Markdown with sections and subsections

### 2. Task List (Markdown)
- **File**: `docs/output/tasks.md`
- **Content**: Human-readable task list with descriptions and details
- **Format**: Markdown with task hierarchy and metadata

### 3. Task Data (JSON)
- **File**: `docs/output/tasks.json`
- **Content**: Structured task data for Redmine integration
- **Format**: JSON with project, versions, and tasks arrays

## 🎨 Generation Templates

### Default Template
- **Analysis**: Requirements analysis and project overview
- **Structure**: Version-based task breakdown
- **Format**: Standardized sections and formatting

### Custom Templates
- **Web App**: Web application specific structure
- **Mobile App**: Mobile application specific structure
- **API Service**: API service specific structure
- **Library**: Library/package specific structure

## 🔍 Input Analysis

The command analyzes input files for:

### Requirements Analysis
- **Functional requirements** - What the system should do
- **Non-functional requirements** - Performance, security, usability
- **Technical constraints** - Technology limitations and choices
- **Business rules** - Domain-specific logic and workflows

### Task Identification
- **Core functionality** - Essential system features
- **Infrastructure** - Setup and deployment tasks
- **Integration** - External system connections
- **Testing** - Quality assurance activities

### Version Planning
- **Milestone identification** - Major project phases
- **Dependency mapping** - Task relationships and order
- **Resource estimation** - Time and effort requirements
- **Risk assessment** - Potential challenges and mitigation

## 📤 Output Format

```
📚 Generating Output Documentation for Project: my-project
🔍 Analyzing input files...

📊 Analysis Results:
- Input Files: 3
- Requirements Identified: 25
- Tasks Generated: 18
- Versions Planned: 4

📝 Generated Files:
✅ docs/output/project-specification.md (15.2 KB)
✅ docs/output/tasks.md (8.7 KB)
✅ docs/output/tasks.json (12.1 KB)

🎯 Next Steps:
- Review generated specifications
- Adjust task priorities and estimates
- Validate task dependencies
- Prepare for Redmine integration
```

## ⚠️ Requirements

- Project must exist in `projects/` directory
- Input documentation must be in `docs/input/` directory
- Input files must be in Markdown format
- Project must have valid configuration

## 🔍 Input File Detection

The command automatically detects input files:
- **Primary**: `project-requirements.md`
- **Secondary**: `technical-specs.md`, `user-stories.md`
- **Custom**: Any `.md` files in `docs/input/`

## 🚨 Error Handling

- **Missing input**: Suggests creating input documentation
- **Invalid format**: Provides format correction guidance
- **Generation failures**: Shows specific error details
- **File conflicts**: Offers resolution options

## 🔗 Related Commands

- `/create-task-list` - Create task list manually
- `/generate-tasks-json` - Generate JSON from task descriptions
- `/create-redmine-tasks` - Create tasks in Redmine

## 📋 Customization Options

- **Output format**: Markdown, HTML, PDF
- **Language**: English, Polish, other languages
- **Style**: Technical, business, developer-friendly
- **Detail level**: High-level, detailed, comprehensive

---

**Note**: This command uses AI analysis to generate documentation and follows the established project structure patterns.
