# Quick Start Guide - Example-01 Learning Project

**Project AI Manager** - Learn all features in 5 minutes! 🚀

## ⚡ Get Redmine environment running in 5 minutes!

This guide will help you quickly set up and test the Example-01 learning project.

### 🎯 What you'll learn:
- How to start the Docker environment
- How to access Redmine and create your first project
- How to use Project AI Manager scripts
- How to safely experiment with all features

## 🚀 Step 1: Start the Environment

### Windows Users:
1. **Double-click** `start-example.bat`
2. **Wait** for Docker to start (may take 2-3 minutes)
3. **See success message** when ready

### Linux/macOS Users:
1. **Open terminal** in the `example-01` directory
2. **Run**: `./start-example.sh`
3. **Wait** for Docker to start
4. **See success message** when ready

### ✅ What happens:
- PostgreSQL database starts
- Redmine application starts
- Adminer (database manager) starts
- Sample data is loaded

## 🌐 Step 2: Access Redmine

1. **Open browser** and go to: http://localhost:3000
2. **Login** with:
   - Username: `admin`
   - Password: `admin`
3. **Create new project**:
   - Click "New project"
   - Name: `Example-01`
   - Identifier: `example-01`
   - Click "Create"

## 🔑 Step 3: Get API Key

1. **Go to**: My Account → API access key
2. **Copy the API key** (long string of characters)
3. **Open**: `config/project-config.json`
4. **Replace**: `"your_api_key_here"` with your actual API key
5. **Save** the file

## 🧪 Step 4: Test Project AI Manager

### Test basic operations:
```powershell
# Windows (PowerShell)
.\core\scripts\script-manager.ps1 -Action "get-projects" -ConfigFile "config\project-config.json"

# Linux/macOS (Bash)
bash core/scripts/linux/redmine-api.sh get-projects config/project-config.json
```

### Test task creation:
```powershell
# Windows
.\core\scripts\script-manager.ps1 -Action "create-issue" -ConfigFile "config\project-config.json" -DataFile "tasks\sample-issues.json"

# Linux/macOS
bash core/scripts/linux/redmine-api.sh create-issue config/project-config.json tasks/sample-issues.json
```

## 🔄 Step 5: Experiment Safely

### What you can do:
- ✅ **Create tasks** and versions
- ✅ **Edit task descriptions**
- ✅ **Delete tasks** (learning mode enabled)
- ✅ **Reset project** completely
- ✅ **Test all features** without risk

### Safety features:
- **Automatic backups** before changes
- **Learning mode** allows everything
- **Easy reset** to clean state
- **No production data** at risk

## 🧹 Step 6: Cleanup

### Reset project:
```powershell
# Windows
.\scripts\manage-example-project.ps1 -Action reset

# Linux/macOS
./scripts/manage-example-project.sh reset
```

### Stop environment:
```powershell
# Windows
.\scripts\manage-example-project.ps1 -Action stop

# Linux/macOS
./scripts/manage-example-project.sh stop
```

## 🎓 What's Next?

1. **Explore the configuration files** in `config/`
2. **Read the project rules** in `config/project-rules.md`
3. **Try different script actions** (get-issues, create-version, etc.)
4. **Modify project rules** to see how they affect behavior
5. **Create your own tasks** and experiment with the workflow

## 🆘 Need Help?

### Check status:
```powershell
# Windows
.\scripts\manage-example-project.ps1 -Action status

# Linux/macOS
./scripts/manage-example-project.sh status
```

### View logs:
```powershell
# Windows
.\scripts\manage-example-project.ps1 -Action logs

# Linux/macOS
./scripts/manage-example-project.sh logs
```

### Common issues:
- **Port 3000 busy**: Stop other services using this port
- **Docker not running**: Start Docker Desktop
- **Permission denied**: Make scripts executable (`chmod +x *.sh`)

## 🎯 Success Checklist

- [ ] Environment started successfully
- [ ] Redmine accessible at http://localhost:3000
- [ ] Project created in Redmine
- [ ] API key configured in project-config.json
- [ ] Basic script operations working
- [ ] Ready to experiment!

---

**Congratulations!** You're now ready to explore Project AI Manager! 🎉

**Next**: Read the main [README.md](README.md) for detailed documentation.
