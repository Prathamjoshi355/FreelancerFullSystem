# Face Verification System - Condition Update Implementation Guide

## Quick Summary

The Face Verification System has been updated to safely handle 20+ edge cases and failure conditions. All responses now follow a structured format with proper error codes, messages, and fallback logic.

**Key Changes:**
- ✅ No more crashes - all errors handled gracefully
- ✅ Rich error diagnostics - detailed messages and metrics
- ✅ Automatic retries - exponential backoff for transient failures
- ✅ Timeout handling - prevents hanging requests
- ✅ Safe fallbacks - service errors don't break registration
- ✅ Concurrency protection - prevents duplicate processing

---

## API Response Format

### Unified Response Structure
All face verification endpoints now return this standardized response:

```json
{
  "decision": "allow | reject | suspicious | retry | error",
  "error_code": "string or null",
  "message": "human readable message",
  "retry_allowed": true or false,
  "similarity_score": 0.85 or null,
  "confidence": 0.95 or null,
  "top_matches": [
    {
      "user_id": "user_123",
      "similarity": 0.92
    }
  ],
  "processing_time_ms": 245.5
}
```

### Decision Types

| Decision | HTTP Status | Meaning | User Action |
|----------|------------|---------|------------|
| `allow` | 200 | Face verified, no duplicates | Proceed with registration |
| `reject` | 403 | Duplicate face detected | Show error, cannot proceed |
| `suspicious` | 202 | Borderline match, needs review | Show warning, can proceed |
| `retry` | 400 | Image quality issue | Ask user to retake photo |
| `error` | 503 | Service error | Show message, can proceed with review |

---

## New Signup Face Verification Endpoint

### Endpoint
```
POST /api/accounts/face-verify-signup/
```

### Request
```json
{
  "email": "user@example.com",
  "images": [
    "data:image/jpeg;base64,/9j/4AAQSkZJRg...",
    "data:image/jpeg;base64,iVBORw0KGgoAAAAN..."
  ]
}
```

### Success Response (allow)
```json
{
  "decision": "allow",
  "message": "Face verification passed. You can complete your registration.",
  "error_code": null,
  "retry_allowed": false,
  "can_proceed": true,
  "similarity_score": 0.35,
  "confidence": 0.95
}
```

### Duplicate Face Response (reject)
```json
{
  "decision": "reject",
  "message": "Face matches an existing account (similarity: 0.92).",
  "error_code": "duplicate_face",
  "retry_allowed": false,
  "can_proceed": false,
  "similarity_score": 0.92,
  "confidence": 0.98
}
```

### Suspicious Response (needs manual review)
```json
{
  "decision": "suspicious",
  "message": "Face match is borderline (similarity: 0.78). Account flagged for review.",
  "error_code": "needs_review",
  "retry_allowed": false,
  "can_proceed": true,
  "review_required": true,
  "similarity_score": 0.78,
  "confidence": 0.85
}
```

### Retry Response (poor image quality)
```json
{
  "decision": "retry",
  "message": "Your face moved too quickly. Please hold still and try again.",
  "error_code": "motion_blur_detected",
  "retry_allowed": true,
  "can_proceed": false,
  "similarity_score": null,
  "confidence": null
}
```

### Error Response (service issue)
```json
{
  "decision": "error",
  "message": "Face verification service timed out. Your account will be reviewed.",
  "error_code": "service_timeout",
  "retry_allowed": false,
  "can_proceed": true,
  "review_required": true,
  "similarity_score": null,
  "confidence": null
}
```

---

## Error Codes Reference

### Image Quality Errors
- `invalid_image` - Image corrupted or invalid format
- `image_quality_poor` - Image too dark, bright, or has low contrast
- `no_face_detected` - No face visible in image
- `multiple_faces_detected` - More than one face in image
- `face_partially_visible` - Face at edge or partially outside frame
- `face_angle_problem` - Face at extreme angle, not facing camera
- `face_extraction_failed` - Failed to extract face region
- `face_quality_poor` - Extracted face doesn't meet quality standards
- `motion_blur_detected` - Motion blur detected (user moved)

### Processing Errors
- `embedding_failure` - Failed to generate face embedding
- `embedding_error` - Exception during embedding generation
- `model_not_loaded` - AI model not available

### Service Errors
- `service_unavailable` - Service not running or not initialized
- `service_timeout` - Request took too long
- `service_http_error` - Service returned error status
- `network_error` - Network connectivity problem
- `unexpected_error` - Unexpected internal error
- `verification_error` - Verification process failed

### Request Errors
- `missing_images` - No images provided
- `too_many_images` - More than 5 images provided
- `email_required` - Email not provided
- `email_exists` - Email already registered

