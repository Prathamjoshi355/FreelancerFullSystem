# Face Verification Quick Start

## 30-Minute Setup

### Step 1: Start FastAPI Service (5 min)

```bash
cd face-verification-service

# Create and activate venv
python -m venv venv
source venv/bin/activate  # or venv\Scripts\activate on Windows

# Install dependencies
pip install -r requirements.txt

# Create data directory
mkdir -p data/models

# Run service
python -m uvicorn app.main:app --reload --port 8001
```

**Verify it's running:**
```bash
curl http://localhost:8001/health
```

Expected:
```json
{
  "status": "healthy",
  "model_loaded": true,
  "index_ready": true,
  "message": "Service running. Embeddings in index: 0"
}
```

### Step 2: Configure Django (5 min)

In `freelancerbackend/settings.py`:

```python
FACE_VERIFICATION_SERVICE_URL = os.getenv(
    "FACE_VERIFICATION_SERVICE_URL",
    "http://localhost:8001"
)
```

In `freelancerbackend/.env`:
```env
FACE_VERIFICATION_SERVICE_URL=http://localhost:8001
```

### Step 3: Start Django (5 min)

```bash
cd freelancerbackend
python manage.py runserver
```

### Step 4: Test Registration (15 min)

#### Get a test face image:

```python
# Quick Python script to capture and encode face
import base64
from PIL import Image
import io

# Use any JPEG image of a face
image_path = "path/to/face.jpg"

with open(image_path, "rb") as img_file:
    base64_string = base64.b64encode(img_file.read()).decode()
    data_uri = f"data:image/jpeg;base64,{base64_string}"
    print(data_uri[:50] + "...")  # Print first 50 chars
```

#### Test registration:

```bash
curl -X POST http://localhost:8000/auth/register/ \
  -H "Content-Type: application/json" \
  -d '{
    "email": "test@example.com",
    "password": "TestPassword123",
    "role": "freelancer",
    "face_images": [
      "data:image/jpeg;base64,/9j/4AAQSkZJRgABA...",
      "data:image/jpeg;base64,/9j/4AAQSkZJRgABA...",
      "data:image/jpeg;base64,/9j/4AAQSkZJRgABA..."
    ]
  }'
```

**Success Response (201):**
```json
{
  "message": "Registration successful",
  "user": {
    "email": "test@example.com",
    "face_verified": true
  },
  "access": "eyJ0eXAiOiJKV1QiLCJhbGc..."
}
```

**Error Response (400):**
```json
{
  "face_image": "Face verification failed: ..."
}
```

---

## Next Steps

1. **Run the Complete Checklist**
   - See `FACE_VERIFICATION_CHECKLIST.md`

2. **Set Up Monitoring**
   - Monitor logs in both services
   - Check `face_verification_logs` MongoDB collection

3. **Scale for Production**
   - Use Docker: `docker-compose up`
   - Increase workers: `--workers 4`
   - Add load balancer

---

## Common Issues

### "No module named 'insightface'"

```bash
pip install --upgrade insightface onnxruntime
```

### "Port 8001 already in use"

```bash
# Linux/Mac: Find and kill process
lsof -i :8001
kill -9 <PID>

# Windows: Find and kill process
netstat -ano | findstr :8001
taskkill /PID <PID> /F
```

### "Service unavailable" during registration

- Ensure FastAPI service is running
- Check logs: `tail -f logs/face_verification.log`
- Restart service if needed

### Registration succeeds but face_verified is False

- Check verification logs: `db.face_verification_logs.find()`
- Check similarity scores
- Adjust thresholds in `.env` if needed

---

## Testing with Postman

1. **Download & Import Collection**
   - Available at: `/docs/postman_collection.json`

2. **Set Environment Variables**
   ```json
   {
     "base_url": "http://localhost:8001",
     "django_url": "http://localhost:8000"
   }
   ```

3. **Run Requests**
   - Health Check: `GET /health`
   - Verify Face: `POST /api/verify-face`
   - Register User: `POST /auth/register/`

---

## Quick Commands Reference

```bash
# Check service health
curl http://localhost:8001/health

# View API docs
open http://localhost:8001/docs

# Check logs (FastAPI)
tail -f logs/face_verification.log

# Query verification logs (MongoDB)
mongosh
db.face_verification_logs.find().limit(5)

# Reset index (clear all embeddings)
rm -rf data/face_embeddings.faiss data/metadata.json

# Stress test
ab -n 100 -c 10 http://localhost:8001/health
```

---

**Total Setup Time**: ~30 minutes (first run may take longer due to model download)

**Next**: See [FACE_VERIFICATION_SETUP.md](FACE_VERIFICATION_SETUP.md) for detailed documentation
