# Face Verification Microservice - Complete Setup Guide

## Overview

The Face Verification Microservice is a FastAPI-based service that detects duplicate users by analyzing face images using deep learning embeddings (InsightFace/ArcFace) and vector similarity search (FAISS).

### System Architecture

```
┌─────────────────────┐
│   Django Backend    │
├─────────────────────┤
│  Registration Flow  │
│  User Signup        │
└──────────┬──────────┘
           │ POST /api/verify-face
           │ [base64 images, user_id]
           ▼
┌─────────────────────────────────────┐
│   Face Verification Service         │
│   (FastAPI on port 8001)            │
├─────────────────────────────────────┤
│ 1. Image Decoding & Validation      │
│ 2. Face Detection (InsightFace)     │
│ 3. Embedding Generation (ArcFace)   │
│ 4. Vector Search (FAISS)            │
│ 5. Similarity Calculation           │
│ 6. Decision Logic                   │
└──────────┬──────────────────────────┘
           │ Response with decision
           │ (allow/reject/suspicious)
           ▼
┌─────────────────────┐
│  MongoDB Database   │
├─────────────────────┤
│ - Face Embeddings   │
│ - Verification Logs │
└─────────────────────┘
```

---

## PART 1: FastAPI Microservice Setup

### 1.1 Prerequisites

- Python 3.9+
- pip or conda
- ~2GB disk space (for models)
- GPU optional (ONNX Runtime can use CPU)

### 1.2 Installation

#### Step 1: Create Virtual Environment

```bash
cd face-verification-service

# Using venv
python -m venv venv

# Activate
# On Windows:
venv\Scripts\activate
# On Linux/Mac:
source venv/bin/activate
```

#### Step 2: Install Dependencies

```bash
pip install -r requirements.txt
```

**Note**: First install might take 10-15 minutes as it downloads ML models (~500MB).

#### Step 3: Create Directory Structure

```bash
mkdir -p data/models
```

#### Step 4: Configure Environment

Update `.env` file with your settings:

```env
# Service Configuration
SERVICE_PORT=8001
SERVICE_HOST=0.0.0.0
ENVIRONMENT=development

# Model Settings
MODEL_NAME=buffalo_l  # High-performance face recognition model
MAX_FACE_SIZE=4       # Max face detection size in MP

# Decision Thresholds
REJECT_THRESHOLD=0.85        # Similarity >= 0.85 → REJECT
SUSPICIOUS_THRESHOLD=0.75    # Similarity >= 0.75 → SUSPICIOUS

# Storage
VECTOR_STORE_PATH=./data/face_embeddings.faiss
METADATA_PATH=./data/metadata.json

# Django Backend
DJANGO_API_URL=http://localhost:8000

# Logging
LOG_LEVEL=INFO
```

### 1.3 Run the Service

```bash
# Development mode (with auto-reload)
python -m uvicorn app.main:app --reload --host 0.0.0.0 --port 8001

# Production mode
python -m uvicorn app.main:app --host 0.0.0.0 --port 8001 --workers 4
```

#### Verify Service is Running

```bash
# Check health
curl http://localhost:8001/health

# Expected response:
{
  "status": "healthy",
  "model_loaded": true,
  "index_ready": true,
  "message": "Service running. Embeddings in index: 0"
}
```

### 1.4 API Documentation

#### Auto-generated Docs
- Swagger UI: `http://localhost:8001/docs`
- ReDoc: `http://localhost:8001/redoc`

---

## PART 2: Django Backend Integration

### 2.1 Prerequisites

Your existing Django project with:
- MongoDB configured
- djangorestframework installed
- CustomUser model with face_verified field

### 2.2 Installation

#### Step 1: Install Dependencies

```bash
pip install requests httpx
```

#### Step 2: Add Service URL to Django Settings

```python
# settings.py
FACE_VERIFICATION_SERVICE_URL = os.getenv(
    "FACE_VERIFICATION_SERVICE_URL",
    "http://localhost:8001"
)
```

#### Step 3: Update Django .env

```env
FACE_VERIFICATION_SERVICE_URL=http://localhost:8001
```

#### Step 4: Migrate Face Verification Models

The system creates MongoDB collections automatically:
- `face_embeddings`: Stores face vectors per user
- `face_verification_logs`: Audit trail of verification attempts

No Django migrations needed (MongoDB is schema-free).

### 2.3 Integration: Signup Flow

#### Current Registration Endpoint

**POST** `/auth/register/`

