# Example-01 Learning Project

This is a learning project for **Project AI Manager** that demonstrates all features in a safe, controlled environment.

## 🎯 Purpose

This project serves as a hands-on learning environment where you can:
- Test all Project AI Manager features safely
- Experiment with different configurations
- Learn the workflow without affecting production data
- Practice API operations with a local Redmine instance

## 🚀 Quick Start

1. **Start the environment**:
   - Windows: Double-click `start-example.bat`
   - Linux/macOS: Run `./start-example.sh`

2. **Access Redmine**: http://localhost:3000
   - Username: `admin`
   - Password: `admin`

3. **Explore the project**: Check the `QUICK-START.md` for detailed instructions

## 🔧 Features Demonstrated

- **Cross-platform scripting** (PowerShell + Bash)
- **Dockerized Redmine environment**
- **Project-specific rules and exceptions**
- **Automatic backup and recovery**
- **Version management**
- **Task creation and management**

## 📁 Project Structure

```
example-01/
├── config/           # Project configuration
├── scripts/          # Management scripts
├── docker-compose.yml # Docker environment
├── tasks/            # Sample data
├── backups/          # Backup storage
├── specs/            # Technical specifications
├── requirements/     # Project requirements
├── docs/             # Documentation
└── changelog/        # Change history
```

## 🛡️ Safety Features

This project has special permissions enabled:
- **Learning mode**: Safe experimentation
- **Task deletion allowed**: Practice cleanup operations
- **Full cleanup enabled**: Reset project state
- **Backup before changes**: Automatic safety

## 📚 Learning Path

1. **Start with QUICK-START.md** for basic operations
2. **Explore the configuration files** to understand settings
3. **Run the management scripts** to see automation in action
4. **Modify the project rules** to experiment with different configurations
5. **Create your own tasks** to practice the full workflow

## 🔄 Reset and Cleanup

Use the management scripts to reset the project:
- **Windows**: `.\scripts\manage-example-project.ps1 -Action reset`
- **Linux/macOS**: `./scripts/manage-example-project.sh reset`

## 📖 Documentation

- [QUICK-START.md](QUICK-START.md) - 5-minute setup guide
- [Configuration Guide](../core/templates/) - Template examples
- [Script Documentation](../core/scripts/README.md) - Script usage
- [Rules and Guidelines](../core/rules/) - Operational rules

---

**Ready to learn?** Start with the [QUICK-START.md](QUICK-START.md) guide! 🚀
