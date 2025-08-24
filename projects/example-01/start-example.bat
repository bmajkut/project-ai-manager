@echo off
REM Example-01 Learning Project Startup Script
REM Project AI Manager - Safe learning environment
REM Author: Bartosz Majkut

echo ========================================
echo    Project AI Manager - Example-01
echo ========================================
echo.
echo Starting learning environment...
echo.

REM Check if Docker is running
docker --version >nul 2>&1
if %errorlevel% neq 0 (
    echo ERROR: Docker is not running or not installed!
    echo Please start Docker Desktop and try again.
    echo.
    pause
    exit /b 1
)

REM Check if we're in the right directory
if not exist "scripts\manage-example-project.ps1" (
    echo ERROR: Please run this script from the example-01 directory!
    echo.
    pause
    exit /b 1
)

echo Docker is running. Starting environment...
echo.

REM Start the environment using PowerShell script
powershell -ExecutionPolicy Bypass -File "scripts\manage-example-project.ps1" -Action start

echo.
echo ========================================
echo Environment startup completed!
echo ========================================
echo.
echo Next steps:
echo 1. Open http://localhost:3000 in your browser
echo 2. Login with admin/admin
echo 3. Create project "Example-01"
echo 4. Get API key from My Account
echo 5. Update config/project-config.json
echo.
echo For detailed instructions, see QUICK-START.md
echo.
pause
