# Freelancer Platform Backend API Documentation

## Overview
This is a complete backend API for a freelancing platform built with Django, Django REST Framework, and MongoDB. It supports role-based access (Client and Freelancer) with features for job posting, proposals, payments, messaging, and notifications.

## Architecture

### Technology Stack
- **Framework**: Django 4.2.7
- **API**: Django REST Framework
- **Database**: MongoDB (with MongoEngine)
- **Authentication**: JWT (djangorestframework-simplejwt)
- **CORS**: django-cors-headers

### Database Models

#### 1. **Accounts App** - User Management
- `CustomUser` - Main user model with email authentication
  - Fields: email, password, full_name, company_name, role (freelancer/client), is_active, is_staff
  - Methods: set_password(), check_password()

#### 2. **Profiles App** - User Profiles
- `Profile` - User profile information
  - Fields: user_id (FK), bio, avatar, phone, address, city, country, skills[], rating, total_projects, hourly_rate
  - Used by freelancers to showcase their expertise

#### 3. **Jobs App** - Job Management
- `Job` - Job postings
  - Fields: client_id (FK), title, description, category, budget_type (fixed/hourly), budget_min, budget_max, required_skills[], status, deadline
  - Status: open, in_progress, completed, closed
  
- `JobApplication` - Applications to jobs
  - Fields: job_id (FK), freelancer_id (FK), status (pending/accepted/rejected)

#### 4. **Proposals App** - Proposals/Bids
- `Proposal` - Freelancer proposals for jobs
  - Fields: job_id (FK), freelancer_id (FK), cover_letter, proposed_amount, proposed_timeline, status
  - Status: pending, accepted, rejected, withdrew

#### 5. **Payments App** - Transactions & Payouts
- `Transaction` - Payment transactions
  - Fields: client_id (FK), freelancer_id (FK), proposal_id (FK), amount, fees, net_amount, status, is_released
  - Status: pending, completed, failed, refunded
  - Features: 10% platform fee, 7-day hold before release

- `Payout` - Freelancer payouts
  - Fields: freelancer_id (FK), amount, status, payout_method, bank details
  - Status: pending, processing, completed, failed

#### 6. **Messages App** - Messaging System
- `Conversation` - Conversations between users
  - Fields: participant_ids[], subject, created_at, updated_at
  
- `Message` - Messages in conversations
  - Fields: conversation_id (FK), sender_id (FK), content, is_read, attachment_url

#### 7. **Notifications App** - Notifications
- `Notification` - User notifications
  - Fields: user_id (FK), title, message, notification_type, related_id, is_read
  - Types: job_posted, proposal_received, proposal_accepted, payment_received, etc.

- `NotificationPreference` - User notification settings
  - Fields: user_id (FK), email_on_proposal, email_on_message, push_notifications_enabled

---

## API Endpoints

### Authentication
```
POST   /api/token/                          # Get JWT token
POST   /api/token/refresh/                  # Refresh token
POST   /api/accounts/register/              # Register new user
GET    /api/accounts/user/                  # Get current user details
```

### Jobs
```
GET    /api/jobs/                           # List all open jobs (with filters)
POST   /api/jobs/                           # Create new job (Client only)
GET    /api/jobs/{id}/                      # Get job details
PUT    /api/jobs/{id}/                      # Update job (Client only)
DELETE /api/jobs/{id}/                      # Delete job (Client only)
GET    /api/jobs/{id}/applications/         # Get applications for job
GET    /api/jobs/my-jobs/                   # Get user's posted jobs
POST   /api/jobs/apply/                     # Apply to a job (Freelancer only)
GET    /api/jobs/my-applications/           # Get user's applications
```

### Proposals
```
GET    /api/proposals/                      # List proposals
POST   /api/proposals/                      # Submit proposal
GET    /api/proposals/{id}/                 # Get proposal details
POST   /api/proposals/{id}/accept/          # Accept proposal (Client only)
POST   /api/proposals/{id}/reject/          # Reject proposal (Client only)
POST   /api/proposals/{id}/withdraw/        # Withdraw proposal (Freelancer only)
```

### Payments
```
GET    /api/payments/transactions/          # List transactions
GET    /api/payments/transactions/{id}/     # Get transaction details
POST   /api/payments/transactions/create_payment/  # Create payment
POST   /api/payments/transactions/{id}/confirm_payment/  # Confirm payment
POST   /api/payments/transactions/{id}/release_payment/  # Release payment
GET    /api/payments/payouts/               # List payouts
POST   /api/payments/payouts/request_payout/  # Request payout
```

### Messages
```
GET    /api/messages/conversations/         # List conversations
POST   /api/messages/conversations/         # Create/get conversation
GET    /api/messages/conversations/{id}/    # Get conversation
GET    /api/messages/conversations/{id}/messages/  # Get all messages
POST   /api/messages/messages/              # Send message
POST   /api/messages/messages/mark_as_read/ # Mark as read
GET    /api/messages/messages/unread_count/ # Get unread count
```

