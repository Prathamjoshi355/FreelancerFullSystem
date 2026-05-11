# FreelancerChatProtection Integration Guide

## Overview

The **FreelancerChatProtection** module is a standalone OCR + text processing service that analyzes chat messages and attachments for fraud detection and restricted content.

## Architecture

```
┌─────────────────────┐
│  Frontend (Next.js) │
└──────────┬──────────┘
           │
           ▼
┌─────────────────────┐         ┌──────────────────────┐
│  Backend (Django)   │────────▶│  Chat Protection     │
│  - Chat Views       │         │  - OCR Service       │
│  - Message API      │         │  - Text Analysis     │
│  - Protection Logic │         │  - Content Detection │
└─────────────────────┘         └──────────────────────┘
```

## Services

### 1. **Backend Service** (Django)
- **Port:** 8000
- **Purpose:** Main API server for chat, jobs, profiles, etc.
- **Location:** `freelancerbackend/`

### 2. **Chat Protection Service** (FastAPI)
- **Port:** 8001
- **Purpose:** OCR + text processing for image analysis
- **Location:** `FreelancerChatProtection/`

## Setup & Installation

### Prerequisites
- Python 3.9+
- Tesseract OCR binary (must be installed separately on host machine)

### Install Tesseract OCR

#### Windows
```powershell
# Download and install from: https://github.com/UB-Mannheim/tesseract/wiki
# Or use chocolatey:
choco install tesseract
```

#### macOS
```bash
brew install tesseract
```

#### Linux (Ubuntu/Debian)
```bash
sudo apt-get install tesseract-ocr
```

### Install Dependencies

```bash
# Install backend dependencies (includes OCR libraries)
cd freelancerbackend
pip install -r requirements.txt

# Install protection service dependencies
cd ../FreelancerChatProtection
pip install -r requirements.txt
```

## Running the Services

### Option 1: Run Both Services (Recommended for Development)

#### Terminal 1 - Backend Service
```bash
cd freelancerbackend
python manage.py migrate
python manage.py runserver 0.0.0.0:8000
```

#### Terminal 2 - Chat Protection Service
```bash
cd FreelancerChatProtection
uvicorn main:app --host 0.0.0.0 --port 8001 --reload
```

### Option 2: Docker (Production)

Create a `docker-compose.yml` at the root:

```yaml
version: '3.8'

services:
  backend:
    build: ./freelancerbackend
    ports:
      - "8000:8000"
    environment:
      - DEBUG=false
      - DATABASE_URL=mongodb://mongo:27017/freelancer
    depends_on:
      - mongo
    volumes:
      - ./freelancerbackend:/app

  protection:
    build: ./FreelancerChatProtection
    ports:
      - "8001:8001"
    volumes:
      - ./FreelancerChatProtection:/app

  mongo:
    image: mongo:7.0
    ports:
      - "27017:27017"
    volumes:
      - mongo_data:/data/db

volumes:
  mongo_data:
```

Run with:
```bash
docker-compose up -d
```

## API Integration

### Chat Message Analysis Endpoint

**Endpoint:** `POST /api/chat/analyze/`

**Request:**
```json
{
  "content": "User's message text",
  "file": "<optional multipart file upload>"
}
```

**Response:**
```json
{
  "blocked": false,
  "message_flags": ["clean"],
  "attachment_flags": [],
  "moderation_flags": [],
  "normalized_text": "cleaned message text",
  "attachment": {
    "attachment_name": "image.png",
    "attachment_type": "image",
    "attachment_scan_status": "completed",
    "attachment_scan_error": "",
    "attachment_extracted_text": "text extracted from image"
  }
}
```

### Image Analysis Endpoint (Direct)

**Endpoint:** `POST /analyze-image` (Protection Service)

**Request:** Multipart form data
- `file`: Image file
- `enable_enhancement`: true/false

**Response:**
```json
{
  "raw_text": "extracted text",
  "processed_text": "cleaned and enhanced text",
  "language": "en",
  "confidence": 0.95,
  "processing_time_ms": 1250
}
```

## Features

### 1. **Image OCR**
- Detects and extracts text from attachment images
- Supports: PNG, JPG, JPEG, BMP, TIFF, WebP
- Uses Tesseract for high-accuracy text extraction
- Optional text enhancement via rule-based normalization

### 2. **Content Detection**
- Detects restricted content in messages
- Flags potentially harmful patterns
- Supports multiple content types:
  - Payment method info
  - Contact information (emails, phones)
  - Identity information
  - Suspicious patterns

