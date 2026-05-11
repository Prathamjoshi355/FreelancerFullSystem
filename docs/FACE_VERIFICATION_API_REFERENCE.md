# Face Verification API Reference

## Base URL

**Development**: `http://localhost:8001`  
**Production**: `https://face-verification.yourdomain.com`

---

## Authentication

Currently no authentication required (can be added with API keys in production).

---

## Endpoints

### 1. Health Check

Verify service is running and healthy.

**Endpoint**: `GET /health`

**Response** (200 OK):
```json
{
  "status": "healthy",
  "model_loaded": true,
  "index_ready": true,
  "message": "Service running. Embeddings in index: 42"
}
```

**Response** (503 Service Unavailable):
```json
{
  "detail": "Models not loaded"
}
```

---

### 2. Verify Face

Main verification endpoint - check for duplicate users and determine verification decision.

**Endpoint**: `POST /api/verify-face`

**Request Headers**:
```
Content-Type: application/json
```

**Request Body**:
```json
{
  "images": [
    "data:image/jpeg;base64,/9j/4AAQSkZJRgABA...",
    "data:image/jpeg;base64,/9j/4AAQSkZJRgABA...",
    "data:image/jpeg;base64,/9j/4AAQSkZJRgABA..."
  ],
  "user_id": "new_user_123",
  "user_meta": {
    "ip": "192.168.1.100",
    "device": "iPhone 12",
    "timestamp": "2024-01-15T10:30:00Z"
  }
}
```

**Request Fields**:

| Field | Type | Required | Description |
|---|---|---|---|
| images | array[string] | YES | Base64 encoded images (1-5 images, <4MB each) |
| user_id | string | YES | Unique user identifier |
| user_meta | object | NO | Additional metadata |
| user_meta.ip | string | NO | User IP address |
| user_meta.device | string | NO | Device identifier |
| user_meta.timestamp | string | NO | ISO 8601 timestamp |

**Image Format**:
- JPEG, PNG, WebP supported
- Base64 encoded with data URI prefix: `data:image/jpeg;base64,...`
- Maximum 4MB per image
- 1-5 images recommended (3 optimal)

**Response** (200 OK):
```json
{
  "decision": "allow",
  "similarity_score": 0.62,
  "top_matches": [
    {
      "user_id": "existing_user_456",
      "similarity": 0.62
    },
    {
      "user_id": "existing_user_789",
      "similarity": 0.55
    }
  ],
  "confidence": 0.38,
  "processing_time_ms": 1234.5
}
```

**Response** (200 OK - Duplicate Detected):
```json
{
  "decision": "reject",
  "similarity_score": 0.88,
  "top_matches": [
    {
      "user_id": "existing_user_111",
      "similarity": 0.88
    }
  ],
  "confidence": 0.88,
  "processing_time_ms": 1500.2
}
```

**Response** (200 OK - Suspicious):
```json
{
  "decision": "suspicious",
  "similarity_score": 0.78,
  "top_matches": [
    {
      "user_id": "existing_user_222",
      "similarity": 0.78
    }
  ],
  "confidence": 0.78,
  "processing_time_ms": 1456.8
}
```

**Response** (400 Bad Request):
```json
{
  "detail": "No images provided"
}
```

**Possible Error Messages**:
- "No images provided"
- "Maximum 5 images allowed"
- "Invalid image format or size"
- "No face detected in image"
- "Multiple faces detected (2). Please provide one face per image"
- "Face quality too low (too small or blurry)"
- "Failed to generate embeddings"

**Response** (500 Internal Server Error):
```json
{
  "detail": "Internal server error. Check logs."
}
```

---

## Response Fields Explained

### Decision

| Value | Meaning | Action |
|---|---|---|
| `"allow"` | Face is unique, user can proceed | Create user account |
| `"reject"` | Face matches existing user (likely duplicate) | Block signup |
| `"suspicious"` | Face similar but not duplicate (needs review) | Allow but flag for review |
| `"error"` | Verification failed | Handle based on policy |

### Similarity Score

Range: 0.0 - 1.0

- **0.0 - 0.50**: Clearly different faces
- **0.50 - 0.75**: Similar-looking people (possibly twins)
- **0.75 - 0.85**: Very similar (requires manual review)
- **0.85 - 1.00**: Nearly identical (likely same person)

**Thresholds**:
- Reject threshold: 0.85
- Suspicious threshold: 0.75

### Confidence

Confidence in the decision (0.0 - 1.0).

- High confidence: Close to 1.0
- Low confidence: Close to 0.0

For "allow" decision: Confidence = 1 - (highest_similarity_score)

### Top Matches

Array of top 5 most similar existing users in the database.

Each match contains:
- `user_id`: ID of existing user
- `similarity`: Similarity score (0.0 - 1.0)

### Processing Time

Time taken to process the request in milliseconds.

Typical ranges:
- First request: 3000-5000ms (model warmup)
- Subsequent: 1000-2000ms

---

## Request Examples

### Python