### Notifications
```
GET    /api/notifications/notifications/   # List notifications
GET    /api/notifications/notifications/{id}/ # Get notification
POST   /api/notifications/notifications/{id}/mark_as_read/  # Mark read
POST   /api/notifications/notifications/mark_all_as_read/   # Mark all read
GET    /api/notifications/notifications/unread_count/       # Unread count
GET    /api/notifications/preferences/my_preferences/  # Get preferences
POST   /api/notifications/preferences/update_preferences/  # Update preferences
```

### Profiles
```
GET    /api/profiles/                       # List all profiles
GET    /api/profiles/{id}/                  # Get specific profile
GET    /api/profiles/my_profile/            # Get current user's profile
POST   /api/profiles/update_profile/        # Update profile
GET    /api/profiles/freelancers?skill=     # Search freelancers by skill
```

---

## Request/Response Examples

### 1. User Registration
**Request:**
```json
POST /api/accounts/register/
{
  "email": "freelancer@example.com",
  "password": "securepassword",
  "full_name": "John Doe",
  "role": "freelancer"
}
```

**Response:**
```json
{
  "email": "freelancer@example.com",
  "full_name": "John Doe",
  "role": "freelancer"
}
```

### 2. Login (Get JWT Token)
**Request:**
```json
POST /api/token/
{
  "email": "freelancer@example.com",
  "password": "securepassword"
}
```

**Response:**
```json
{
  "access": "eyJ0eXAiOiJKV1QiLCJhbGc...",
  "refresh": "eyJ0eXAiOiJKV1QiLCJhbGc...",
  "user": {
    "email": "freelancer@example.com",
    "role": "freelancer"
  }
}
```

### 3. Post a Job
**Request:**
```json
POST /api/jobs/
Headers: Authorization: Bearer {access_token}

{
  "title": "Build a React App",
  "description": "Need a full-featured React application",
  "category": "Web Development",
  "budget_type": "fixed",
  "budget_min": 1000,
  "budget_max": 5000,
  "duration": "medium",
  "required_skills": ["React", "JavaScript", "CSS"],
  "experience_level": "intermediate",
  "deadline": "2026-04-13T23:59:59Z"
}
```

### 4. Submit a Proposal
**Request:**
```json
POST /api/proposals/
Headers: Authorization: Bearer {access_token}

{
  "job_id": "507f1f77bcf86cd799439011",
  "cover_letter": "I have 5 years of React experience...",
  "proposed_amount": 2500,
  "proposed_timeline": "2 weeks"
}
```

### 5. Create a Payment
**Request:**
```json
POST /api/payments/transactions/create_payment/
Headers: Authorization: Bearer {access_token}

{
  "proposal_id": "507f1f77bcf86cd799439012",
  "payment_method": "stripe"
}
```

**Response:**
```json
{
  "id": "507f1f77bcf86cd799439013",
  "amount": 2500,
  "fees": 250,
  "net_amount": 2250,
  "status": "pending",
  "release_date": "2026-04-20T10:30:00Z"
}
```

---

## Authentication

### JWT Token Flow
1. User registers or logs in
2. Backend returns `access` and `refresh` tokens
3. Include `access` token in `Authorization: Bearer {token}` header
4. When token expires, use `refresh` token to get new access token

### Role-Based Access
- **Clients**: Can post jobs, accept proposals, make payments
- **Freelancers**: Can browse jobs, submit proposals, view earnings
- **Admin**: Can manage all resources (reserved for future)

---

## Setup & Running

### Prerequisites
- Python 3.10+
- MongoDB running locally or remote connection
- pip/pipenv

### Installation
```bash
cd freelancerbackend

# Create virtual environment
python -m venv .venv
.\.venv\Scripts\activate

# Install dependencies
pip install -r requirements.txt

# Run development server
python manage.py runserver
```

### API will be available at:
```
http://localhost:8000/api/
```

---

## Features Implemented

- ✅ User Authentication (JWT)
- ✅ Role-Based Access (Client/Freelancer)
- ✅ Job Management (CRUD operations)
- ✅ Proposal System (Submit, Accept, Reject)
- ✅ Payment Processing (Create, Confirm, Release)
- ✅ Real-time Messaging
- ✅ Notification System
- ✅ User Profiles with Skills
- ✅ Freelancer Search/Discovery
- ✅ MongoDB Integration

---

## Future Enhancements

- [ ] WebSocket for real-time notifications
- [ ] Payment gateway integration (Stripe, PayPal)
- [ ] File upload for portfolios
- [ ] Review and rating system
- [ ] Admin dashboard
- [ ] Email notifications
- [ ] Two-factor authentication
- [ ] Dispute resolution system

---

## Error Handling

All endpoints return standard HTTP status codes:
- `200` - Success
- `201` - Created
- `400` - Bad Request
- `401` - Unauthorized
- `403` - Forbidden
- `404` - Not Found
- `500` - Server Error

Error responses include details:
```json
{
  "detail": "Error message here"
}
```

---

## Support & Contact

For issues or questions, please refer to the project repository.