### Registration Errors
- `duplicate_face` - Face matches existing account
- `needs_review` - Account flagged for manual review
- `poor_image_quality` - Image too poor, retry capture

---

## Frontend Integration Examples

### React/TypeScript Example

```typescript
interface FaceVerificationResult {
  decision: 'allow' | 'reject' | 'suspicious' | 'retry' | 'error';
  error_code: string | null;
  message: string;
  retry_allowed: boolean;
  can_proceed?: boolean;
  review_required?: boolean;
  similarity_score?: number;
  confidence?: number;
}

async function verifyFaceForSignup(
  email: string,
  images: string[]
): Promise<FaceVerificationResult> {
  const response = await fetch('/api/accounts/face-verify-signup/', {
    method: 'POST',
    headers: { 'Content-Type': 'application/json' },
    body: JSON.stringify({ email, images }),
  });

  return response.json();
}

// Usage in signup flow
function SignupWithFaceVerification() {
  const [decision, setDecision] = useState<FaceVerificationResult | null>(null);

  async function handleFaceCapture(images: string[], email: string) {
    const result = await verifyFaceForSignup(email, images);
    setDecision(result);

    if (result.decision === 'allow') {
      // User can proceed with registration
      completeRegistration(email);
    } else if (result.decision === 'reject') {
      // Show error, prevent registration
      showError('Your face matches an existing account.');
    } else if (result.decision === 'suspicious') {
      // Show warning, allow to proceed but flag it
      showWarning('Your account will be reviewed.');
      completeRegistration(email, { review_required: true });
    } else if (result.decision === 'retry') {
      // Ask user to retake photo
      showMessage(result.message);
      // Enable retry button
    } else if (result.decision === 'error') {
      // Service error, allow to proceed with review
      showWarning('Service error. Your account will be reviewed.');
      completeRegistration(email, { review_required: true });
    }
  }

  return (
    <div>
      <CameraCapture onCapture={(images) => handleFaceCapture(images, email)} />
      {decision && (
        <div>
          <p>{decision.message}</p>
          {decision.retry_allowed && <button>Retry</button>}
          {decision.can_proceed && <button>Continue</button>}
        </div>
      )}
    </div>
  );
}
```

### Error Handling Best Practices

```typescript
function getRetryMessage(errorCode: string): string {
  const retryMessages: Record<string, string> = {
    'motion_blur_detected': 'Please hold your face steady',
    'no_face_detected': 'Move closer to the camera',
    'face_partially_visible': 'Make sure your entire face is visible',
    'image_quality_poor': 'Improve the lighting and try again',
    'face_angle_problem': 'Face the camera directly',
    'multiple_faces_detected': 'Make sure only your face is visible',
  };
  return retryMessages[errorCode] || 'Please try again';
}

function getUserMessage(result: FaceVerificationResult): string {
  switch (result.decision) {
    case 'allow':
      return 'Great! Your face has been verified.';
    case 'reject':
      return 'This face is already registered.';
    case 'suspicious':
      return 'Your account will be reviewed by our team.';
    case 'retry':
      return getRetryMessage(result.error_code || '');
    case 'error':
      return 'Service temporarily unavailable. Please try again later.';
  }
}
```

---

## Condition Handling Summary

### Quality Issues (All Retry)
When image quality is poor, the system returns `retry` with user-friendly instructions:

- **No face detected**: "Hold the camera steady and ensure your face is clearly visible"
- **Multiple faces**: "Only you should be visible in the image"
- **Face too small/partial**: "Move closer to the camera"
- **Blurry/motion**: "Hold still and avoid moving"
- **Wrong angle**: "Face the camera directly"
- **Too dark**: "Increase lighting"
- **Too bright**: "Reduce glare or shadows"

### Verification Results
Three main outcomes:

1. **ALLOW** (decision='allow')
   - No duplicates found
   - Face similarity < 0.75
   - Proceed with registration

2. **REJECT** (decision='reject')
   - Duplicate detected (similarity > 0.85)
   - Block registration
   - Show similarity score to user

3. **SUSPICIOUS** (decision='suspicious')
   - Borderline match (0.75-0.85 similarity)
   - Flag for manual review
   - Can still register but marked for verification

### Service Issues (All Error with Safe Fallback)
When service fails:
- Return `error` decision
- Set `can_proceed: true` (allow registration with review)
- Set `review_required: true` (flag for manual review)
- Never break the signup flow

Service failures include:
- Service timeout
- Network error
- Model not loaded
- FAISS unavailable
- Request exception

---

## Response Status Codes

### 200 OK - Face Allowed
```
Decision: allow
User can complete registration
```

### 202 Accepted - Pending Review
```
Decision: suspicious
User can proceed but account flagged for review
```

