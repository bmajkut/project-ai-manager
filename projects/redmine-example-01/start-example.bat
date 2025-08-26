@echo off
REM Redmine Example 01 - Start Script (Windows Batch)
REM This script starts the Redmine learning environment and automatically seeds data

title Redmine Example 01 - Start Script

echo.
echo ========================================
echo     Redmine Example 01 Learning Environment
echo ========================================
echo.
echo Starting Redmine learning environment...
echo.

REM Check if Docker is running
docker version >nul 2>&1
if %errorlevel% neq 0 (
    echo [ERROR] Docker is not running or not installed. Please start Docker Desktop.
    pause
    exit /b 1
)

REM Check if Docker Compose is available
docker-compose version >nul 2>&1
if %errorlevel% neq 0 (
    echo [ERROR] Docker Compose is not available. Please install Docker Compose.
    pause
    exit /b 1
)

echo [SUCCESS] Docker and Docker Compose are available
echo.

REM Create data directories if they don't exist
if not exist "data\postgres" (
    echo [INFO] Creating data directories...
    mkdir "data\postgres" 2>nul
    echo [SUCCESS] Data directories created
)

REM Start Docker services
echo [INFO] Starting Docker services...
docker-compose up -d
if %errorlevel% neq 0 (
    echo [ERROR] Failed to start Docker services
    pause
    exit /b 1
)

echo [SUCCESS] Docker services started successfully
echo.

REM Wait for services to be ready
echo [INFO] Waiting for services to start...
set wait_count=0
set max_wait=20

:wait_loop
timeout /t 30 /nobreak >nul
set /a wait_count+=1

REM Try to connect to Redmine
powershell -Command "try { $response = Invoke-WebRequest -Uri 'http://localhost:3000' -Method GET -TimeoutSec 5; if ($response.StatusCode -eq 200) { exit 0 } else { exit 1 } } catch { exit 1 }" >nul 2>&1
if %errorlevel% equ 0 (
    echo [SUCCESS] Redmine is now accessible!
    goto :services_ready
)

if %wait_count% geq %max_wait% (
    echo [WARNING] Redmine is taking longer than expected to start
    echo [INFO] You can check the status with: docker-compose ps
    echo [INFO] View logs with: docker-compose logs -f redmine
    goto :services_ready
)

echo [INFO] Still waiting for Redmine to start... (%wait_count% * 30s)
goto :wait_loop

:services_ready
REM Display service status
echo.
echo [INFO] Service status:
docker-compose ps

echo.
echo [SUCCESS] Redmine learning environment is ready!
echo.

REM Generate API token using Core script
echo [INFO] Starting API token generation process using Core script...
set core_script=..\..\core\scripts\windows\redmine\generate-api-token.ps1
set config_file=config\config.json

if exist "%core_script%" (
    echo [INFO] Running Core token generation script: %core_script%
    echo [INFO] Config file: %config_file%
    powershell -ExecutionPolicy Bypass -File "%core_script%" -ConfigFile "%config_file%" -CredentialsFile "config\credentials.env"
    if %errorlevel% equ 0 (
        echo.
        echo [SUCCESS] Environment setup completed successfully!
        echo.
        echo Access URLs:
        echo   Redmine: http://localhost:3000
        echo   Adminer: http://localhost:8080
        echo.
        echo Default credentials:
        echo   Username: admin
        echo   Password: Zaq1xsw@
        echo.
        echo What's ready:
        echo   ✅ Redmine application running
        echo   ✅ API token generated
        echo   ✅ Configuration files updated
        echo   ✅ Ready for AI integration testing
    ) else (
        echo.
        echo [WARNING] Environment started but token generation failed
        echo You can run token generation manually: %core_script% -ConfigFile "%config_file%"
    )
) else (
    echo [ERROR] Core token generation script not found: %core_script%
    echo.
    echo [WARNING] Environment started but Core token generation script not found
)

echo.
echo Useful commands:
echo   View logs: docker-compose logs -f
echo   Stop services: docker-compose down
echo   Restart: docker-compose restart
echo   Manual token generation: %core_script% -ConfigFile "%config_file%"
echo.

pause