```python
import requests
import base64
from pathlib import Path

# Prepare images
images = []
for img_path in ["face1.jpg", "face2.jpg", "face3.jpg"]:
    with open(img_path, "rb") as f:
        b64 = base64.b64encode(f.read()).decode()
        images.append(f"data:image/jpeg;base64,{b64}")

# Make request
url = "http://localhost:8001/api/verify-face"
payload = {
    "images": images,
    "user_id": "user_12345",
    "user_meta": {
        "ip": "192.168.1.100",
        "device": "Desktop"
    }
}

response = requests.post(url, json=payload, timeout=30)
result = response.json()

print(f"Decision: {result['decision']}")
print(f"Similarity: {result['similarity_score']:.2f}")
```

### JavaScript

```javascript
// Prepare images
async function getBase64(file) {
  return new Promise((resolve) => {
    const reader = new FileReader();
    reader.readAsDataURL(file);
    reader.onload = () => resolve(reader.result);
  });
}

async function verifyFace(imageFiles) {
  const images = [];
  for (const file of imageFiles) {
    const b64 = await getBase64(file);
    images.push(b64);
  }

  const payload = {
    images: images,
    user_id: "user_12345",
    user_meta: {
      ip: "192.168.1.100",
      device: "Mobile"
    }
  };

  const response = await fetch("http://localhost:8001/api/verify-face", {
    method: "POST",
    headers: { "Content-Type": "application/json" },
    body: JSON.stringify(payload)
  });

  const result = await response.json();
  console.log(`Decision: ${result.decision}`);
  console.log(`Similarity: ${result.similarity_score.toFixed(2)}`);
  return result;
}

// Usage
verifyFace([file1, file2, file3]);
```

### cURL

```bash
# Single image
curl -X POST http://localhost:8001/api/verify-face \
  -H "Content-Type: application/json" \
  -d '{
    "images": ["data:image/jpeg;base64,/9j/4AAQSkZJ..."],
    "user_id": "user_12345",
    "user_meta": {
      "ip": "192.168.1.100"
    }
  }'

# Multiple images (with jq for pretty output)
curl -X POST http://localhost:8001/api/verify-face \
  -H "Content-Type: application/json" \
  -d @payload.json | jq '.'
```

---

## Rate Limiting

Currently no rate limiting. Recommended to add in production:

- **Per IP**: 100 requests/minute
- **Per user_id**: 10 requests/minute
- **Burst**: 5 concurrent requests

---

## Timeout Guidelines

Set timeouts based on expected response times:

| Phase | Time | Total |
|---|---|---|
| Network latency | 100ms | 100ms |
| Image processing | 200ms | 300ms |
| Face detection | 800ms | 1100ms |
| Embedding | 600ms | 1700ms |
| Vector search | 300ms | 2000ms |

**Recommended client timeout**: 30 seconds (first request) / 10 seconds (subsequent)

---

## Error Handling

### Status Codes

| Code | Meaning | Action |
|---|---|---|
| 200 | Success | Process result based on decision |
| 400 | Bad request | Fix input and retry |
| 500 | Server error | Retry with exponential backoff |
| 503 | Service unavailable | Use fallback logic |

### Retry Policy

```python
import time

def verify_with_retry(images, user_id, max_retries=3):
    for attempt in range(max_retries):
        try:
            response = requests.post(
                "http://localhost:8001/api/verify-face",
                json={
                    "images": images,
                    "user_id": user_id
                },
                timeout=30
            )
            
            if response.status_code == 200:
                return response.json()
            elif response.status_code == 400:
                raise ValueError(response.json()["detail"])
            elif response.status_code in [500, 503]:
                if attempt < max_retries - 1:
                    wait_time = 2 ** attempt
                    print(f"Retry in {wait_time}s...")
                    time.sleep(wait_time)
                    continue
                raise
                
        except requests.Timeout:
            if attempt < max_retries - 1:
                continue
            raise
    
    raise Exception("All retries failed")
```

---

## Monitoring & Metrics

### Key Metrics to Track

```python
# From response
processing_time = result["processing_time_ms"]
similarity = result["similarity_score"]
decision = result["decision"]

# Track:
# - Distribution of processing times
# - Distribution of similarity scores
# - Decision distribution (allow/reject/suspicious)
# - Error rate
# - Availability
```

### Health Monitoring

```bash
#!/bin/bash
# Monitor health every 60s

while true; do
  status=$(curl -s http://localhost:8001/health | jq -r '.status')
  timestamp=$(date '+%Y-%m-%d %H:%M:%S')
  echo "[$timestamp] Status: $status"
  
  if [ "$status" != "healthy" ]; then
    # Alert
    echo "ALERT: Service unhealthy!"
  fi
  
  sleep 60
done
```

---

## Related APIs

### Django Registration

**Endpoint**: `POST /auth/register/`

Integrates with Face Verification Service automatically.

**Request**:
```json
{
  "email": "user@example.com",
  "password": "SecurePass123",
  "role": "freelancer",
  "face_images": ["data:image/jpeg;base64,..."]
}
```

**Response**: User object with `face_verified: true`

---

## Support

For issues or questions:

1. Check logs: `docker logs face-verification-service`
2. Review documentation: `FACE_VERIFICATION_SETUP.md`
3. Test health endpoint: `curl http://localhost:8001/health`
4. Check MongoDB logs: `db.face_verification_logs.find()`
