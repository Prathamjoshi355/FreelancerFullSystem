# API Endpoints Quick Reference

## Base URL
`http://localhost:8000/api/`

## Authentication

### Get Token
```
POST /token/
Body: { "email": "user@example.com", "password": "password" }
Response: { "access": "token", "refresh": "token", "user": {...} }
```

### Refresh Token
```
POST /token/refresh/
Body: { "refresh": "refresh_token" }
Response: { "access": "new_token" }
```

---

## 🔐 Accounts

| Method | Endpoint | Purpose | Auth Required |
|--------|----------|---------|---------------|
| POST | `/accounts/register/` | Register new user | ❌ |
| GET | `/accounts/user/` | Get current user | ✅ |
| PUT | `/accounts/user/` | Update current user | ✅ |

---

## 👤 Profiles

| Method | Endpoint | Purpose | Auth Required |
|--------|----------|---------|---------------|
| GET | `/profiles/` | List all profiles | ❌ |
| GET | `/profiles/{id}/` | Get specific profile | ❌ |
| GET | `/profiles/my_profile/` | Get own profile | ✅ |
| POST | `/profiles/update_profile/` | Update own profile | ✅ |
| GET | `/profiles/freelancers/?skill=skill_name` | Search freelancers | ❌ |

---

## 💼 Jobs

| Method | Endpoint | Purpose | Auth Required | Role |
|--------|----------|---------|---------------|------|
| GET | `/jobs/` | List open jobs | ❌ | - |
| POST | `/jobs/` | Create new job | ✅ | Client |
| GET | `/jobs/{id}/` | Get job details | ❌ | - |
| PUT | `/jobs/{id}/` | Update job | ✅ | Client |
| DELETE | `/jobs/{id}/` | Delete job | ✅ | Client |
| GET | `/jobs/{id}/applications/` | View applications | ✅ | Client |
| GET | `/jobs/my-jobs/` | Get own jobs | ✅ | Client |
| POST | `/jobs/apply/` | Apply to job | ✅ | Freelancer |
| GET | `/jobs/my-applications/` | Get own applications | ✅ | Freelancer |

### Query Parameters for Listing:
- `category=Web%20Development`
- `experience_level=intermediate`
- `min_budget=1000`
- `max_budget=5000`

---

## 📋 Proposals

| Method | Endpoint | Purpose | Auth Required | Role |
|--------|----------|---------|---------------|------|
| GET | `/proposals/` | List proposals | ✅ | Any |
| POST | `/proposals/` | Submit proposal | ✅ | Freelancer |
| GET | `/proposals/{id}/` | Get proposal details | ✅ | Any |
| POST | `/proposals/{id}/accept/` | Accept proposal | ✅ | Client |
| POST | `/proposals/{id}/reject/` | Reject proposal | ✅ | Client |
| POST | `/proposals/{id}/withdraw/` | Withdraw proposal | ✅ | Freelancer |

### Proposal Body:
```json
{
  "job_id": "id_here",
  "cover_letter": "Why I'm perfect for this...",
  "proposed_amount": 2500,
  "proposed_timeline": "2 weeks"
}
```

---

## 💰 Payments

| Method | Endpoint | Purpose | Auth Required | Role |
|--------|----------|---------|---------------|------|
| GET | `/payments/transactions/` | List transactions | ✅ | Any |
| GET | `/payments/transactions/{id}/` | Get transaction details | ✅ | Any |
| POST | `/payments/transactions/create_payment/` | Create payment | ✅ | Client |
| POST | `/payments/transactions/{id}/confirm_payment/` | Confirm payment | ✅ | Client |
| POST | `/payments/transactions/{id}/release_payment/` | Release payment | ✅ | Client/Admin |
| GET | `/payments/payouts/` | List payouts | ✅ | Freelancer |
| POST | `/payments/payouts/request_payout/` | Request payout | ✅ | Freelancer |

### Payment Creation:
```json
{
  "proposal_id": "id_here",
  "payment_method": "stripe"
}
```

### Payout Request:
```json
{
  "amount": 2000,
  "payout_method": "bank_transfer",
  "bank_account": "12345678",
  "bank_name": "Bank Name",
  "routing_number": "123456789"
}
```

---

## 💬 Chat

| Method | Endpoint | Purpose | Auth Required |
|--------|----------|---------|---------------|
| GET | `/chat/conversations/` | List conversations | ✅ |
| POST | `/chat/conversations/` | Create/get conversation | ✅ |
| GET | `/chat/conversations/{id}/` | Get conversation details | ✅ |
| GET | `/chat/conversations/{id}/messages/` | Get all messages | ✅ |
| POST | `/chat/messages/` | Send message | ✅ |
| POST | `/chat/messages/mark_as_read/` | Mark messages as read | ✅ |
| GET | `/chat/messages/unread_count/` | Get unread count | ✅ |

