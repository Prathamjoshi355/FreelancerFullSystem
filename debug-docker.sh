#!/bin/bash
# Docker Build Debug Script - Diagnose build context issues

set -e

echo ""
echo "================================"
echo "Docker Build Context Diagnostic"
echo "================================"
echo ""

# Check if docker-compose is available
if ! command -v docker-compose &> /dev/null; then
    echo "[ERROR] docker-compose is not installed"
    exit 1
fi

echo "[1] Checking docker-compose configuration..."
echo ""

# Print build configuration
docker-compose config | grep -A 5 "build:"

echo ""
echo "[2] Verifying Dockerfile locations..."
echo ""

# Check each Dockerfile exists
DOCKERFILES=(
    "freelancerbackend/Dockerfile"
    "FreelancerChatProtection/Dockerfile"
    "freelance-frontend/Dockerfile"
)

for df in "${DOCKERFILES[@]}"; do
    if [ -f "$df" ]; then
        echo "[OK] $df exists"
    else
        echo "[ERROR] $df NOT FOUND"
    fi
done

echo ""
echo "[3] Checking build context visibility..."
echo ""

# Check frontend build context
echo "Frontend build context: ./freelance-frontend"
if [ -f "freelance-frontend/package.json" ]; then
    echo "[OK] freelance-frontend/package.json exists"
else
    echo "[ERROR] freelance-frontend/package.json NOT FOUND"
fi

if [ -f "freelance-frontend/Dockerfile" ]; then
    echo "[OK] freelance-frontend/Dockerfile exists"
else
    echo "[ERROR] freelance-frontend/Dockerfile NOT FOUND"
fi

echo ""
echo "[4] Checking for nested folder issue..."
echo ""

# Check for problematic nesting
if [ -d "freelance-frontend/freelance-frontend" ]; then
    echo "[WARNING] Double-nested folder found: freelance-frontend/freelance-frontend/"
    echo "This could cause COPY path issues"
else
    echo "[OK] No problematic nesting detected"
fi

echo ""
echo "[5] Extracting COPY commands from Dockerfiles..."
echo ""

for df in "${DOCKERFILES[@]}"; do
    if [ -f "$df" ]; then
        echo "=== $df ==="
        grep "^COPY" "$df" || echo "(No COPY commands found)"
        echo ""
    fi
done

echo ""
echo "[6] Simulating build context..."
echo ""

echo "Files visible to Docker (frontend build context):"
echo "Expected files in ./freelance-frontend/:"
echo ""
ls -la freelance-frontend/ | grep -E "package.json|pnpm-lock|Dockerfile|src|tsconfig" || echo "(Checking...)"

echo ""
echo "[DIAGNOSIS COMPLETE]"
echo ""
echo "If you see errors:"
echo "  1. Check COPY commands don't have extra path prefixes"
echo "  2. Verify Dockerfiles are in the correct folders"
echo "  3. Run: docker-compose build --no-cache to rebuild"
echo ""
