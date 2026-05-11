@echo off
REM FreelancerChatProtection Integration - Quick Start Script (Windows)
REM Run this script to start all services

setlocal enabledelayedexpansion

set "SCRIPT_DIR=%~dp0"
cd /d "%SCRIPT_DIR%"

echo.
echo Starting Freelancer Platform with Chat Protection
echo.

REM Check if docker-compose is available
where docker-compose >nul 2>nul
if errorlevel 1 (
    echo [ERROR] Docker Compose is not installed or not in PATH
    echo Please install Docker Desktop: https://www.docker.com/products/docker-desktop
    pause
    exit /b 1
)

REM Create logs directory
if not exist "logs" (
    mkdir logs
    echo [INFO] Created logs directory
)

REM Start services
echo [INFO] Starting services with Docker Compose...
docker-compose up -d

if errorlevel 1 (
    echo [ERROR] Failed to start services
    pause
    exit /b 1
)

echo.
echo [OK] Services are starting!
echo.
echo Service URLs:
echo    - Backend API:        http://localhost:8000
echo    - Chat Protection:    http://localhost:8001
echo    - Face Verification:  http://localhost:8002
echo    - Frontend:           http://localhost:3000
echo    - MongoDB:            mongodb://localhost:27017
echo.
echo [INFO] Waiting for services to be ready...
echo.

REM Wait for services to be ready (max 120 seconds)
set "MAX_ATTEMPTS=60"
set "ATTEMPT=0"
set "SERVICES_READY=0"

:wait_loop
if %ATTEMPT% geq %MAX_ATTEMPTS% goto wait_timeout

set /a ATTEMPT=%ATTEMPT%+1
echo    Waiting... (Attempt %ATTEMPT%/%MAX_ATTEMPTS%)

REM Try to reach backend health check
curl -s http://localhost:8000/api/health/ >nul 2>nul
if errorlevel 1 goto wait_sleep

curl -s http://localhost:8001/docs >nul 2>nul
if errorlevel 1 goto wait_sleep

curl -s http://localhost:8002/health >nul 2>nul
if errorlevel 1 goto wait_sleep

set "SERVICES_READY=1"
goto wait_ready

:wait_sleep
timeout /t 2 /nobreak >nul
goto wait_loop

:wait_timeout
echo.
echo [WARN] Services took too long to start. Check logs:
echo    docker-compose logs
echo.
goto exit_script

:wait_ready
echo.
echo [OK] All services are ready!
echo.
echo Documentation and Testing:
echo    - Integration Guide:     docs/CHAT_PROTECTION_INTEGRATION.md
echo    - Backend API Docs:      http://localhost:8000/api/docs
echo    - Protection API:        http://localhost:8001/docs
echo    - Face Verification API: http://localhost:8002/docs
echo.
echo View Logs:
echo    docker-compose logs -f backend
echo    docker-compose logs -f protection
echo    docker-compose logs -f face-verification
echo    docker-compose logs -f frontend
echo.

:exit_script
echo Done!
pause
