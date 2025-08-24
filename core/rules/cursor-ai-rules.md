# Cursor AI Rules for Project AI Manager

## Overview

This document defines the core operational rules and guidelines for Cursor AI when working with Project AI Manager. These rules ensure consistent, safe, and efficient project management across multiple platforms.

## Basic Operating Principles

### 1. Safety First
- **Never delete tasks without explicit user permission**
- **Always create backups before major changes**
- **Validate all data before API operations**
- **Log all operations for audit purposes**

### 2. Project Structure
- **Each project gets its own directory**
- **Maintain consistent internal structure**
- **Use templates for new projects**
- **Follow naming conventions strictly**

### 3. Task Management
- **Create comprehensive task descriptions**
- **Maintain changelog for all updates**
- **Group tasks by versions logically**
- **Respect project-specific rules and exceptions**

## Workflow Phases

### Phase 1: Project Initialization
1. **Analyze user requirements**
2. **Create project configuration file**
3. **Set up project directory structure**
4. **Apply project-specific rules**

### Phase 2: Requirements Analysis
1. **Process technical specifications**
2. **Generate project elaboration document**
3. **Wait for user approval**

### Phase 3: Task Planning
1. **Create detailed task list with versions**
2. **Write comprehensive task descriptions**
3. **Get final user approval**

### Phase 4: Platform Synchronization
1. **Validate data integrity**
2. **Execute API operations**
3. **Verify successful synchronization**
4. **Update project documentation**

## Per-Project Rules and Exceptions

### Rule Hierarchy
1. **Global Rules**: Apply to all projects by default
2. **Project Rules**: Override global rules for specific projects
3. **Learning Mode**: Special permissions for practice projects

### Exception Types
- **`allow_issue_deletion`**: Override deletion prohibition
- **`allow_full_cleanup`**: Allow complete project reset
- **`learning_mode`**: Enable experimental features
- **`special_permissions`**: Custom rule overrides

### Rule Detection
- Check `project-config.json` for `project_rules` section
- Look for `project-rules.md` in project config directory
- Apply most restrictive rules by default
- Log all rule exceptions for audit

## Configuration Requirements

### Project Configuration
- **Platform detection settings**
- **API credentials and endpoints**
- **Project identification**
- **Language preferences**
- **Rule exceptions and overrides**

### System Configuration
- **Target platforms (Windows, Linux, macOS)**
- **Automatic OS detection**
- **Fallback platform settings**
- **Script manager preferences**

## Error Handling

### API Errors
- **Retry with exponential backoff**
- **Log detailed error information**
- **Provide user-friendly error messages**
- **Suggest recovery actions**

### Validation Errors
- **Stop operation immediately**
- **Show specific validation failures**
- **Guide user to fix issues**
- **Maintain data integrity**

## Logging and Documentation

### Operation Logging
- **Log all API calls with timestamps**
- **Record user decisions and approvals**
- **Track rule exceptions and overrides**
- **Maintain audit trail for compliance**

### Documentation Updates
- **Update project changelog automatically**
- **Maintain task description history**
- **Document rule exceptions**
- **Track configuration changes**

## Best Practices

### Code Quality
- **Use consistent naming conventions**
- **Implement proper error handling**
- **Add comprehensive logging**
- **Follow platform-specific best practices**

### User Experience
- **Provide clear progress indicators**
- **Show confirmation dialogs for critical actions**
- **Offer helpful error messages**
- **Maintain consistent interface across platforms**

### Security
- **Never log sensitive credentials**
- **Validate all user inputs**
- **Use secure API communication**
- **Implement proper access controls**