### 3. **Message Protection**
- Analyzes text content
- Analyzes image attachments
- Combines results for comprehensive moderation
- Returns clear flags for blocked vs allowed messages

### 4. **Attachment Inspection**
- Images: OCR extraction
- PDFs: Text extraction via pypdf
- Text files: Direct text reading
- Returns extracted text and status

## Integration Points

### Authentication
All chat endpoints require JWT authentication via header:
```
Authorization: Bearer <jwt_token>
```

### Error Handling
- Missing files → `attachment_scan_status: "not_applicable"`
- OCR failures → `attachment_scan_status: "failed"` + error message
- Text extraction → Gracefully degrades, returns available text

### Configuration

**Backend Settings** (`freelancerbackend/settings.py`):
```python
# Chat Protection
CHAT_PROTECTION_ENABLED = True
CHAT_PROTECTION_SERVICE_URL = "http://localhost:8001"
```

**Protection Service Settings** (`FreelancerChatProtection/main.py`):
```python
# Tesseract path (if custom location)
OCRConfig(tesseract_cmd="/usr/bin/tesseract")

# Image preprocessing options
OCRConfig(
    resize_scale=2.0,  # Upscale for better recognition
    gaussian_kernel_size=(5, 5),  # Denoise
    tesseract_config="--oem 3 --psm 6",  # OCR settings
    enable_enhancement=True  # Text cleanup
)
```

## Testing

### Test Chat Message Analysis
```python
# test_protection.py
import requests

response = requests.post(
    "http://localhost:8000/api/chat/analyze/",
    json={"content": "Hello! Let's chat on WhatsApp: +1234567890"},
    headers={"Authorization": "Bearer YOUR_JWT_TOKEN"}
)
print(response.json())
```

### Test Image OCR
```bash
curl -X POST "http://localhost:8001/analyze-image" \
  -F "file=@screenshot.png" \
  -F "enable_enhancement=true"
```

## Monitoring & Logging

### Backend Logs
```bash
# Check Django logs
tail -f freelancerbackend/logs/django.log

# Test endpoint health
curl http://localhost:8000/api/health/
```

### Protection Service Logs
```bash
# Uvicorn logs show in terminal, or:
curl http://localhost:8001/docs  # Interactive API docs
```

## Troubleshooting

### Issue: Tesseract not found
**Solution:** Install Tesseract OCR binary on your system (see Prerequisites above)

### Issue: Images not being analyzed
**Solution:** Ensure Protection Service is running on port 8001

### Issue: Import errors with FreelancerChatProtection
**Solution:** Add FreelancerChatProtection to Python path or install as package

### Issue: Memory issues with large images
**Solution:** Configure preprocessing in OCRConfig to use lower `resize_scale` values

## Project Structure

```
freelance-frontend/
├── freelancerbackend/          # Django backend
│   ├── chat/
│   │   ├── views.py            # Chat endpoints with protection
│   │   ├── protection.py        # Protection logic
│   │   ├── attachments.py       # Attachment handling & OCR
│   │   └── models.py
│   └── requirements.txt
│
├── FreelancerChatProtection/    # FastAPI OCR service
│   ├── main.py                  # FastAPI app & endpoints
│   ├── image_ocr.py             # OCR orchestration
│   ├── preprocessing.py         # Image preprocessing
│   ├── text_cleaner.py          # Text normalization
│   ├── exceptions.py
│   └── requirements.txt
│
└── freelance-frontend/          # Next.js frontend
    └── src/
        └── services/
            └── chat.ts          # Chat service with API calls
```

## Performance Metrics

- **Text Analysis:** ~10-50ms per message
- **Image OCR:** ~500ms-2s per image (depends on size)
- **PDF Extraction:** ~100-500ms per page
- **Concurrent requests:** Handles multiple simultaneous analyses

## Security Considerations

1. **Input Validation:** All inputs validated before processing
2. **File Upload Limits:** Max file size configurable (default: 10MB)
3. **Temporary Files:** Cleaned up immediately after processing
4. **Service Isolation:** Protection service can run on separate infrastructure
5. **Rate Limiting:** Can be added at reverse proxy level

## Next Steps

1. ✅ Install Tesseract OCR on your system
2. ✅ Run both services as described above
3. ✅ Test endpoints using provided curl/Python examples
4. ✅ Configure environment variables as needed
5. ✅ Deploy to production with Docker

## Support

For issues or questions:
- Check logs in both services
- Verify both services are running on correct ports
- Ensure Tesseract is properly installed
- Review test files for usage examples

