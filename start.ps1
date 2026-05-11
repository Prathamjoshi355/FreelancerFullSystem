# FreelancerChatProtection Integration - Quick Start Script (Windows)
# Run this script to start all services

param(
    [switch]$Help,
    [switch]$CheckOnly,
    [switch]$Stop
)

function Write-Section {
    param([string]$Text, [string]$Color = "Cyan")
    Write-Host ""
    Write-Host $Text -ForegroundColor $Color
}

function Write-Success {
    param([string]$Text)
    Write-Host "[OK] $Text" -ForegroundColor Green
}

function Write-ErrorMsg {
    param([string]$Text)
    Write-Host "[ERROR] $Text" -ForegroundColor Red
}

function Write-WarningMsg {
    param([string]$Text)
    Write-Host "[WARN] $Text" -ForegroundColor Yellow
}

function Write-InfoMsg {
    param([string]$Text)
    Write-Host "[INFO] $Text" -ForegroundColor Cyan
}

if ($Help) {
    Write-Section "Freelancer Chat Protection - Quick Start" "Cyan"
    Write-Host "Usage: .\start.ps1 [options]" -ForegroundColor Yellow
    Write-Host ""
    Write-Host "Options:"
    Write-Host "  -Help       Show this help message"
    Write-Host "  -CheckOnly  Check prerequisites without starting"
    Write-Host "  -Stop       Stop all running services"
    exit 0
}

Write-Section "Starting Freelancer Platform with Chat Protection" "Cyan"

# Check prerequisites
Write-Section "Checking Prerequisites..." "Yellow"

$Prerequisites = @{
    "Python" = "python --version"
    "Docker" = "docker --version"
    "Docker Compose" = "docker-compose --version"
    "Tesseract OCR" = "tesseract --version"
}

$AllReady = $true

foreach ($Tool in $Prerequisites.GetEnumerator()) {
    try {
        $Output = & Invoke-Expression $Tool.Value 2>$null
        if ($?) {
            Write-Success "$($Tool.Name): Ready"
        } else {
            Write-ErrorMsg "$($Tool.Name): Not found or not in PATH"
            $AllReady = $false
        }
    } catch {
        Write-WarningMsg "$($Tool.Name): Not found - $($_.Exception.Message)"
        $AllReady = $false
    }
}

if ($CheckOnly) {
    if ($AllReady) {
        Write-Section "All prerequisites are installed!" "Green"
        exit 0
    } else {
        Write-Section "Some prerequisites are missing. Please install them first." "Red"
        exit 1
    }
}

if (-not $AllReady) {
    Write-Section "Missing Prerequisites" "Red"
    Write-Host ""
    Write-Host "Please ensure the following are installed:"
    Write-Host "1. Python 3.9+ - https://www.python.org/downloads/"
    Write-Host "2. Docker Desktop - https://www.docker.com/products/docker-desktop"
    Write-Host "3. Tesseract OCR - https://github.com/UB-Mannheim/tesseract/wiki"
    exit 1
}

# Handle stop command
if ($Stop) {
    Write-Section "Stopping services..." "Yellow"
    docker-compose down
    Write-Success "Services stopped"
    exit 0
}

# Create logs directory
$LogDir = Join-Path (Get-Location) "logs"
if (-not (Test-Path $LogDir)) {
    New-Item -ItemType Directory -Path $LogDir | Out-Null
    Write-InfoMsg "Created logs directory"
}

# Start services
Write-Section "Starting Services..." "Yellow"
docker-compose up -d

if ($?) {
    Write-Success "Services started"
} else {
    Write-ErrorMsg "Failed to start services"
    exit 1
}

Write-Section "Service URLs" "Cyan"
Write-Host "   • Backend API:        http://localhost:8000"
Write-Host "   • Chat Protection:    http://localhost:8001"
Write-Host "   • Face Verification:  http://localhost:8002"
Write-Host "   • Frontend:           http://localhost:3000"
Write-Host "   • MongoDB:            mongodb://localhost:27017"

Write-Section "Waiting for services to be ready..." "Yellow"

$ServicesReady = $false
$MaxAttempts = 60
$Attempt = 0

while (-not $ServicesReady -and $Attempt -lt $MaxAttempts) {
    try {
        $Backend = Invoke-WebRequest -Uri "http://localhost:8000/api/health/" -UseBasicParsing -ErrorAction SilentlyContinue
        $Protection = Invoke-WebRequest -Uri "http://localhost:8001/docs" -UseBasicParsing -ErrorAction SilentlyContinue
        $FaceVerification = Invoke-WebRequest -Uri "http://localhost:8002/health" -UseBasicParsing -ErrorAction SilentlyContinue
        
        if ($Backend.StatusCode -eq 200 -and $Protection.StatusCode -eq 200 -and $FaceVerification.StatusCode -eq 200) {
            $ServicesReady = $true
        } else {
            Write-Host "   Waiting... (Attempt $($Attempt + 1)/$MaxAttempts)"
            Start-Sleep -Seconds 2
            $Attempt++
        }
    } catch {
        Write-Host "   Waiting... (Attempt $($Attempt + 1)/$MaxAttempts)"
        Start-Sleep -Seconds 2
        $Attempt++
    }
}

if ($ServicesReady) {
    Write-Section "All services are ready!" "Green"
    Write-Section "Documentation and Testing" "Cyan"
    Write-Host "   • Integration Guide:     docs/CHAT_PROTECTION_INTEGRATION.md"
    Write-Host "   • Backend API Docs:      http://localhost:8000/api/docs"
    Write-Host "   • Protection API:        http://localhost:8001/docs"
    Write-Host "   • Face Verification API: http://localhost:8002/docs"
    
    Write-Section "View Logs" "Cyan"
    Write-Host "   docker-compose logs -f backend"
    Write-Host "   docker-compose logs -f protection"
    Write-Host "   docker-compose logs -f face-verification"
    Write-Host "   docker-compose logs -f frontend"
    
    Write-Host ""
} else {
    Write-WarningMsg "Some services took too long to start. Check logs:"
    Write-Host "   docker-compose logs"
    exit 1
}
