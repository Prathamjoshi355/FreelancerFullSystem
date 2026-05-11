@echo off
REM Docker Build Debug Script - Diagnose build context issues (Windows Batch)

setlocal enabledelayedexpansion

cls
echo.
echo ================================
echo Docker Build Context Diagnostic
echo ================================
echo.

REM Check if docker-compose is available
where docker-compose >nul 2>nul
if errorlevel 1 (
    echo [ERROR] docker-compose is not installed
    pause
    exit /b 1
)

echo [1] Checking docker-compose configuration...
echo.

REM Print build configuration
docker-compose config | findstr /R "^.*build:" || echo (Build config not shown)

echo.
echo [2] Verifying Dockerfile locations...
echo.

REM Check each Dockerfile exists
if exist "freelancerbackend\Dockerfile" (
    echo [OK] freelancerbackend\Dockerfile exists
) else (
    echo [ERROR] freelancerbackend\Dockerfile NOT FOUND
)

if exist "FreelancerChatProtection\Dockerfile" (
    echo [OK] FreelancerChatProtection\Dockerfile exists
) else (
    echo [ERROR] FreelancerChatProtection\Dockerfile NOT FOUND
)

if exist "freelance-frontend\Dockerfile" (
    echo [OK] freelance-frontend\Dockerfile exists
) else (
    echo [ERROR] freelance-frontend\Dockerfile NOT FOUND
)

echo.
echo [3] Checking build context visibility...
echo.

echo Frontend build context: .\freelance-frontend
if exist "freelance-frontend\package.json" (
    echo [OK] freelance-frontend\package.json exists
) else (
    echo [ERROR] freelance-frontend\package.json NOT FOUND
)

if exist "freelance-frontend\Dockerfile" (
    echo [OK] freelance-frontend\Dockerfile exists
) else (
    echo [ERROR] freelance-frontend\Dockerfile NOT FOUND
)

echo.
echo [4] Checking for nested folder issue...
echo.

if exist "freelance-frontend\freelance-frontend" (
    echo [WARNING] Double-nested folder found: freelance-frontend\freelance-frontend\
    echo This could cause COPY path issues
) else (
    echo [OK] No problematic nesting detected
)

echo.
echo [5] Extracting COPY commands from Dockerfiles...
echo.

if exist "freelance-frontend\Dockerfile" (
    echo === freelance-frontend\Dockerfile ===
    findstr "^COPY" freelance-frontend\Dockerfile || echo (No COPY commands found)
    echo.
)

if exist "freelancerbackend\Dockerfile" (
    echo === freelancerbackend\Dockerfile ===
    findstr "^COPY" freelancerbackend\Dockerfile || echo (No COPY commands found)
    echo.
)

if exist "FreelancerChatProtection\Dockerfile" (
    echo === FreelancerChatProtection\Dockerfile ===
    findstr "^COPY" FreelancerChatProtection\Dockerfile || echo (No COPY commands found)
    echo.
)

echo [6] Checking file structure...
echo.

echo Files in .\freelance-frontend\:
echo.
dir freelance-frontend\ | findstr "package pnpm Dockerfile src tsconfig next" || echo (Checking...)

echo.
echo [7] Docker Build Context Summary...
echo.

echo Frontend Context Mapping:
echo   Build Context: .\freelance-frontend
echo   Docker sees: /build/
echo.
echo   Your files:                      Docker sees:
echo   V freelance-frontend\package.json  -  /build/package.json
echo   V freelance-frontend\src\          -  /build/src/
echo   V freelance-frontend\Dockerfile    -  (implicit)
echo.
echo   X NOT visible to Docker:
echo   X freelance-frontend\freelance-frontend\  (double nesting!)
echo.

echo [DIAGNOSIS COMPLETE]
echo.

echo Next Steps:
echo   1. Review COPY commands - they should NOT have 'freelance-frontend/' prefix
echo   2. Verify Dockerfiles are in correct service folders
echo   3. Run: docker-compose build --no-cache frontend
echo.

pause
