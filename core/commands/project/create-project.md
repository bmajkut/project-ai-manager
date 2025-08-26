# Create Project Command

Creates a new project in the `projects/` directory using templates from `core/templates/`.

## 🎯 Purpose

Automate the creation of new projects with consistent structure and configuration.

## 📝 Usage

```
/create-project <project-name> [options]
```

## 🔧 Parameters

### Required
- **`project-name`** - Name of the project to create (will create `projects/project-name/`)

### Optional
- **`--template`** - Template to use (default: `default`)
- **`--description`** - Project description
- **`--type`** - Project type (web-app, mobile-app, api, etc.)
- **`--framework`** - Technology framework (react, vue, django, etc.)

## 📁 What Gets Created

```
projects/project-name/
├── config/
│   ├── project-config.json     # AI Manager configuration
│   └── project-rules.md        # Project-specific rules
├── docs/
│   ├── input/                  # Input documentation
│   └── output/                 # Generated specifications
├── data/                       # Project data (gitignore)
├── docker-compose.yml          # Docker configuration
├── README.md                   # Project documentation
└── .cursorrules               # Project AI rules
```

## 🔄 Workflow

1. **Validate** project name (no spaces, valid characters)
2. **Check** if project already exists
3. **Copy** template files from `core/templates/`
4. **Customize** configuration based on parameters
5. **Initialize** project structure
6. **Generate** project-specific files
7. **Setup** git repository (if requested)

## 📋 Examples

### Basic Project Creation
```
/create-project my-web-app
```

### Project with Template
```
/create-project ecommerce-api --template=api --framework=nodejs
```

### Project with Description
```
/create-project mobile-app --template=mobile --description="Cross-platform mobile application"
```

## ⚠️ Validation Rules

- Project name must be lowercase with hyphens
- No spaces or special characters allowed
- Project name must be unique in workspace
- Template must exist in `core/templates/`

## 🎨 Available Templates

- **`default`** - Basic project structure
- **`web-app`** - Web application template
- **`mobile-app`** - Mobile application template
- **`api`** - API service template
- **`library`** - Library/package template
- **`redmine`** - Redmine integration template

## 📤 Output

- **Success**: Project created with confirmation message
- **Error**: Detailed error message with suggestions
- **Log**: Operation logged for audit purposes

## 🔗 Related Commands

- `/list-projects` - List existing projects
- `/project-info` - Show project details
- `/setup-dev-env` - Setup development environment

---

**Note**: This command respects the Core/Projects separation principle and only creates project structure, not business logic.
