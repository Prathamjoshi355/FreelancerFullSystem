# Docker Build Debug Script - Diagnose build context issues (Windows)

param(
    [switch]$Full = $false
)

Write-Host ""
Write-Host "================================" -ForegroundColor Cyan
Write-Host "Docker Build Context Diagnostic" -ForegroundColor Cyan
Write-Host "================================" -ForegroundColor Cyan
Write-Host ""

# Check if docker-compose is available
$DockerCompose = Get-Command docker-compose -ErrorAction SilentlyContinue
if (-not $DockerCompose) {
    Write-Host "[ERROR] docker-compose is not installed" -ForegroundColor Red
    exit 1
}

Write-Host "[1] Checking docker-compose configuration..." -ForegroundColor Yellow
Write-Host ""

# Print build configuration
$BuildConfig = & docker-compose config | Select-String -Pattern "build:" -Context 0, 5
Write-Host $BuildConfig

Write-Host ""
Write-Host "[2] Verifying Dockerfile locations..." -ForegroundColor Yellow
Write-Host ""

# Check each Dockerfile exists
$Dockerfiles = @(
    "freelancerbackend/Dockerfile",
    "FreelancerChatProtection/Dockerfile",
    "freelance-frontend/Dockerfile"
)

foreach ($df in $Dockerfiles) {
    if (Test-Path $df) {
        Write-Host "[OK] $df exists" -ForegroundColor Green
    } else {
        Write-Host "[ERROR] $df NOT FOUND" -ForegroundColor Red
    }
}

Write-Host ""
Write-Host "[3] Checking build context visibility..." -ForegroundColor Yellow
Write-Host ""

# Check frontend build context
Write-Host "Frontend build context: ./freelance-frontend" -ForegroundColor Cyan
if (Test-Path "freelance-frontend/package.json") {
    Write-Host "[OK] freelance-frontend/package.json exists" -ForegroundColor Green
} else {
    Write-Host "[ERROR] freelance-frontend/package.json NOT FOUND" -ForegroundColor Red
}

if (Test-Path "freelance-frontend/Dockerfile") {
    Write-Host "[OK] freelance-frontend/Dockerfile exists" -ForegroundColor Green
} else {
    Write-Host "[ERROR] freelance-frontend/Dockerfile NOT FOUND" -ForegroundColor Red
}

Write-Host ""
Write-Host "[4] Checking for nested folder issue..." -ForegroundColor Yellow
Write-Host ""

# Check for problematic nesting
if (Test-Path "freelance-frontend/freelance-frontend") {
    Write-Host "[WARNING] Double-nested folder found: freelance-frontend/freelance-frontend/" -ForegroundColor Yellow
    Write-Host "This could cause COPY path issues" -ForegroundColor Yellow
} else {
    Write-Host "[OK] No problematic nesting detected" -ForegroundColor Green
}

Write-Host ""
Write-Host "[5] Extracting COPY commands from Dockerfiles..." -ForegroundColor Yellow
Write-Host ""

foreach ($df in $Dockerfiles) {
    if (Test-Path $df) {
        Write-Host "=== $df ===" -ForegroundColor Cyan
        $CopyCommands = Get-Content $df | Select-String "^COPY"
        if ($CopyCommands) {
            Write-Host $CopyCommands -ForegroundColor Gray
        } else {
            Write-Host "(No COPY commands found)" -ForegroundColor Gray
        }
        Write-Host ""
    }
}

Write-Host "[6] Checking file structure..." -ForegroundColor Yellow
Write-Host ""

Write-Host "Files in ./freelance-frontend/:" -ForegroundColor Cyan
$FrontendFiles = Get-ChildItem "freelance-frontend/" -ErrorAction SilentlyContinue | 
    Where-Object { $_.Name -match "package|pnpm|Dockerfile|src|tsconfig|next" }

if ($FrontendFiles) {
    $FrontendFiles | ForEach-Object { Write-Host "  ✓ $($_.Name)" -ForegroundColor Green }
} else {
    Write-Host "  (Checking...)" -ForegroundColor Gray
}

Write-Host ""
Write-Host "[7] Docker Build Context Summary..." -ForegroundColor Yellow
Write-Host ""

$ContextSummary = @"
Frontend Context Mapping:
  Build Context: ./freelance-frontend
  Docker sees: /build/
  
  Your files:              Docker sees:
  ✓ freelance-frontend/package.json  →  /build/package.json
  ✓ freelance-frontend/src/          →  /build/src/
  ✓ freelance-frontend/Dockerfile    →  (implicit)
  
  ✗ NOT visible to Docker:
  ✗ freelance-frontend/freelance-frontend/  (double nesting!)
"@

Write-Host $ContextSummary -ForegroundColor Gray

Write-Host ""
Write-Host "[DIAGNOSIS COMPLETE]" -ForegroundColor Cyan
Write-Host ""

Write-Host "Next Steps:" -ForegroundColor Yellow
Write-Host "  1. Review COPY commands - they should NOT have 'freelance-frontend/' prefix"
Write-Host "  2. Verify Dockerfiles are in correct service folders"
Write-Host "  3. Run: docker-compose build --no-cache frontend" -ForegroundColor Cyan
Write-Host ""

if ($Full) {
    Write-Host ""
    Write-Host "[Additional Debugging]" -ForegroundColor Yellow
    Write-Host ""
    Write-Host "Full docker-compose config:" -ForegroundColor Cyan
    & docker-compose config | Write-Host -ForegroundColor Gray
}