### Create Conversation:
```json
{
  "participant_email": "other_user@example.com",
  "subject": "Discussion about Web Development Job"
}
```

### Send Message:
```json
{
  "conversation_id": "id_here",
  "content": "Message content here",
  "attachment_url": "https://url.com/file.pdf"  // Optional
}
```

### Mark as Read:
```json
{
  "conversation_id": "id_here"
}
```

---

## 🔔 Notifications

| Method | Endpoint | Purpose | Auth Required |
|--------|----------|---------|---------------|
| GET | `/notifications/notifications/` | List notifications | ✅ |
| GET | `/notifications/notifications/{id}/` | Get notification | ✅ |
| POST | `/notifications/notifications/{id}/mark_as_read/` | Mark as read | ✅ |
| POST | `/notifications/notifications/mark_all_as_read/` | Mark all as read | ✅ |
| GET | `/notifications/notifications/unread_count/` | Get unread count | ✅ |
| GET | `/notifications/preferences/my_preferences/` | Get preferences | ✅ |
| POST | `/notifications/preferences/update_preferences/` | Update preferences | ✅ |

### Query Parameters:
- `/notifications/?unread_only=true` - Get only unread

### Update Preferences:
```json
{
  "email_on_proposal": true,
  "email_on_message": true,
  "email_on_payment": true,
  "email_on_review": true,
  "push_notifications_enabled": true,
  "sms_notifications_enabled": false
}
```

---

## 📊 Response Status Codes

| Code | Meaning | Example |
|------|---------|---------|
| 200 | SUCCESS | GET request successful |
| 201 | CREATED | Resource created successfully |
| 400 | BAD REQUEST | Invalid data provided |
| 401 | UNAUTHORIZED | Missing or invalid token |
| 403 | FORBIDDEN | User doesn't have permission |
| 404 | NOT FOUND | Resource doesn't exist |
| 500 | SERVER ERROR | Backend error |

---

## 🧪 Example Workflow

### 1. Register
```bash
curl -X POST http://localhost:8000/api/accounts/register/ \
  -H "Content-Type: application/json" \
  -d '{
    "email": "client@example.com",
    "password": "secure123",
    "full_name": "John Client",
    "role": "client",
    "company_name": "My Company"
  }'
```

### 2. Login
```bash
curl -X POST http://localhost:8000/api/token/ \
  -H "Content-Type: application/json" \
  -d '{
    "email": "client@example.com",
    "password": "secure123"
  }'
```

### 3. Post Job
```bash
curl -X POST http://localhost:8000/api/jobs/ \
  -H "Authorization: Bearer ACCESS_TOKEN" \
  -H "Content-Type: application/json" \
  -d '{
    "title": "Build React Dashboard",
    "description": "Need a professional dashboard",
    "category": "Web Development",
    "budget_type": "fixed",
    "budget_min": 1500,
    "budget_max": 5000,
    "required_skills": ["React", "JavaScript"],
    "experience_level": "intermediate",
    "duration": "medium",
    "deadline": "2026-04-20T23:59:59Z"
  }'
```

### 4. Submit Proposal
```bash
curl -X POST http://localhost:8000/api/proposals/ \
  -H "Authorization: Bearer FREELANCER_TOKEN" \
  -H "Content-Type: application/json" \
  -d '{
    "job_id": "JOB_ID_HERE",
    "cover_letter": "I have 8 years of React experience...",
    "proposed_amount": 3000,
    "proposed_timeline": "2 weeks"
  }'
```

### 5. Accept Proposal
```bash
curl -X POST http://localhost:8000/api/proposals/PROPOSAL_ID/accept/ \
  -H "Authorization: Bearer CLIENT_TOKEN"
```

---

## 🔗 Useful Links

- API Documentation: See `API_DOCUMENTATION.md`
- Quick Start: See `QUICK_START.md`
- Project Summary: See `PROJECT_SUMMARY.md`

---

## 💡 Tips

1. **Always include Authorization header** with Bearer token for protected endpoints
2. **Save the access token** from login response
3. **Use refresh token** to get new access token when expired
4. **Check response status** before processing data
5. **Handle errors gracefully** with meaningful messages

---

**Last Updated**: March 13, 2026  
**API Version**: 1.0.0