**Request:**
```json
{
  "email": "user@example.com",
  "password": "SecurePassword123",
  "role": "freelancer",
  "face_images": [
    "data:image/jpeg;base64,/9j/4AAQSkZJRg...",
    "data:image/jpeg;base64,/9j/4AAQSkZJRg...",
    "data:image/jpeg;base64,/9j/4AAQSkZJRg..."
  ]
}
```

**Fields:**
- `face_images`: Array of base64-encoded images (1-5 images, recommended 3)
- All other fields: same as before

**Response (if face verification passes):**
```json
{
  "message": "Registration successful. Complete your profile to unlock marketplace access.",
  "user": {
    "id": "507f1f77bcf86cd799439011",
    "email": "user@example.com",
    "role": "freelancer",
    "face_verified": true,
    "account_status": "pending_profile"
  },
  "profile": { ... },
  "access": "eyJ0eXAiOiJKV1QiLCJhbGc...",
  "refresh": "eyJ0eXAiOiJKV1QiLCJhbGc..."
}
```

**Response (if face verification fails):**
```json
{
  "face_image": "Face verification failed: Face matches existing user (similarity: 0.89)"
}
```

#### Decision Logic

| Similarity Score | Decision | Action |
|---|---|---|
| ≥ 0.85 | **REJECT** | Signup blocked - likely duplicate account |
| 0.75 - 0.85 | **SUSPICIOUS** | Signup allowed but flagged for manual review |
| < 0.75 | **ALLOW** | Signup proceeds normally |

#### Failure Handling

If Face Verification Service is unavailable:
- **Default behavior**: Allow signup (fail-open)
- **Logged**: All attempts logged to `face_verification_logs`
- **Recommended**: Monitor service availability and alert on downtime

### 2.4 Configuration in Django

#### Optional: Customize Thresholds

```python
# settings.py
FACE_VERIFICATION_REJECT_THRESHOLD = 0.85
FACE_VERIFICATION_SUSPICIOUS_THRESHOLD = 0.75
```

#### Optional: Require Service Availability

```python
# In accounts/serializers.py - modify can_register_with_faces()
# Change from fail-open to fail-closed:

if not client.is_service_available():
    raise serializers.ValidationError("Face verification service unavailable")
```

---

## PART 3: API Usage Guide

### Verification Service API

#### 3.1 POST /api/verify-face

Verify face images and check for duplicates.

**Request:**
```bash
curl -X POST http://localhost:8001/api/verify-face \
  -H "Content-Type: application/json" \
  -d '{
    "images": ["data:image/jpeg;base64,..."],
    "user_id": "new_user_12345",
    "user_meta": {
      "ip": "192.168.1.1",
      "device": "iPhone 12",
      "timestamp": "2024-01-15T10:30:00Z"
    }
  }'
```

**Response (200 OK):**
```json
{
  "decision": "allow",
  "similarity_score": 0.65,
  "top_matches": [
    {
      "user_id": "existing_user_789",
      "similarity": 0.65
    }
  ],
  "confidence": 0.35,
  "processing_time_ms": 1245.5
}
```

**Response (400 Bad Request):**
```json
{
  "detail": "Image processing error: Multiple faces detected (2). Please provide one face per image"
}
```

#### 3.2 GET /health

Health check endpoint.

**Response:**
```json
{
  "status": "healthy",
  "model_loaded": true,
  "index_ready": true,
  "message": "Service running. Embeddings in index: 42"
}
```

---

## PART 4: Development Workflow

### Running Both Services

#### Terminal 1: FastAPI Service

```bash
cd face-verification-service
source venv/bin/activate  # or venv\Scripts\activate on Windows
python -m uvicorn app.main:app --reload --port 8001
```

#### Terminal 2: Django Backend

```bash
cd freelancerbackend
source venv/bin/activate  # or .venv\Scripts\activate on Windows
python manage.py runserver
```

#### Terminal 3: Test Signup

```bash
curl -X POST http://localhost:8000/auth/register/ \
  -H "Content-Type: application/json" \
  -d '{
    "email": "test@example.com",
    "password": "TestPass123",
    "role": "freelancer",
    "face_images": ["data:image/jpeg;base64,...")
  }'
```

### Debugging

#### Enable Debug Logging

In `.env`:
```env
LOG_LEVEL=DEBUG
```

#### Check Verification Logs

```bash
# MongoDB shell
mongosh

# Query logs
db.face_verification_logs.find().sort({created_at: -1}).limit(5)
```

---

## PART 5: Production Deployment

### 5.1 Docker Deployment

#### FastAPI Service Dockerfile