### 400 Bad Request - Retry Needed
```
Decision: retry
User should capture another image
```

### 403 Forbidden - Duplicate Face
```
Decision: reject
User cannot proceed, duplicate detected
```

### 503 Service Unavailable - Service Error
```
Decision: error
User can proceed but account flagged for review
```

---

## Testing Scenarios

### Test Case 1: Happy Path
```
Input: Clear face image
Expected: { decision: 'allow' }
Status: 200
Action: Complete registration
```

### Test Case 2: Duplicate Detection
```
Input: Face of existing user
Expected: { decision: 'reject', similarity_score: 0.92 }
Status: 403
Action: Show error, block registration
```

### Test Case 3: Poor Image Quality
```
Input: Blurry image
Expected: { decision: 'retry', error_code: 'motion_blur_detected' }
Status: 400
Action: Ask user to retake
```

### Test Case 4: Service Unavailable
```
Input: Any image, service down
Expected: { decision: 'error', can_proceed: true, review_required: true }
Status: 503
Action: Allow to proceed, flag for review
```

### Test Case 5: Suspicious Match
```
Input: Similar but not duplicate face
Expected: { decision: 'suspicious', similarity_score: 0.78, review_required: true }
Status: 202
Action: Allow to proceed with warning
```

---

## Logging and Monitoring

### What Gets Logged
- **Every verification attempt** - User, email, decision
- **Error details** - Error code, message, stack trace
- **Metrics** - Processing time, similarity score, confidence
- **Metadata** - IP address, user agent, timestamp

### Error Codes to Monitor
- `service_timeout` - Service performance issue
- `service_unavailable` - Service not running
- `network_error` - Infrastructure issue
- `embedding_failure` - Model issue
- `concurrent_request` - Potential spam/attack

### Metrics to Track
- Average processing time
- Distribution of decisions (allow/reject/suspicious)
- Retry rate
- Service availability
- Error rate by type

---

## Deployment Checklist

- [ ] Update frontend to use new endpoint `/api/accounts/face-verify-signup/`
- [ ] Update frontend to handle new decision types (especially `suspicious` and `error`)
- [ ] Update UI copy for each decision type
- [ ] Add monitoring for error codes
- [ ] Configure manual review workflow for suspicious accounts
- [ ] Set up alerts for `service_timeout` and `service_unavailable`
- [ ] Load test concurrent face verifications
- [ ] Test all error scenarios in staging
- [ ] Update API documentation
- [ ] Train support team on new decisions
- [ ] Plan rollback strategy

---

## Backward Compatibility

**Important:** The old endpoints still work:
- `POST /api/accounts/register/` - Basic registration (without face)
- `POST /api/accounts/face-verify/` - Login face verification

New endpoint:
- `POST /api/accounts/face-verify-signup/` - Signup face verification (recommended)

Use the new endpoint for better error handling and condition coverage.

---

## Troubleshooting

### Issue: Service Keeps Timing Out
**Cause:** Face verification service is slow or overloaded
**Solution:** 
- Check service logs
- Monitor GPU/CPU usage
- Increase timeout if needed
- Scale service horizontally

### Issue: Legitimate Users Marked Suspicious
**Cause:** Similarity threshold too low
**Solution:**
- Review flagged accounts manually
- Adjust threshold (0.75-0.85 range)
- Retrain models if needed

### Issue: Duplicate Faces Not Detected
**Cause:** Similarity calculation issue or FAISS problem
**Solution:**
- Check FAISS index health
- Verify embeddings are being generated
- Review model accuracy
- Check for corrupted data

### Issue: All Users Get "Retry" Messages
**Cause:** Image quality checks too strict
**Solution:**
- Review validation thresholds
- Check lighting conditions during testing
- Adjust brightness/blur/contrast limits

---

## Performance Metrics

### Expected Processing Times
- Image validation: 50-100ms
- Face detection: 100-300ms
- Embedding generation: 150-400ms
- FAISS search: 50-200ms
- **Total per image: 350-1000ms**
- **Total for 2-3 images: 700-3000ms**

### Timeouts
- Per image processing: 60 seconds (should never hit)
- Service call: 90 seconds (handles slow service)
- Max concurrent requests per user: 1 (enforced)

### Throughput
- Single service instance: ~10-20 requests/second
- Scale horizontally for more throughput

---

## Support and Escalation

**For Face Verification Issues:**
1. Check error code in response
2. Review logs with user email
3. Check service health
4. Verify FAISS index
5. Contact engineering team

**For Suspicious Accounts:**
1. Review similarity score
2. Check top matches
3. Request user to recapture
4. Manual verification required

**For Service Errors:**
1. Check service logs
2. Verify service is running
3. Check network connectivity
4. Check FAISS index availability
5. Restart service if needed
