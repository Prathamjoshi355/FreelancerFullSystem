# Freelancer Platform - Backend Workflow Documentation

**Version**: 1.0  
**Framework**: Django REST Framework + MongoEngine  
**Database**: MongoDB  
**Auth**: JWT (SimpleJWT) with Email-based Login

---

## Table of Contents

1. [Architecture Overview](#architecture-overview)
2. [Authentication Flow](#authentication-flow)
3. [User Management](#user-management)
4. [Job Management Workflow](#job-management-workflow)
5. [Proposal/Bidding Workflow](#proposalbidding-workflow)
6. [Payment & Transaction Workflow](#payment--transaction-workflow)
7. [Chat & Messaging Workflow](#chat--messaging-workflow)
8. [Notification System](#notification-system)
9. [Data Models](#data-models)
10. [API Endpoints Reference](#api-endpoints-reference)

---

## Architecture Overview

### Tech Stack
- **Backend Framework**: Django 4.x + Django REST Framework
- **Database**: MongoDB with MongoEngine ODM
- **Authentication**: JWT (SimpleJWT) with custom MongoEngine adapter
- **Server**: WSGI (Django development server / Gunicorn)

### Project Structure
```
freelancerbackend/
├── FreelancerBackend/       # Main Django config
│   ├── settings.py          # Global settings
│   ├── urls.py              # Main URL routing
│   └── wsgi.py              # WSGI entrypoint
├── accounts/                # User auth & management
│   ├── models.py            # CustomUser model
│   ├── views.py             # Auth views (register, login)
│   ├── serializers.py       # User & token serializers
│   ├── auth.py              # Custom JWT authentication
│   └── urls.py              # Auth routes
├── jobs/                    # Job posting system
│   ├── models.py            # Job, JobApplication models
│   ├── views.py             # Job CRUD, filtering
│   ├── serializers.py       # Job serializers
│   └── urls.py              # Job routes
├── proposals/               # Bidding system
│   ├── models.py            # Proposal model
│   ├── views.py             # Proposal actions (create, accept, reject)
│   ├── serializers.py       # Proposal serializers
│   └── urls.py              # Proposal routes
├── payments/                # Transaction handling
│   ├── models.py            # Transaction, Payout models
│   ├── views.py             # Payment endpoints
│   ├── serializers.py       # Payment serializers
│   └── urls.py              # Payment routes
├── chat/                    # Messaging system
│   ├── models.py            # Conversation, Message models
│   ├── views.py             # Chat endpoints
│   ├── serializers.py       # Chat serializers
│   └── urls.py              # Chat routes
├── notifications/           # Notification system
│   ├── models.py            # Notification, NotificationPreference
│   ├── views.py             # Notification endpoints
│   └── urls.py              # Notification routes
├── profiles/                # User profiles & skills
│   ├── models.py            # Profile, SkillTest models
│   ├── views.py             # Profile endpoints
│   └── urls.py              # Profile routes
└── core/                    # Shared utilities
    ├── policies.py          # Business logic helpers
    └── env.py               # Environment config
```

---

## Authentication Flow

### 1. User Registration

```
POST /api/accounts/register/
├─ Request: { email, password, role, full_name/company_name, face_image (freelancer) }
├─ Validation (UserSerializer):
│  ├─ Check email uniqueness
│  ├─ Check role (freelancer or client)
│  ├─ For freelancer: requires full_name + face_image
│  ├─ For client: requires company_name
│  ├─ Face recognition: check for duplicate faces
│  └─ Hash password using bcrypt
├─ Backend Actions:
│  ├─ Create CustomUser in MongoDB
│  ├─ Generate JWT tokens (AccessToken + RefreshToken)
│  ├─ Create Profile record for freelancer
│  └─ Store face_embedding in CustomUser
└─ Response: 201 Created
   { user: { id, email, role }, access: "...", refresh: "..." }
```

### 2. User Login

**Two Endpoints (Both Work)**:

#### Option A: `/api/accounts/token/` (Recommended)
```
POST /api/accounts/token/
├─ Request: { email, password }
├─ MyTokenObtainPairSerializer:
│  ├─ Look up CustomUser by email
│  ├─ Verify password using bcrypt
│  ├─ Generate JWT with claims: user_id, role, restricted
│  └─ Return tokens + user data
└─ Response: 200 OK
   {
     access: "eyJ0eX...",
     refresh: "eyJ0eX...",
     user: { id, email, role, restricted }
   }
```

#### Option B: `/login/` (Alternative)
```
POST /login/
├─ Request: { email, password }
├─ Custom login_view:
│  ├─ Queries CustomUser by email
│  ├─ Uses user.check_password() for verification
│  └─ Generates RefreshToken
└─ Response: 200 OK
   {
     message: "Login successful",
     user: { ... },
     tokens: { access: "...", refresh: "..." }
   }
```

### 3. Token Verification

**For Protected Routes**:
```
Request Headers: { Authorization: "Bearer <access_token>" }
├─ MongoEngineJWTAuthentication.authenticate():
│  ├─ Extract token from header
│  ├─ Validate token signature (uses SIGNING_KEY)
│  ├─ Extract user_id claim
│  ├─ Query MongoDB for CustomUser
│  └─ Return user object + token
├─ Permission Classes check:
│  ├─ IsAuthenticated: user must exist
│  ├─ Specific role checks in views
│  └─ 403 Forbidden if unauthorized
└─ Proceed to view handler
```

### 4. Token Refresh

```
POST /api/accounts/token/refresh/
├─ Request: { refresh: "refresh_token" }
├─ TokenRefreshView:
│  ├─ Validate refresh token
│  ├─ Generate new access token
│  └─ Optional: rotate refresh token
└─ Response: 200 OK
   { access: "new_access_token" }
```

---

## User Management

### Data Model: CustomUser
```python
CustomUser (MongoDB Document)
├─ Email: unique, required
├─ Password: bcrypt hashed
├─ Role: 'freelancer' | 'client'
├─ Full Name: for freelancers
├─ Company Name: for clients
├─ Face Embedding: [float] - ML model embedding
├─ Violation Count: for suspensions
├─ Is Restricted: boolean - account suspension flag
├─ Is Active: boolean
├─ Timestamps: created_at, updated_at
└─ Django Compat: pk (returns str(id)), is_authenticated
```

### Get User Profile

```
GET /api/accounts/user/
GET /api/accounts/me/  (Alias)
├─ Required: Authentication
├─ Response: 200 OK
│  {
│    id: "507f...",
│    email: "user@example.com",
│    full_name: "Jane Doe",
│    company_name: null,
│    role: "freelancer",
│    is_restricted: false,
│    created_at: "2026-03-20T10:30:00Z"
│  }
└─ Errors:
   401: Not authenticated
   404: User not found
```

### Update User Profile

```
PUT /api/accounts/user/
├─ Required: Authentication
├─ Request: { full_name?, company_name?, face_image? }
├─ Allowed Fields: full_name, company_name
├─ Face Update Process:
│  ├─ Convert base64 to embedding
│  ├─ Check for duplicate faces
│  ├─ Reject if duplicate found
│  └─ Update face_embedding
└─ Response: 200 OK { email, full_name, company_name, role, message }
```

---

## Job Management Workflow

### 1. Create Job (Client Only)

```
POST /jobs/ 
├─ Required: Authentication + role == 'client'
├─ Request:
│  {
│    title: "Landing Page Redesign",
│    description: "...",
│    category: "Web Design",
│    budget_type: "fixed" | "hourly",
│    budget_min: 500,
│    budget_max: 2000,
│    hourly_rate: null,
│    duration: "short" | "medium" | "long",
│    required_skills: ["React", "TypeScript"],
│    experience_level: "intermediate",
│    deadline: "2026-04-20T00:00:00Z"
│  }
├─ Database Action:
│  ├─ Create Job with client_id = request.user
│  ├─ Set status = "open"
│  ├─ Set views_count = 0, proposals_count = 0
│  └─ Store created_at timestamp
└─ Response: 201 Created { id, client_id, ... full job data }
```

### 2. List Jobs (Public, Filterable)

```
GET /jobs/ ?category=...&experience_level=...&min_budget=...&max_budget=...
├─ Permission: AllowAny (public endpoint)
├─ Filters Applied:
│  ├─ status = "open" (only active jobs)
│  ├─ category (if provided)
│  ├─ experience_level (if provided)
│  ├─ budget_min >= min_budget (if provided)
│  └─ budget_max <= max_budget (if provided)
├─ Response: 200 OK
│  [
│    {
│      id: "...",
│      title: "...",
│      description: "...",
│      budget_min: 500,
│      proposals_count: 3,
│      client_info: { id, email, company_name },
│      ...
│    },
│    ...
│  ]
└─ Note: If user is freelancer, triggers ensure_freelancer_profile_complete()
```

### 3. Get Job Details

```
GET /jobs/{job_id}/
├─ Permission: AllowAny
├─ Side Effect: Increments job.views_count
├─ Response: 200 OK
│  {
│    id: "...",
│    title: "...",
│    client_info: { id, email, company_name },
│    budget_min: 500,
│    proposals_count: 5,
│    views_count: 23,
│    created_at: "2026-03-20T...",
│    ...full job details
│  }
└─ Errors:
   404: Job not found
```

### 4. Update Job (Client Only)

```
PUT /jobs/{job_id}/
├─ Required: Authentication + role == 'client' + client_id == request.user
├─ Allowed Fields: All fields except status validation
├─ Status Validation: Can set to 'draft', 'open', 'cancelled', 'completed'
├─ Cannot Set: 'hired' (handled by proposal accept)
└─ Response: 200 OK { updated job data }
   403: Not job owner
```

### 5. Delete Job

```
DELETE /jobs/{job_id}/
├─ Required: Authentication + role == 'client' + ownership
├─ Behavior: Hard delete (removes job and related data)
└─ Response: 204 No Content
```

### 6. View Job Applications

```
GET /jobs/{job_id}/applications/
├─ Required: Authentication + role == 'client' + job owner
├─ Response: 200 OK
│  [
│    {
│      id: "...",
│      job_id: "...",
│      freelancer_id: "...",
│      status: "pending" | "accepted" | "rejected",
│      applied_at: "..."
│    },
│    ...
│  ]
└─ Errors:
   403: Not job owner
```

### 7. Get My Jobs (Client)

```
GET /jobs/my-jobs/
GET /jobs/my_jobs/  (Alias - underscore version also works)
├─ Required: Authentication + role == 'client'
├─ Query: Filter(client_id=request.user)
└─ Response: 200 OK [list of client's jobs]
```

---

## Proposal/Bidding Workflow

### 1. Submit Proposal (Freelancer Only)

```
POST /proposals/
├─ Required: Authentication + role == 'freelancer'
├─ Checks:
│  ├─ ensure_freelancer_profile_complete() - must have profile
│  ├─ Job exists and status == 'open'
│  ├─ No duplicate proposal from same freelancer for same job
│  └─ User doesn't have face_embedding = [] (required for freelancers)
├─ Request:
│  {
│    job_id: "507f...",
│    cover_letter: "I am interested in...",
│    proposed_amount: 1200,
│    proposed_timeline: "2 weeks"
│  }
├─ Database Action:
│  ├─ Create Proposal with:
│  │  ├─ freelancer_id = request.user
│  │  ├─ status = 'pending'
│  │  ├─ Calculate initial_rating from profile
│  │  ├─ Calculate final_rating from past jobs
│  │  └─ completed = false
│  ├─ Increment job.proposals_count
│  └─ Timestamp created_at
└─ Response: 201 Created
   {
     id: "...",
     job_id: "...",
     freelancer_id: "...",
     cover_letter: "...",
     proposed_amount: 1200,
     status: "pending",
     initial_rating: 4.5,
     final_rating: 4.3,
     created_at: "..."
   }
```

### 2. List Proposals

```
GET /proposals/
├─ Required: Authentication
├─ Role-Based Filtering:
│  ├─ If client: Show proposals for their own jobs
│  │  Query: Proposal.filter(job_id__client_id=request.user)
│  └─ If freelancer: Show their own proposals
│     Query: Proposal.filter(freelancer_id=request.user) + ensure_profile_complete()
└─ Response: 200 OK [list of proposals with freelancer_info + job_info]
```

### 3. Get Proposal Details

```
GET /proposals/{proposal_id}/
├─ Required: Authentication
├─ Permission Check: Must be freelancer owner OR job client
├─ Response: 200 OK
│  {
│    id: "...",
│    job_id: "...",
│    freelancer_info: {
│      id: "...",
│      email: "...",
│      full_name: "...",
│      skills: ["React", "TypeScript"],
│      rating: 4.5,
│      initial_rating: 4.5,
│      final_rating: 4.3
│    },
│    job_info: {
│      id: "...",
│      title: "...",
│      category: "...",
│      status: "open",
│      budget_min: 500,
│      budget_max: 2000
│    },
│    cover_letter: "...",
│    proposed_amount: 1200,
│    proposed_timeline: "2 weeks",
│    status: "pending",
│    created_at: "..."
│  }
└─ Errors:
   403: Not authorized to view
   404: Proposal not found
```

### 4. Accept Proposal (Client Only)

```
POST /proposals/{proposal_id}/accept/
├─ Required: Authentication + role == 'client' + job owner
├─ Validation:
│  ├─ Proposal exists
│  ├─ Job status == 'open'
│  └─ Proposal not already accepted/rejected
├─ Database Actions:
│  ├─ Set proposal.status = 'hired'
│  ├─ Set all OTHER proposals for same job to 'auto_rejected'
│  ├─ Set job.status = 'hired'
│  └─ Trigger notification to freelancer
└─ Response: 200 OK { proposal with status='hired' }
   403: Not job owner
   400: Job not open
```

### 5. Reject Proposal

```
POST /proposals/{proposal_id}/reject/
├─ Required: Authentication + role == 'client' + job owner
├─ Database Action:
│  ├─ Set proposal.status = 'rejected'
│  └─ Trigger notification
└─ Response: 200 OK { proposal with status='rejected' }
```

### 6. Withdraw Proposal (Freelancer Only)

```
POST /proposals/{proposal_id}/withdraw/
├─ Required: Authentication + role == 'freelancer' + proposal owner
├─ Validation: proposal.status != 'hired' (can't withdraw hired proposal)
├─ Database Action:
│  ├─ Set proposal.status = 'withdrew'
│  └─ Decrement job.proposals_count
└─ Response: 200 OK { proposal }
   400: Already hired (can't withdraw)
```

### 7. Get My Proposals (Freelancer)

```
GET /jobs/my-applications/
GET /jobs/my_applications/  (Alias)
├─ Required: Authentication + role == 'freelancer'
├─ Triggers: ensure_freelancer_profile_complete()
└─ Response: 200 OK [list of freelancer's proposals]
```

---

## Payment & Transaction Workflow

### 1. Create Payment (Client)

```
POST /payments/transactions/create_payment/
├─ Required: Authentication + role == 'client'
├─ Request: { proposal_id, payment_method? }
├─ Validation:
│  ├─ Proposal exists
│  ├─ User is job client
│  └─ Proposal.status == 'hired'  (CRITICAL: must be hired)
├─ Database Action:
│  ├─ Calculate amounts:
│  │  ├─ amount = proposal.proposed_amount
│  │  ├─ fees = amount * 0.10 (10% platform fee)
│  │  └─ net_amount = amount - fees
│  ├─ Create Transaction:
│  │  ├─ client_id = request.user
│  │  ├─ freelancer_id = proposal.freelancer_id
│  │  ├─ proposal_id = proposal
│  │  ├─ amount, fees, net_amount
│  │  ├─ payment_method = 'stripe' (default)
│  │  ├─ status = 'pending'
│  │  ├─ release_date = now + 7 days
│  │  └─ is_released = false
│  └─ Timestamp created_at
└─ Response: 201 Created { transaction details }
   403: Not job client
   400: Proposal not hired
   404: Proposal not found
```

### 2. Confirm Payment

```
POST /payments/transactions/{transaction_id}/confirm_payment/
├─ Required: Authentication + role == 'client' + transaction owner
├─ Behavior: Process payment through payment gateway (Stripe/Razorpay)
├─ Database Action:
│  ├─ Update transaction.status = 'completed'
│  ├─ Store external provider ID
│  ├─ Update completed_at timestamp
│  └─ Trigger notification
└─ Response: 200 OK { updated transaction }
```

### 3. Release Payment (After Hold Period)

```
POST /payments/transactions/{transaction_id}/release_payment/
├─ Required: Authentication + role == 'client'
├─ Validation:
│  ├─ release_date >= now (wait period passed)
│  └─ status == 'completed'
├─ Database Action:
│  ├─ Set is_released = true
│  ├─ Create Payout to freelancer
│  │  ├─ freelancer_id
│  │  ├─ amount = transaction.net_amount
│  │  ├─ status = 'pending'
│  │  └─ payout_method (from profile)
│  └─ Update proposal.completed = true
└─ Response: 200 OK { transaction + payout info }
```

### 4. List Transactions

```
GET /payments/transactions/
├─ Required: Authentication
├─ Role-Based:
│  ├─ Client sees: Transactions where client_id = request.user
│  └─ Freelancer sees: Transactions where freelancer_id = request.user
└─ Response: 200 OK [list of transactions]
```

### 5. Get Transaction Details

```
GET /payments/transactions/{transaction_id}/
├─ Required: Authentication
├─ Permission: Must be client OR freelancer in transaction
└─ Response: 200 OK { transaction details }
   403: Not authorized
   404: Not found
```

### Payout Management

```
GET /payments/payouts/
├─ Required: Authentication + role == 'freelancer'
└─ Response: List of payouts to freelancer

POST /payments/payouts/request_payout/
├─ Allows freelancer to request custom payout
├─ Same permission requirements
└─ Creates new Payout record
```

---

## Chat & Messaging Workflow

### 1. Create/Get Conversation

```
POST /chat/conversations/
├─ Required: Authentication
├─ Request: { participant_email, subject? }
├─ Validation:
│  ├─ Other user exists by email
│  ├─ **CRITICAL**: Both users must have 'hired' proposal together
│  │  Check: Proposal where:
│  │    - (client_id=me AND freelancer_id=other AND status='hired') OR
│  │    - (client_id=other AND freelancer_id=me AND status='hired')
│  └─ Return existing conversation if already created
├─ Database Action (if new):
│  ├─ Create Conversation:
│  │  ├─ participant_ids = [request.user, other_user]
│  │  ├─ subject = job title or custom
│  │  ├─ proposal_id = the hired proposal
│  │  └─ created_at timestamp
│  └─ Join both users
└─ Response: 201 Created OR 200 OK (existing)
   403: No hired proposal together
   404: Other user not found
```

### 2. List Conversations

```
GET /chat/conversations/
├─ Required: Authentication
├─ Query: Conversations where request.user in participant_ids
├─ Order: By updated_at (most recent first)
└─ Response: 200 OK
   [
     {
       id: "...",
       participant_info: [{ id, email, full_name }, ...],
       subject: "Landing Page Design",
       recent_messages: [...],
       unread_count: 2,
       created_at: "...",
       updated_at: "..."
     },
     ...
   ]
```

### 3. Get Conversation with Messages

```
GET /chat/conversations/{conversation_id}/
├─ Required: Authentication
├─ Permission: Must be participant
├─ Response: 200 OK
   {
     id: "...",
     participant_info: [...],
     subject: "...",
     messages: [
       {
         id: "...",
         sender_id: "...",
         content: "...",
         is_read: false,
         created_at: "..."
       },
       ...
     ]
   }
└─ Errors:
   403: Not a participant
   404: Conversation not found
```

### 4. Get Messages (Paginated)

```
GET /chat/conversations/{conversation_id}/messages/ ?limit=20&offset=0
├─ Required: Authentication + permission
└─ Response: 200 OK { messages: [...], total: 150 }
```

### 5. Send Message

```
POST /chat/messages/
├─ Required: Authentication
├─ Request: {
     conversation_id: "...",
     content: "What's your availability?",
     attachment_url?: "..."
   }
├─ Validation:
│  ├─ Conversation exists and user is participant
│  └─ Content not empty
├─ Database Action:
│  ├─ Create Message:
│  │  ├─ conversation_id
│  │  ├─ sender_id = request.user
│  │  ├─ content
│  │  ├─ is_read = false
│  │  ├─ created_at
│  │  └─ optional: attachment_url
│  ├─ Update conversation.updated_at
│  └─ Trigger notification to other participant
└─ Response: 201 Created { message }
```

### 6. Mark Message as Read

```
POST /chat/messages/{message_id}/mark-read/
├─ Update: is_read = true, read_at = now
└─ Response: 200 OK { message }
```

---

## Notification System

### 1. Notification Types

```
Supported Events:
- job_posted: Client posts new job
- proposal_received: Freelancer submits proposal
- proposal_accepted: Client accepts proposal
- proposal_rejected: Client rejects proposal
- payment_received: Freelancer receives payment
- message_received: New message in conversation
- job_completed: Job marked complete
- review_received: Review posted
```

### 2. Create Notification (Triggered Internally)

```
Backend Auto-Creates When:
├─ Job created → Notify relevant freelancers
├─ Proposal submitted → Notify job client
├─ Proposal accepted → Notify freelancer
├─ Payment released → Notify freelancer
├─ Message sent → Notify conversation partner
└─ Database:
   Notification:
   ├─ user_id: recipient
   ├─ title: "New Proposal"
   ├─ message: "Jane submitted proposal..."
   ├─ notification_type: 'proposal_received'
   ├─ related_id: proposal_id (for linking)
   ├─ is_read: false
   └─ created_at
```

### 3. Get Notifications

```
GET /notifications/notifications/
├─ Required: Authentication
├─ Query: Notification.filter(user_id=request.user).order_by('-created_at')
├─ Optional: ?unread_only=true
└─ Response: 200 OK [list of notifications]
```

### 4. Mark Notification as Read

```
POST /notifications/notifications/{notification_id}/mark_as_read/
├─ Required: Authentication + ownership
├─ Update: is_read = true, read_at = now
└─ Response: 200 OK { notification }
```

### 5. Mark All as Read

```
POST /notifications/notifications/mark_all_as_read/
├─ Bulk update all unread for user
└─ Response: 200 OK { detail: "Marked X notifications as read" }
```

### 6. Get Unread Count

```
GET /notifications/notifications/unread_count/
├─ Query unread notifications for user
└─ Response: 200 OK { unread_count: 5 }
```

### 7. Notification Preferences

```
GET /notifications/preferences/
POST /notifications/preferences/
├─ User can control:
│  ├─ email_on_proposal: true/false
│  ├─ email_on_message: true/false
│  ├─ email_on_payment: true/false
│  ├─ email_on_review: true/false
│  ├─ push_notifications_enabled: true/false
│  └─ sms_notifications_enabled: true/false
└─ Database: NotificationPreference per user
```

---

## Data Models

### CustomUser (Auth)
```python
{
  _id: ObjectId,
  email: String (unique, indexed),
  password: String (bcrypt hashed),
  role: String ('freelancer' | 'client'),
  full_name: String,
  company_name: String,
  face_embedding: [Float],
  violation_count: Int,
  is_restricted: Boolean,
  is_active: Boolean,
  created_at: DateTime,
  updated_at: DateTime
}
```

### Profile (Freelancer)
```python
{
  _id: ObjectId,
  user_id: Reference(CustomUser),
  full_name: String,
  title: String,
  experience_summary: String,
  bio: String,
  skills: [String],
  rating: Float,
  initial_rating: Float,
  final_rating: Float,
  total_projects: Int,
  hourly_rate: Float,
  profile_completed: Boolean,
  profile_completion_percentage: Int,
  created_at: DateTime,
  updated_at: DateTime
}
```

### Job
```python
{
  _id: ObjectId,
  client_id: Reference(CustomUser),
  title: String,
  description: String,
  category: String,
  budget_type: String ('fixed' | 'hourly'),
  budget_min: Float,
  budget_max: Float,
  hourly_rate: Float,
  duration: String ('short' | 'medium' | 'long'),
  required_skills: [String],
  experience_level: String,
  status: String ('draft' | 'open' | 'hired' | 'completed' | 'cancelled'),
  views_count: Int,
  proposals_count: Int,
  is_featured: Boolean,
  created_at: DateTime,
  updated_at: DateTime,
  deadline: DateTime
}
```

### Proposal
```python
{
  _id: ObjectId,
  job_id: Reference(Job),
  freelancer_id: Reference(CustomUser),
  cover_letter: String,
  proposed_amount: Float,
  proposed_timeline: String,
  status: String ('pending' | 'hired' | 'rejected' | 'withdrew' | 'auto_rejected'),
  initial_rating: Float,
  job_rating: Float,
  final_rating: Float,
  completed: Boolean,
  created_at: DateTime,
  updated_at: DateTime
}
```

### Transaction
```python
{
  _id: ObjectId,
  client_id: Reference(CustomUser),
  freelancer_id: Reference(CustomUser),
  proposal_id: Reference(Proposal),
  amount: Float,
  fees: Float,
  net_amount: Float,
  status: String ('pending' | 'completed' | 'failed' | 'refunded'),
  payment_method: String ('stripe' | 'razorpay' | 'invoice'),
  transaction_id: String (external),
  release_date: DateTime,
  is_released: Boolean,
  verified: Boolean,
  created_at: DateTime,
  updated_at: DateTime,
  completed_at: DateTime
}
```

### Conversation
```python
{
  _id: ObjectId,
  participant_ids: [Reference(CustomUser)],
  subject: String,
  proposal_id: Reference(Proposal),
  created_at: DateTime,
  updated_at: DateTime
}
```

### Message
```python
{
  _id: ObjectId,
  conversation_id: Reference(Conversation),
  sender_id: Reference(CustomUser),
  content: String,
  is_read: Boolean,
  read_at: DateTime,
  attachment_url: String,
  created_at: DateTime,
  updated_at: DateTime
}
```

### Notification
```python
{
  _id: ObjectId,
  user_id: Reference(CustomUser),
  title: String,
  message: String,
  notification_type: String,
  related_id: String (job_id/proposal_id/etc),
  is_read: Boolean,
  read_at: DateTime,
  created_at: DateTime
}
```

---

## API Endpoints Reference

### Authentication
- `POST /api/accounts/register/` - Register user
- `POST /api/accounts/token/` - Get JWT tokens (email-based)
- `POST /api/accounts/token/refresh/` - Refresh access token
- `POST /login/` - Alternative login endpoint
- `GET /api/accounts/user/` - Get current user profile
- `GET /api/accounts/me/` - Get current user (alias)
- `PUT /api/accounts/user/` - Update profile
- `PATCH /api/accounts/user/` - Partial update

### Jobs
- `GET /jobs/` - List all jobs (public, filterable)
- `POST /jobs/` - Create job (client only)
- `GET /jobs/{id}/` - Get job details
- `PUT /jobs/{id}/` - Update job (client owner)
- `DELETE /jobs/{id}/` - Delete job (client owner)
- `GET /jobs/{id}/applications/` - Get job applications (client owner)
- `GET /jobs/my-jobs/` - Get my jobs (client)
- `GET /jobs/my_jobs/` - Alias (underscore version)

### Proposals
- `POST /proposals/` - Submit proposal (freelancer)
- `GET /proposals/` - List proposals
- `GET /proposals/{id}/` - Get proposal details
- `POST /proposals/{id}/accept/` - Accept proposal (client)
- `POST /proposals/{id}/reject/` - Reject proposal (client)
- `POST /proposals/{id}/withdraw/` - Withdraw proposal (freelancer)
- `GET /jobs/my-applications/` - Get my proposals (freelancer)
- `GET /jobs/my_applications/` - Alias (underscore)

### Payments
- `GET /payments/transactions/` - List transactions
- `GET /payments/transactions/{id}/` - Get transaction details
- `POST /payments/transactions/create_payment/` - Create payment
- `POST /payments/transactions/{id}/confirm_payment/` - Confirm payment
- `POST /payments/transactions/{id}/release_payment/` - Release payment
- `GET /payments/payouts/` - List payouts
- `POST /payments/payouts/request_payout/` - Request payout

### Chat
- `GET /chat/conversations/` - List conversations
- `POST /chat/conversations/` - Create conversation
- `GET /chat/conversations/{id}/` - Get conversation
- `GET /chat/conversations/{id}/messages/` - Get messages
- `POST /chat/messages/` - Send message

### Notifications
- `GET /notifications/notifications/` - List notifications
- `GET /notifications/notifications/{id}/` - Get notification
- `POST /notifications/notifications/{id}/mark_as_read/` - Mark as read
- `POST /notifications/notifications/mark_all_as_read/` - Mark all read
- `GET /notifications/notifications/unread_count/` - Unread count
- `GET /notifications/preferences/` - Get preferences
- `POST /notifications/preferences/` - Update preferences

### Profiles
- `GET /profiles/me/` - Get my profile
- `PUT /profiles/me/` - Update profile
- `GET /profiles/tests/` - List skill tests
- `POST /profiles/tests/` - Create skill test
- `GET /profiles/tests/{skill}/` - Get test for skill

---

## Key Business Rules

### Authentication
✅ Email-based login (not username)  
✅ JWT tokens valid for 30 min (access), 3 days (refresh)  
✅ Password hashed with bcrypt  
✅ Face recognition for freelancer fraud detection  

### Jobs
✅ Only clients can post jobs  
✅ Jobs must be "open" to receive proposals  
✅ Job status: draft → open → hired → completed  
✅ Freelancers can view all open jobs  

### Proposals
✅ Only freelancers can submit proposals  
✅ One proposal per freelancer per job  
✅ Status: pending → hired (accepted) OR rejected/withdrew  
✅ Accepting proposal auto-rejects others  

### Payments
✅ Only after proposal is "hired"  
✅ Platform takes 10% fee  
✅ 7-day hold period before release  
✅ Freelancer gets 90% of amount  

### Chat
✅ **ONLY after proposal is "hired"**  
✅ Two-way communication  
✅ Tied to specific proposal/job  

### Throttling
✅ Auth endpoints: 5 attempts/minute  
✅ Registration: 10 attempts/hour  
✅ General: 50/hour (anonymous), 1000/hour (authenticated)  

---

## Error Handling

### Standard HTTP Status Codes
- `200 OK` - Success, with data
- `201 Created` - Resource created
- `204 No Content` - Success, no data
- `400 Bad Request` - Invalid input
- `401 Unauthorized` - Missing/invalid token
- `403 Forbidden` - Insufficient permissions
- `404 Not Found` - Resource doesn't exist
- `429 Too Many Requests` - Rate limited

### Error Response Format
```json
{
  "detail": "Error message",
  // OR
  "message": "Error message",
  // OR field-specific
  "email": ["This email is already registered."],
  "face_image": ["Face matching detected."]
}
```

---

## Development Notes

### Running Backend
```bash
cd freelancerbackend
python manage.py runserver
# Server runs on http://localhost:8000
```

### Testing Auth
```bash
# Register
curl -X POST http://localhost:8000/api/accounts/register/ \
  -H "Content-Type: application/json" \
  -d '{"email":"test@test.com","password":"Test123456","role":"client","company_name":"Test Co"}'

# Login
curl -X POST http://localhost:8000/api/accounts/token/ \
  -H "Content-Type: application/json" \
  -d '{"email":"test@test.com","password":"Test123456"}'

# Use token
curl -X GET http://localhost:8000/api/accounts/user/ \
  -H "Authorization: Bearer <access_token>"
```

### Database
- MongoDB required at `mongodb://localhost:27017/freelancer_db`
- Use `initialize_mongodb.py` to create collections

---

**Last Updated**: March 24, 2026  
**Maintainer**: Development Team