```dockerfile
FROM python:3.11-slim

WORKDIR /app

# Install system dependencies
RUN apt-get update && apt-get install -y \
    libsm6 libxext6 libxrender-dev \
    && rm -rf /var/lib/apt/lists/*

# Copy files
COPY requirements.txt .
RUN pip install --no-cache-dir -r requirements.txt

COPY app/ app/
COPY .env .

# Expose port
EXPOSE 8001

# Run
CMD ["python", "-m", "uvicorn", "app.main:app", "--host", "0.0.0.0", "--port", "8001"]
```

#### Build & Run

```bash
# Build
docker build -t face-verification-service .

# Run
docker run -p 8001:8001 \
  -e SERVICE_PORT=8001 \
  -e ENVIRONMENT=production \
  -v $(pwd)/data:/app/data \
  face-verification-service
```

#### Docker Compose

```yaml
version: "3.8"

services:
  face-verification:
    build: ./face-verification-service
    ports:
      - "8001:8001"
    environment:
      SERVICE_PORT: 8001
      ENVIRONMENT: production
      LOG_LEVEL: INFO
    volumes:
      - ./face-verification-service/data:/app/data
    restart: unless-stopped

  django-backend:
    build: ./freelancerbackend
    ports:
      - "8000:8000"
    environment:
      FACE_VERIFICATION_SERVICE_URL: http://face-verification:8001
      DATABASE_URL: mongodb://mongo:27017/freelancer
    depends_on:
      - mongo
      - face-verification
    restart: unless-stopped

  mongo:
    image: mongo:6
    ports:
      - "27017:27017"
    volumes:
      - mongo_data:/data/db
    restart: unless-stopped

volumes:
  mongo_data:
```

### 5.2 Environment-Specific Configuration

#### Development
```env
ENVIRONMENT=development
LOG_LEVEL=DEBUG
REJECT_THRESHOLD=0.85
SUSPICIOUS_THRESHOLD=0.75
```

#### Staging
```env
ENVIRONMENT=staging
LOG_LEVEL=INFO
REJECT_THRESHOLD=0.87
SUSPICIOUS_THRESHOLD=0.77
```

#### Production
```env
ENVIRONMENT=production
LOG_LEVEL=WARNING
REJECT_THRESHOLD=0.90
SUSPICIOUS_THRESHOLD=0.80
```

### 5.3 Monitoring

#### Health Check

```bash
# Setup continuous monitoring
while true; do
  status=$(curl -s http://localhost:8001/health | jq .status)
  echo "$(date) - Status: $status"
  sleep 60
done
```

#### Metrics to Monitor

- Response time: `processing_time_ms` in responses
- Index size: Number of embeddings in FAISS index
- Duplicate detection rate: % of rejections
- Service availability: /health endpoint uptime

---

## PART 6: Troubleshooting

### Issue: "No face detected in image"

**Cause**: Image doesn't contain a clear face or face is too small

**Solutions**:
- Ensure good lighting
- Face should be at least 50x50 pixels
- Image should be front-facing
- Remove sunglasses/hats

### Issue: Service timeout (504)

**Cause**: Model loading or inference is slow

**Solutions**:
- First request always slower (model warmup)
- Increase timeout in Django client
- Use GPU if available
- Scale to multiple workers

### Issue: "Service unavailable"

**Cause**: FastAPI service not running

**Solutions**:
```bash
# Check if service is running
curl http://localhost:8001/health

# If not running, start it:
python -m uvicorn app.main:app --host 0.0.0.0 --port 8001

# Check logs for errors
tail -f logs/face_verification.log
```

### Issue: FAISS index not saving

**Cause**: Permission issue or disk full

**Solutions**:
```bash
# Check permissions
ls -la data/

# Fix permissions
chmod -R 755 data/

# Check disk space
df -h
```

---

## PART 7: Security Considerations

### 1. API Security

- Use HTTPS in production
- Add API key authentication between services
- Implement rate limiting on /verify-face endpoint
- Validate all base64 images before processing

### 2. Data Privacy

- Don't store raw image data
- Store only embeddings (irreversible)
- Delete images after processing
- Implement data retention policies

### 3. Model Security

- Use official InsightFace models only
- Validate model checksums before loading
- Run in isolated container
- Update models regularly for security patches

### 4. Access Control

- Restrict service to private network in production
- Use VPC/firewall rules
- Monitor access logs
- Implement audit trail (FaceVerificationLog)

---

## References

- [InsightFace Documentation](https://github.com/deepinsight/insightface)
- [FAISS Documentation](https://faiss.ai/)
- [FastAPI Documentation](https://fastapi.tiangolo.com/)
- [ArcFace Paper](https://arxiv.org/abs/1801.07698)
