# Startup Guide - Windows, macOS & Linux

## Quick Start - Choose Your OS

### Windows Users

#### Option 1: Simple Batch File (Recommended)
```batch
.\start.bat
```

#### Option 2: PowerShell Script
```powershell
# First time only - allows execution of local scripts
Set-ExecutionPolicy -ExecutionPolicy RemoteSigned -Scope CurrentUser

# Then run the script
.\start.ps1
```

##### PowerShell Script Options:
```powershell
.\start.ps1                # Start all services
.\start.ps1 -CheckOnly    # Check prerequisites without starting
.\start.ps1 -Stop         # Stop all running services
.\start.ps1 -Help         # Show help
```

### macOS/Linux Users

Make the script executable first:
```bash
chmod +x start.sh
```

Then run:
```bash
./start.sh
```

---

## Prerequisites

Before running any startup script, ensure you have:

### 1. Docker & Docker Compose
- **Windows:** [Docker Desktop for Windows](https://www.docker.com/products/docker-desktop)
- **macOS:** [Docker Desktop for Mac](https://www.docker.com/products/docker-desktop)
- **Linux:** 
  ```bash
  sudo apt-get install docker.io docker-compose
  ```

  Or follow: https://docs.docker.com/engine/install/

### 2. Python 3.9+
- **Windows:** [python.org](https://www.python.org/downloads/)
- **macOS:** `brew install python3`
- **Linux:** `sudo apt-get install python3.9 python3-pip`

### 3. Tesseract OCR
- **Windows:** [Download installer](https://github.com/UB-Mannheim/tesseract/wiki) or `choco install tesseract`
- **macOS:** `brew install tesseract`
- **Linux:** `sudo apt-get install tesseract-ocr`

---

## What The Scripts Do

All startup scripts perform the same functions:

1. ✅ Check if Docker is installed
2. ✅ Check if Docker Compose is available
3. ✅ Start MongoDB (database)
4. ✅ Start Backend API (Django on port 8000)
5. ✅ Start Chat Protection Service (FastAPI on port 8001)
6. ✅ Start Frontend (Next.js on port 3000)
7. ✅ Wait for services to be ready (up to 60 seconds)
8. ✅ Display service URLs and next steps

---

## Verify Services Are Running

Once the script completes, verify all services are running:

### Check via Browser
- Backend API: http://localhost:8000
- Chat Protection: http://localhost:8001
- Frontend: http://localhost:3000
- API Documentation: http://localhost:8000/api/docs

### Check via Command Line
```bash
# Check all services
docker-compose ps

# View logs
docker-compose logs -f backend      # Backend API logs
docker-compose logs -f protection   # Protection service logs
docker-compose logs -f frontend     # Frontend logs
docker-compose logs -f mongodb      # Database logs
```

---

## Next Steps

### 1. Read Documentation
```
docs/CHAT_PROTECTION_INTEGRATION.md  # Complete integration guide
docs/INTEGRATION_CHECKLIST.md         # Setup verification
QUICK_REFERENCE.txt                   # Quick command reference
```

### 2. Test the System
```bash
# Get JWT token for testing (from your auth endpoint)
TOKEN="your_jwt_token_here"

# Test chat analysis
curl -X POST http://localhost:8000/api/chat/analyze/ \
  -H "Authorization: Bearer $TOKEN" \
  -d '{"content": "Hello, this is a test"}'
```

### 3. View Interactive API Docs
- Backend: http://localhost:8000/api/docs
- Protection: http://localhost:8001/docs

---

## Troubleshooting

### Issue: Docker is not running
**Solution:** 
- Windows/macOS: Open Docker Desktop
- Linux: `sudo systemctl start docker`

### Issue: Port already in use
**Solution:** Change ports in `docker-compose.yml` or stop other services:
```bash
# Find process on port 8000
lsof -i :8000                    # macOS/Linux
netstat -ano | findstr :8000    # Windows
```

### Issue: Services take too long to start
**Solution:** Check logs:
```bash
docker-compose logs backend
docker-compose logs protection
```

### Issue: "Cannot find Tesseract"
**Solution:** Install Tesseract OCR (see Prerequisites section)

### Issue: "Version obsolete" warning
**Solution:** You can ignore this warning - upcoming Docker Compose update will remove the `version` field requirement

### Issue: "Image not found"
**Solution:** Make sure all Docker images are built:
```bash
docker-compose build
docker-compose up -d
```

---

## Stop Services

### Windows
```batch
docker-compose down
```

Or use PowerShell:
```powershell
.\start.ps1 -Stop
```

### macOS/Linux
```bash
docker-compose down
```

---

## Development Tips

### Hot Reload
Services are configured with hot-reload:
- **Backend:** Auto-reloads on Python file changes
- **Frontend:** Auto-reloads on Next.js file changes
- **Protection:** Auto-reloads with Uvicorn

### View Real-time Logs
```bash
docker-compose logs -f             # All services
docker-compose logs -f backend     # Specific service
```

### Enter a Service Container
```bash
# Access backend shell
docker-compose exec backend bash

# Access protection service shell
docker-compose exec protection bash

# Access MongoDB shell
docker-compose exec mongodb mongosh
```

### Rebuild Services
```bash
# Rebuild all services with updated code
docker-compose build --no-cache
docker-compose up -d

# Or rebuild specific service
docker-compose build --no-cache backend
docker-compose up -d backend
```

### Reset Everything
```bash
# Stop and remove all containers, networks, volumes
docker-compose down -v

# Then restart
docker-compose up -d
```

---

## File Descriptions

| File | Purpose | OS |
|------|---------|-----|
| `start.bat` | Simple batch file starter | Windows |
| `start.ps1` | PowerShell starter script | Windows |
| `start.sh` | Bash startup script | Linux/macOS |
| `docker-compose.yml` | Multi-container orchestration | All |
| `.env.example` | Configuration template | All |
| `QUICK_REFERENCE.txt` | Command quick reference | All |

---

## Configuration

Copy the example environment file to use custom settings:

```bash
cp .env.example .env
```

Then edit `.env` to customize:
- Database connection strings
- API tokens
- Service ports
- Debug mode

---

## Getting Help

1. **Check Logs:**
   ```bash
   docker-compose logs
   ```

2. **Read Documentation:**
   - `docs/CHAT_PROTECTION_INTEGRATION.md` - Full setup guide
   - `docs/INTEGRATION_CHECKLIST.md` - Verification checklist

3. **API Documentation:**
   - http://localhost:8000/api/docs (Swagger UI)
   - http://localhost:8001/docs (Redoc UI)

4. **Common Issues:**
   See "Troubleshooting" section above

---

## Production Deployment

For production, consider:

1. Use environment-specific docker-compose files
2. Set `DEBUG=false` in environment
3. Configure CORS settings properly
4. Use environment secrets for API keys
5. Enable HTTPS/SSL
6. Set up monitoring and logging
7. Configure backup strategies for MongoDB

---

**Last Updated:** April 14, 2026  
**Status:** All scripts tested and working  

Happy coding! 🚀
