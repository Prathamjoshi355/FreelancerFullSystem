# 📊 Freelancer Platform - Complete Workflow Design

## Table of Contents
1. [System Architecture](#system-architecture)
2. [Frontend Workflow](#frontend-workflow)
3. [Backend Workflow](#backend-workflow)
4. [Core User Journeys](#core-user-journeys)
5. [API Integration Flow](#api-integration-flow)
6. [Database Flow](#database-flow)
7. [Feature Workflows](#feature-workflows)

---

## System Architecture

```
┌─────────────────────────────────────────────────────────────────┐
│                      FRONTEND (React/Next.js)                    │
│  ┌────────────────────────────────────────────────────────────┐ │
│  │  Pages: Register | Login | Jobs | Proposals | Dashboard    │ │
│  │  Components: Job Card | Proposal Form | Chat | Profile    │ │
│  │  State: Redux/Context (Auth, Jobs, Messages)              │ │
│  └────────────────────────────────────────────────────────────┘ │
└──────────────────────┬──────────────────────────────────────────┘
                       │ HTTP/REST (JSON)
                       ↓
┌─────────────────────────────────────────────────────────────────┐
│               API GATEWAY & MIDDLEWARE                           │
│  ┌────────────────────────────────────────────────────────────┐ │
│  │  CORS | JWT Validation | Error Handling | Rate Limiting   │ │
│  └────────────────────────────────────────────────────────────┘ │
└──────────────────────┬──────────────────────────────────────────┘
                       │
                       ↓
┌─────────────────────────────────────────────────────────────────┐
│          DJANGO REST FRAMEWORK BACKEND (Port 8000)               │
│  ┌────────────────────────────────────────────────────────────┐ │
│  │  7 Apps:                                                    │ │
│  │  • Accounts (Auth)        • Profiles (User Info)            │ │
│  │  • Jobs (Postings)        • Proposals (Bidding)             │ │
│  │  • Payments (Transactions) • Chat (Messaging)               │ │
│  │  • Notifications (Alerts)                                   │ │
│  └────────────────────────────────────────────────────────────┘ │
└──────────────────────┬──────────────────────────────────────────┘
                       │
                       ↓
┌─────────────────────────────────────────────────────────────────┐
│                    MONGODB DATABASE                              │
│  ┌────────────────────────────────────────────────────────────┐ │
│  │  Collections: users | profiles | jobs | proposals |         │ │
│  │  transactions | payouts | conversations | messages |         │ │
│  │  notifications | preferences                                │ │
│  └────────────────────────────────────────────────────────────┘ │
└─────────────────────────────────────────────────────────────────┘
```

---

## Frontend Workflow

### 🏗️ Frontend Project Structure

```
freelance-frontend/
├── src/
│   ├── app/
│   │   ├── (auth)
│   │   │   ├── login/page.tsx
│   │   │   ├── register/page.tsx
│   │   │   └── forgot-password/page.tsx
│   │   │
│   │   ├── (client)
│   │   │   ├── dashboard/page.tsx
│   │   │   ├── post-job/page.tsx
│   │   │   ├── jobs/page.tsx
│   │   │   ├── proposals/page.tsx
│   │   │   └── payments/page.tsx
│   │   │
│   │   ├── (freelancer)
│   │   │   ├── dashboard/page.tsx
│   │   │   ├── browse-jobs/page.tsx
│   │   │   ├── proposals/page.tsx
│   │   │   ├── earnings/page.tsx
│   │   │   └── projects/page.tsx
│   │   │
│   │   ├── messages/page.tsx
│   │   ├── profile/page.tsx
│   │   └── search/page.tsx
│   │
│   ├── components/
│   │   ├── JobCard.tsx
│   │   ├── ProposalForm.tsx
│   │   ├── ChatWindow.tsx
│   │   ├── ProfileCard.tsx
│   │   └── PaymentModal.tsx
│   │
│   ├── context/
│   │   └── AuthContext.tsx (User, Token, Role)
│   │
│   └── api.js (API calls)
│
└── package.json
```

### 📱 Frontend Page Workflows

#### 1. **Authentication Flow**

```
┌─────────────────────────────────────────────────────────┐
│                   USER VISITS SITE                       │
└────────────────────┬─────────────────────────────────────┘
                     │
            ┌────────┴────────┐
            ↓                 ↓
    [Is Logged In?]      [Check localStorage for token]
            │                 │
       YES  │ NO             │ YES (Token valid)
            │                 │
            ↓                 ↓
        [HomePage]      [Redirect to Dashboard]
     - Browse Jobs
     - Browse Freelancers
     - See Features
            │
            ↓
        [Click Register/Login]
            │
    ┌───────┴────────┐
    ↓                ↓
[Register]      [Login]
    │                │
    ├─────┬──────────┤
    │     │          │
  [Client] │     [Freelancer]
    │     │          │
    └─────┴──────────┘
        │
        ↓
[Submit to Backend: POST /api/accounts/register/]
    │
    ├─────────────┬──────────────┐
    │             │              │
[Success]  [Email Error]   [Validation Error]
    │             │              │
    ↓             ↓              ↓
[Auto Login]  [Show Error]  [Highlight Fields]
    │
    ↓
[Receive Access & Refresh Token]
    │
    ↓
[Store in localStorage]
    │
    ↓
[Redirect to Dashboard]
```

#### 2. **Client Job Posting Flow**

```
Client Dashboard
    ↓
[Click "Post New Job"]
    ↓
[Job Posting Form]
├─ Title
├─ Description
├─ Category (Dropdown)
├─ Budget Type (Fixed/Hourly)
├─ Budget Min/Max
├─ Required Skills (Multi-select)
├─ Experience Level
├─ Duration
└─ Deadline
    ↓
[Click Submit]
    ↓
[Validate Form (Frontend)]
├─ Title not empty?
├─ Description > 50 chars?
├─ Budget Min < Max?
├─ Deadline in future?
└─ Skills selected?
    ↓ (All Valid)
[Send POST /api/jobs/]
    ↓
[Backend Creates Job in MongoDB]
    ↓
[Returns Job ID & Details]
    ↓
[Show Success Message]
    ↓
[Redirect to My Jobs / Job Details]
    ↓
[Freelancers See Job in Browse Jobs]
```

#### 3. **Freelancer Job Application Flow**

```
Job Listings Page
    ↓
[Freelancer Sees Job Card]
├─ Title
├─ Company
├─ Budget
├─ Skills Required
└─ [View Details] Button
    ↓
[Click View Details]
    ↓
[Job Detail Page Shows]
├─ Full Description
├─ Client Profile
├─ Similar Jobs
└─ [Apply with Proposal] Button
    ↓
[Click Apply]
    ↓
[Proposal Form Opens]
├─ Cover Letter (TextArea)
├─ Proposed Amount
├─ Timeline
└─ [Submit] Button
    ↓
[Validate & Send POST /api/proposals/]
    ↓
[Backend Saves Proposal]
├─ Links to Job ID
├─ Links to Freelancer ID
└─ Status = "pending"
    ↓
[Shows Success: "Proposal Submitted!"]
    ↓
[Freelancer Sees It in "My Proposals"]
[Client Sees It in "Job Applications"]
```

#### 4. **Proposal Management Flow (Client)**

```
Client Dashboard → My Jobs
    ↓
[Click Job Title]
    ↓
[Job Details + Applications Tab]
    ↓
[See All Proposals]
├─ Freelancer Name
├─ Rating & Skills
├─ Proposed Amount
├─ Cover Letter
└─ [Accept] [Reject] [Message] Buttons
    ↓
    ├─────────────────────┐
    │                     │
[Accept]              [Reject]
    │                     │
    ↓                     ↓
[Status→"accepted"]  [Status→"rejected"]
    │                     │
    ↓                     ↓
[Create Transaction] [Notify Freelancer]
    │
    ↓
[Job Status→"in_progress"]
    │
    ↓
[Show "Initiate Payment" Button]
```

#### 5. **Payment Flow (Client)**

```
Accepted Proposal → [Initiate Payment]
    ↓
[Payment Modal Opens]
├─ Amount (auto-filled)
├─ Platform Fee (shown: 10%)
├─ Net Amount (for freelancer)
├─ Payment Method (Stripe/PayPal)
└─ [Confirm Payment] Button
    ↓
[Click Confirm]
    ↓
[Send POST /api/payments/transactions/create_payment/]
    ↓
[Backend Creates Transaction]
├─ Status = "pending"
├─ Amount = Proposal Amount
├─ Fees = 10%
├─ Hold Date = 7 days
└─ Release Date = Now + 7 days
    ↓
[Redirect to Stripe Payment]
    ↓
[Stripe Charges Card]
    ↓
[Update Transaction Status→"completed"]
    ↓
[Show "Payment Confirmed!"]
    ↓
[Send Notification to Freelancer]
```

#### 6. **Chat/Messaging Flow**

```
Job/Proposal Page
    ↓
[Click "Message Freelancer/Client"]
    ↓
[Check if Conversation Exists]
    ├─ YES → [Open Chat]
    └─ NO → [Create Conversation]
        ↓
        [POST /api/chat/conversations/]
        ↓
        [Create with 2 participants]
    ↓
[Chat Window Opens]
├─ Message History (Loaded)
├─ Input Box
└─ [Send] Button
    ↓
[User Types Message]
    ↓
[Click Send]
    ↓
[POST /api/chat/messages/]
    ↓
[Backend Saves Message]
├─ Links to Conversation
├─ sender_id = Current User
├─ is_read = false
└─ created_at = Now
    ↓
[Message Appears in Chat]
    ↓
[Mark Previous Messages as Read]
    ├─ POST /api/chat/messages/mark_as_read/
    └─ Set is_read = true
    ↓
[Notification Sent to Other User]
    ├─ Type = "message_received"
    └─ Show Badge with Unread Count
```

#### 7. **Profile Update Flow (Freelancer)**

```
Profile Page
    ↓
[Edit Profile Button]
    ↓
[Edit Form Shows]
├─ Bio (TextArea)
├─ Skills (Multi-select with autocomplete)
├─ Hourly Rate
├─ Phone Number
├─ Address
├─ City/Country
├─ Avatar Upload
└─ [Save] Button
    ↓
[Validate Form]
    │
    ├─ Skills selected?
    ├─ Rate > 0?
    └─ Bio not empty?
    ↓ (All Valid)
[POST /api/profiles/update_profile/]
    ↓
[Backend Updates Profile]
    ↓
[Show Success: "Profile Updated"]
    ↓
[Profile Now Visible to Clients]
[Appears in Freelancer Search Results]
```

#### 8. **Earnings/Payout Flow (Freelancer)**

```
Freelancer Dashboard → Earnings
    ↓
[Show Available Balance]
├─ Total Earned = Sum of released payments
├─ Pending = Payments on hold (< 7 days)
└─ Available to Withdraw = Released payments
    ↓
[See Transaction History]
│
├─ Job Title
├─ Client Name
├─ Amount
├─ Status (pending/completed/released)
└─ Date
    ↓
[Request Payout]
    │
    ├─ Amount Input
    ├─ Payout Method (Bank/PayPal/Check)
    ├─ Bank Details (if selected)
    └─ [Request] Button
    ↓
[Validate Amount <= Available Balance]
    │
    ├─ YES → POST /api/payments/payouts/request_payout/
    └─ NO → Show Error "Insufficient Balance"
    ↓
[Backend Creates Payout]
├─ Status = "pending"
├─ Amount = Requested
└─ Payout Method = Selected
    ↓
[Show Confirmation]
    │
    ├─ Payout Amount
    ├─ Expected Arrival Time
    └─ Transaction ID
    ↓
[Admin Reviews & Processes]
    │
    ├─ Verify Bank Details
    ├─ Process Payment
    └─ Update Status → "completed"
    ↓
[Freelancer Receives Payment]
```

#### 9. **Notifications Flow**

```
User Dashboard
    ↓
[Notification Bell Icon]
├─ Badge shows unread count
└─ [Click] Opens dropdown
    ↓
[Get /api/notifications/notifications/?unread_only=true]
    ↓
[Show Recent Notifications]
├─ Someone applied to your job
├─ Your proposal was accepted
├─ Payment released
├─ New message received
└─ Timestamp & Mark as Read button
    ↓
[Click on Notification]
    ↓
[Navigates to Relevant Page]
├─ Job → Details Page
├─ Proposal → Proposal Details
├─ Message → Chat Window
└─ Payment → Earnings/Transactions
    ↓
[POST /api/notifications/mark_as_read/]
    │
    └─ Badge count decreases
    ↓
[Notification Settings]
    │
    ├─ Email on Proposal? (toggle)
    ├─ Email on Message? (toggle)
    ├─ Email on Payment? (toggle)
    ├─ Push Notifications? (toggle)
    └─ SMS Notifications? (toggle)
    ↓
[POST /api/notifications/preferences/update_preferences/]
```

---

## Backend Workflow

### 🔐 Authentication System

```
┌─────────────────────────────────────────┐
│   FRONTEND SENDS LOGIN CREDENTIALS      │
│   POST /api/token/                      │
│   {email, password}                     │
└─────────────────────────────────────────┘
              ↓
┌─────────────────────────────────────────┐
│   BACKEND RECEIVES REQUEST              │
│   Middleware: Check CORS                │
└─────────────────────────────────────────┘
              ↓
┌─────────────────────────────────────────┐
│   FIND USER IN MONGODB                  │
│   db.custom_users.findOne({email})      │
└─────────────────────────────────────────┘
              ↓
        ┌─────┴─────┐
        │           │
    [Found]    [Not Found]
        │           │
        ↓           ↓
   [Verify]   [Return 404]
   Password   {detail: "User"}
        │     {not found}
        ├─────┬─────┤
        │     │     │
      [Match] │ [Mismatch]
        │     │     │
        ↓     ↓     ↓
     [YES] [Return 401]
        │ {detail: "Invalid"}
        │ {credentials}
        ↓
    [Create JWT]
    ├─ Header: {alg: HS256}
    ├─ Payload: {sub: user_id, role}
    └─ Signature: HMAC-SHA256
        ↓
    [Create Refresh Token]
        ↓
┌─────────────────────────────────────────┐
│   RESPONSE TO FRONTEND                  │
│   {                                      │
│     "access": "token...",                │
│     "refresh": "token...",               │
│     "user": {                            │
│       "email": "user@example.com",      │
│       "role": "freelancer"              │
│     }                                    │
│   }                                      │
└─────────────────────────────────────────┘
              ↓
    [Frontend stores in localStorage]
              ↓
    [Uses access token for all requests]
    [Authorization: Bearer {token}]
```

### 💼 Job Management Backend

```
┌──────────────────────────────────────────┐
│   FRONTEND SENDS: POST /api/jobs/        │
│   Authorization: Bearer {access_token}   │
│   {                                       │
│     "title": "Build React App",          │
│     "description": "...",                │
│     "category": "Web Development",       │
│     "budget_min": 1000,                  │
│     "budget_max": 5000,                  │
│     "required_skills": ["React"],        │
│     "deadline": "2026-04-13T23:59Z"     │
│   }                                       │
└──────────────────────────────────────────┘
              ↓
┌──────────────────────────────────────────┐
│   MIDDLEWARE: Permission Check           │
│   ├─ Is user authenticated?              │
│   ├─ Is user a CLIENT? (role check)      │
│   └─ Request valid method?               │
└──────────────────────────────────────────┘
              ↓ (All valid)
┌──────────────────────────────────────────┐
│   SERIALIZER: Validate Data              │
│   ├─ Title length? (1-200 chars)        │
│   ├─ Description not empty?              │
│   ├─ budget_min > 0?                     │
│   ├─ budget_min < budget_max?            │
│   └─ Deadline in future?                 │
└──────────────────────────────────────────┘
              ↓ (All valid)
┌──────────────────────────────────────────┐
│   CREATE JOB OBJECT                      │
│   Job {                                   │
│     client_id: ObjectId(user._id),      │
│     title: "Build React App",            │
│     description: "...",                  │
│     category: "Web Development",         │
│     budget_min: 1000,                    │
│     budget_max: 5000,                    │
│     required_skills: ["React"],          │
│     status: "open",                      │
│     views_count: 0,                      │
│     proposals_count: 0,                  │
│     is_featured: false,                  │
│     created_at: now(),                   │
│     deadline: 2026-04-13T23:59Z         │
│   }                                       │
└──────────────────────────────────────────┘
              ↓
┌──────────────────────────────────────────┐
│   SAVE TO MONGODB                        │
│   db.jobs.insertOne(job)                │
└──────────────────────────────────────────┘
              ↓
┌──────────────────────────────────────────┐
│   CREATE NOTIFICATIONS                   │
│   For all freelancers with matching      │
│   skills:                                │
│   ├─ Find profiles with required_skills  │
│   ├─ For each profile create             │
│   │  Notification:                       │
│   │  - type: "job_posted"                │
│   │  - title: "New Job Posted"           │
│   │  - related_id: job._id              │
│   └─ Save notifications                  │
└──────────────────────────────────────────┘
              ↓
┌──────────────────────────────────────────┐
│   RETURN RESPONSE (201 Created)          │
│   {                                       │
│     "id": "507f1f77bcf86cd799439011",  │
│     "title": "Build React App",          │
│     "client_info": {                     │
│       "email": "client@example.com",    │
│       "company_name": "My Co."           │
│     },                                   │
│     "status": "open",                    │
│     "created_at": "2026-03-13T..."      │
│   }                                       │
└──────────────────────────────────────────┘
              ↓
[Frontend redirects to job details]
```

### 📋 Proposal Management Backend

```
FREELANCER SUBMITS PROPOSAL
            ↓
POST /api/proposals/
{
  "job_id": "507f1f77bcf86cd799439011",
  "cover_letter": "I have 8 years...",
  "proposed_amount": 2500,
  "proposed_timeline": "2 weeks"
}
            ↓
BACKEND VALIDATION
├─ Check user role = "freelancer"
├─ Find job with given ID
├─ Check job status = "open"
├─ Check freelancer NOT applied already
├─ Validate proposed_amount > 0
└─ Validate cover_letter not empty
            ↓ (All valid)
CREATE PROPOSAL
{
  job_id: ObjectId(...),
  freelancer_id: ObjectId(user._id),
  cover_letter: "I have 8 years...",
  proposed_amount: 2500,
  proposed_timeline: "2 weeks",
  status: "pending",
  created_at: now()
}
            ↓
SAVE TO MONGODB
db.proposals.insertOne(proposal)
            ↓
UPDATE JOB
job.proposals_count += 1
            ↓
CREATE NOTIFICATION
FOR CLIENT:
{
  user_id: job.client_id,
  type: "proposal_received",
  title: "New Proposal Received",
  message: "{freelancer} submitted a proposal",
  related_id: proposal._id
}
            ↓
RETURN (201 Created)
{
  "id": proposal._id,
  "job_title": job.title,
  "status": "pending",
  "freelancer_info": {...},
  "proposed_amount": 2500
}
```

### 💰 Payment Flow Backend

```
CLIENT ACCEPTS PROPOSAL
            ↓
POST /api/proposals/{id}/accept/
            ↓
VALIDATION
├─ Is this client's job?
├─ Is proposal pending?
└─ Deny other proposals?
            ↓
UPDATE PROPOSAL
proposal.status = "accepted"
            ↓
REJECT OTHER PROPOSALS
db.proposals.updateMany(
  {job_id, status: "pending"},
  {$set: {status: "rejected"}}
)
            ↓
UPDATE JOB
job.status = "in_progress"
            ↓
CLIENT INITIATES PAYMENT
POST /api/payments/transactions/create_payment/
{
  "proposal_id": "...",
  "payment_method": "stripe"
}
            ↓
CALCULATE FEES
total = 2500
fees = 2500 * 0.10 = 250
net_amount = 2500 - 250 = 2250
            ↓
CREATE TRANSACTION
{
  client_id: ObjectId(...),
  freelancer_id: ObjectId(...),
  proposal_id: ObjectId(...),
  amount: 2500,
  fees: 250,
  net_amount: 2250,
  status: "pending",
  payment_method: "stripe",
  is_released: false,
  release_date: now() + 7 days,
  created_at: now()
}
            ↓
SAVE TO MONGODB
db.transactions.insertOne(transaction)
            ↓
CLIENT CONFIRMS PAYMENT (via Stripe)
POST /api/payments/transactions/{id}/confirm_payment/
            ↓
UPDATE TRANSACTION
transaction.status = "completed"
transaction.completed_at = now()
            ↓
CREATE NOTIFICATIONS
├─ For CLIENT: "Payment confirmed"
└─ For FREELANCER: "Payment received"
            ↓
AFTER 7 DAYS:
CLIENT/ADMIN CAN RELEASE PAYMENT
POST /api/payments/transactions/{id}/release_payment/
            ↓
UPDATE TRANSACTION
transaction.is_released = true
            ↓
FREELANCER REQUESTS PAYOUT
POST /api/payments/payouts/request_payout/
{
  "amount": 2250,
  "payout_method": "bank_transfer",
  "bank_account": "...",
  "bank_name": "...",
  "routing_number": "..."
}
            ↓
VALIDATE
├─ Amount <= available_balance?
└─ Bank details valid?
            ↓
CREATE PAYOUT
{
  freelancer_id: ObjectId(...),
  amount: 2250,
  status: "pending",
  payout_method: "bank_transfer",
  bank_account: "...",
  created_at: now()
}
            ↓
ADMIN PROCESSES PAYOUT
UPDATE STATUS: "completed"
            ↓
FREELANCER RECEIVES MONEY
```

### 💬 Chat Backend

```
FRONTEND: Create Conversation
POST /api/chat/conversations/
{
  "participant_email": "other@example.com",
  "subject": "Discussion about Web Dev Job"
}
            ↓
BACKEND:
├─ Find other user by email
├─ Check if already have conversation
├─ If no conversation, create it
│  {
│    participant_ids: [user1_id, user2_id],
│    subject: "...",
│    created_at: now()
│  }
└─ Return conversation (with message history)
            ↓
USER SENDS MESSAGE
POST /api/chat/messages/
{
  "conversation_id": "...",
  "content": "Hi, when can you start?"
}
            ↓
BACKEND:
├─ Verify user is participant
├─ Create message:
│  {
│    conversation_id: ObjectId(...),
│    sender_id: ObjectId(...),
│    content: "Hi, when can you...",
│    is_read: false,
│    created_at: now()
│  }
├─ Save to MongoDB
├─ Update conversation updated_at
└─ Return message
            ↓
RECEIVER SEES UNREAD MESSAGE
├─ Badge shows +1 unread
├─ Query: GET /api/chat/messages/unread_count/
└─ Returns: {unread_count: 1}
            ↓
RECEIVER MARKS AS READ
POST /api/chat/messages/mark_as_read/
{
  "conversation_id": "..."
}
            ↓
BACKEND:
├─ Find all unread messages
├─ Set is_read = true for all
├─ Set read_at = now()
└─ Return count of updated messages
            ↓
BADGE UPDATES
Badge becomes 0
```

---

## Core User Journeys

### 🔄 Complete Job Completion Journey

```
STEP 1: CLIENT JOURNEY
┌──────────────────────────────────────────┐
│ 1. Register as Client                    │
│    POST /api/accounts/register/          │
│    - Send: email, password, company_name│
│    - Receive: access_token, user_data   │
│                                          │
│ 2. Complete Profile                      │
│    POST /api/profiles/update_profile/    │
│    - Add company info, logo, bio         │
│                                          │
│ 3. Post Job                              │
│    POST /api/jobs/                       │
│    - Title: "Build React Dashboard"     │
│    - Budget: $2000-5000                  │
│    - Skills required: React, Node.js    │
│                                          │
│ 4. Receive Proposals                     │
│    GET /api/jobs/{id}/applications/    │
│    - See 5 freelancers applied          │
│    - Review their profiles, ratings     │
│                                          │
│ 5. Select Freelancer                     │
│    POST /api/proposals/{id}/accept/     │
│    - Accept best proposal                │
│    - Auto-reject others                 │
│                                          │
│ 6. Chat & Kickoff                        │
│    POST /api/chat/messages/              │
│    - Discuss requirements, timeline     │
│    - Share files, expectations          │
│                                          │
│ 7. Make Payment                          │
│    POST /api/payments/transactions/...  │
│    - Amount: $2500                       │
│    - Fee: $250 (10%)                     │
│    - Hold for 7 days                     │
│                                          │
│ 8. Monitor Progress                      │
│    - Get notifications on updates       │
│    - Chat with freelancer               │
│    - See project milestones             │
│                                          │
│ 9. Job Completion                        │
│    - Review delivered work               │
│    - Approve completion                  │
│                                          │
│ 10. Release Payment                      │
│     POST /api/payments/.../release_...  │
│     - After 7 days, release funds       │
│     - Freelancer informed                │
└──────────────────────────────────────────┘

STEP 2: FREELANCER JOURNEY
┌──────────────────────────────────────────┐
│ 1. Register as Freelancer                │
│    POST /api/accounts/register/          │
│    - Send: email, password, full_name   │
│    - Role: "freelancer"                  │
│                                          │
│ 2. Setup Profile                         │
│    POST /api/profiles/update_profile/    │
│    - Add skills: React, Node.js          │
│    - Hourly rate: $50                    │
│    - Bio, portfolio, avatar              │
│                                          │
│ 3. Browse Jobs                           │
│    GET /api/jobs/?category=Web%20Dev    │
│    - Filter by skills, budget            │
│    - View job posting                    │
│                                          │
│ 4. Submit Proposal                       │
│    POST /api/proposals/                  │
│    - Cover letter: pitch yourself        │
│    - Proposed amount: $2500              │
│    - Timeline: 3 weeks                   │
│                                          │
│ 5. Await Selection                       │
│    GET /api/notifications/               │
│    - Monitor unread notifications       │
│                                          │
│ 6. Proposal Accepted! 🎉                 │
│    Notification: "proposal_accepted"    │
│    - Job now appears in "My Projects"   │
│    - Chat opens with client              │
│                                          │
│ 7. Communication                         │
│    POST /api/chat/messages/              │
│    - Clarify requirements                │
│    - Receive feedback                    │
│                                          │
│ 8. Do the Work                           │
│    - Develop the project                 │
│    - Regular check-ins via chat          │
│                                          │
│ 9. Deliver Work                          │
│    - Share deliverables                  │
│    - Request review                      │
│                                          │
│ 10. Receive Payment Notification          │
│     Notification: "payment_received"    │
│     POST /api/notifications/             │
│     Status: "pending" (on hold 7 days)  │
│                                          │
│ 11. Wait 7-Day Hold                      │
│     Protection period for disputes      │
│                                          │
│ 12. Payment Released                     │
│     Notification: "payment_released"    │
│     Amount: $2250 (net)                  │
│                                          │
│ 13. Request Payout                       │
│     POST /api/payments/payouts/requ...  │
│     - Bank transfer: $2250               │
│     - Status: pending → processing       │
│                                          │
│ 14. Receive in Bank Account              │
│     Status: "completed"                  │
│     💰 $2250 transferred                 │
│                                          │
│ 15. Earn Reputation                      │
│     - Rating system (for future)         │
│     - Show on freelancer profile        │
└──────────────────────────────────────────┘
```

---

## API Integration Flow

### 📡 Request-Response Cycle

```
┌─────────────────────────────────────────┐
│         FRONTEND (React)                │
│  state ← API response                   │
│  renders UI                             │
└────────────────────┬────────────────────┘
                     │
            ┌────────▼────────┐
            │ HTTP Request    │
            │ POST /api/jobs/ │
            │ Header: JWT     │
            │ Body: JSON      │
            └────────┬────────┘
                     │
             ┌───────▼────────┐
             │   Middleware   │
             │   CORS Check   │
             │   Rate Limit   │
             └───────┬────────┘
                     │
          ┌──────────▼──────────┐
          │ Django URL Router   │
          │ Match route to view │
          └──────────┬──────────┘
                     │
         ┌───────────▼───────────┐
         │ Django View/ViewSet   │
         │ - Get request         │
         │ - Check permissions   │
         │ - Validate data       │
         └───────────┬───────────┘
                     │
        ┌────────────▼────────────┐
        │ Business Logic          │
        │ - Calculate fees        │
        │ - Check availability    │
        │ - Validate rules        │
        └────────────┬────────────┘
                     │
        ┌────────────▼────────────┐
        │ MongoDB Operations      │
        │ - Query data            │
        │ - Insert/Update/Delete  │
        │ - Return result         │
        └────────────┬────────────┘
                     │
        ┌────────────▼────────────┐
        │ Serializer              │
        │ - Convert to JSON       │
        │ - Format response       │
        └────────────┬────────────┘
                     │
            ┌────────▼────────┐
            │ HTTP Response   │
            │ Status: 201     │
            │ Body: JSON      │
            └────────┬────────┘
                     │
┌────────────────────▼────────────────────┐
│         FRONTEND (React)                │
│  Receives response                      │
│  Updates state                          │
│  Re-renders UI                          │
│  Shows success/error message            │
└─────────────────────────────────────────┘
```

### 🔑 Token Flow & Refresh

```
┌──────────────────────────────────┐
│  USER LOGS IN                    │
│  POST /api/token/                │
│  + email & password              │
└──────────────────────────────────┘
           ↓
┌──────────────────────────────────┐
│  BACKEND RESPONSE                │
│  {                               │
│    "access": "eyJ0...",          │
│    "refresh": "eyJ0...",         │
│    "user": {...}                 │
│  }                               │
└──────────────────────────────────┘
           ↓
┌──────────────────────────────────┐
│  FRONTEND STORES                 │
│  localStorage.setItem(           │
│    'access_token',               │
│    response.access               │
│  )                               │
│  localStorage.setItem(           │
│    'refresh_token',              │
│    response.refresh              │
│  )                               │
└──────────────────────────────────┘
           ↓
┌──────────────────────────────────┐
│  FRONTEND USES ACCESS TOKEN      │
│  ALL REQUESTS:                   │
│  Authorization: Bearer {token}   │
│                                  │
│  Token expires in ~5 minutes     │
└──────────────────────────────────┘
           ↓
    ┌━━━━━━━━━━━━┓
    ┃ 5 MINUTES  ┃
    ┃ PASS       ┃
    └━━━━━━━━━━━━┘
           ↓
┌──────────────────────────────────┐
│  TOKEN EXPIRES                   │
│  Next API call returns 401       │
└──────────────────────────────────┘
           ↓
┌──────────────────────────────────┐
│  FRONTEND REFRESHES TOKEN        │
│  POST /api/token/refresh/        │
│  {                               │
│    "refresh": saved_refresh_...  │
│  }                               │
└──────────────────────────────────┘
           ↓
┌──────────────────────────────────┐
│  BACKEND VALIDATES & RESPONDS    │
│  {                               │
│    "access": "new_token..."      │
│  }                               │
└──────────────────────────────────┘
           ↓
┌──────────────────────────────────┐
│  FRONTEND UPDATES TOKEN          │
│  localStorage → new access token │
└──────────────────────────────────┘
           ↓
┌──────────────────────────────────┐
│  RETRY ORIGINAL REQUEST          │
│  With new access token           │
└──────────────────────────────────┘
           ↓
┌──────────────────────────────────┐
│  SUCCESS ✅                       │
└──────────────────────────────────┘
```

---

## Database Flow

### 📊 MongoDB Collections & Relationships

```
┌─────────────────────────────────────────────┐
│ CUSTOM_USERS (Root Collection)              │
├─────────────────────────────────────────────┤
│ _id: ObjectId                               │
│ email: email (unique, indexed)              │
│ password: hashed_password                   │
│ full_name: string (if freelancer)          │
│ company_name: string (if client)           │
│ role: "client" || "freelancer"             │
│ is_active: boolean                         │
│ created_at: datetime                       │
│ updated_at: datetime                       │
└─────────────────────────────────────────────┘
         ↑                  ↑
         │                  │
    ┌────┴────┐        ┌────┴────┐
    │          │        │         │
    ↓          ↓        ↓         ↓

┌──────────────────────┐  ┌──────────────────────┐
│ PROFILES             │  │ JOBS                 │
├──────────────────────┤  ├──────────────────────┤
│ _id: ObjectId        │  │ _id: ObjectId        │
│ user_id: (FK)        │  │ client_id: (FK)      │
│ bio: string          │  │ title: string        │
│ skills: [string]     │  │ description: string  │
│ hourly_rate: float   │  │ category: string     │
│ rating: float        │  │ budget_min: float    │
│ avatar: url          │  │ budget_max: float    │
│ phone: string        │  │ required_skills: [] │
│ address: string      │  │ status: string       │
│ city: string         │  │ deadline: datetime   │
│ country: string      │  │ proposals_count: int │
│ city: string         │  │ created_at: datetime │
│ created_at: datetime │  │ updated_at: datetime │
└──────────────────────┘  └──────┬───────────────┘
         ↑                        │
         │                   ┌────┴────┐
         │                   │         │
         │                   ↓         ↓
         │           ┌──────────────────────────┐
         │           │ PROPOSALS                │
         │           ├──────────────────────────┤
         │           │ _id: ObjectId            │
         │           │ job_id: (FK→jobs)        │
         │           │ freelancer_id: (FK)      │
         │           │ cover_letter: string     │
         │           │ proposed_amount: float   │
         │           │ proposed_timeline: str   │
         │           │ status: string           │
         │           │ created_at: datetime     │
         │           └──────────┬───────────────┘
         │                      │
         │              ┌───────┴────────┐
         │              │                │
         │              ↓                ↓
         │       ┌────────────────┐  ┌────────────────┐
         │       │ TRANSACTIONS   │  │ PAYOUTS        │
         │       ├────────────────┤  ├────────────────┤
         │       │ client_id:(FK) │  │ freelancer:... │
         │       │ freelancer:... │  │ amount: float  │
         │       │ proposal:(FK)  │  │ status: string │
         │       │ amount: float  │  │ payout_method: │
         │       │ fees: float    │  │ bank_details   │
         │       │ net_amount:... │  │ created_at     │
         │       │ status: string │  │ processed_at   │
         │       │ hold_date:...  │  └────────────────┘
         │       │ released: bool │
         │       └────────────────┘
         │
         └─────────────────────┐
                               │
                    ┌──────────┴──────────┐
                    │                     │
                    ↓                     ↓
            ┌──────────────────┐  ┌──────────────────┐
            │ CONVERSATIONS    │  │ MESSAGES         │
            ├──────────────────┤  ├──────────────────┤
            │ participant_ids[]│  │ conversation:(FK)│
            │ subject: string  │  │ sender_id: (FK)  │
            │ created_at       │  │ content: string  │
            │ updated_at       │  │ is_read: bool    │
            └──────────────────┘  │ read_at: datetime│
                                  │ created_at       │
                                  └──────────────────┘

┌──────────────────────────────────────────────────┐
│ NOTIFICATIONS                                    │
├──────────────────────────────────────────────────┤
│ user_id: (FK→custom_users)                      │
│ title: string                                    │
│ message: string                                  │
│ notification_type: string (enum)                │
│ related_id: ObjectId (job/proposal/transaction) │
│ is_read: boolean                                 │
│ read_at: datetime                                │
│ created_at: datetime                             │
└──────────────────────────────────────────────────┘

┌──────────────────────────────────────────────────┐
│ NOTIFICATION_PREFERENCES                         │
├──────────────────────────────────────────────────┤
│ user_id: (FK→custom_users, unique)              │
│ email_on_proposal: boolean                       │
│ email_on_message: boolean                        │
│ email_on_payment: boolean                        │
│ push_notifications_enabled: boolean              │
│ sms_notifications_enabled: boolean               │
│ created_at: datetime                             │
│ updated_at: datetime                             │
└──────────────────────────────────────────────────┘
```

---

## Feature Workflows

### 1️⃣ Search & Filter

```
FRONTEND: GET /api/jobs/?category=Web&experience=intermediate&min_budget=1000

BACKEND:
├─ Parse query parameters
├─ Start with Job.objects.filter(status='open')
│
├─ IF category exists:
│  └─ jobs = jobs.filter(category=category)
│
├─ IF experience_level exists:
│  └─ jobs = jobs.filter(experience_level=experience)
│
├─ IF min_budget exists:
│  └─ jobs = jobs.filter(budget_min__gte=min_budget)
│
├─ IF max_budget exists:
│  └─ jobs = jobs.filter(budget_max__lte=max_budget)
│
├─ ORDER BY created_at DESC
├─ SERIALIZE results
└─ RETURN 200 OK [job1, job2, job3, ...]

FRONTEND:
├─ Receives jobs list
├─ Map through results
├─ Render JobCard for each
├─ Show pagination controls
└─ Allow adding to favorites (future)
```

### 2️⃣ Role-Based Access Control

```
REQUEST: POST /api/jobs/
HEADER: Authorization: Bearer {token}
BODY: {job data}

BACKEND:
├─ Extract token from header
├─ Verify token signature
├─ Get user from token payload
│
├─ CHECK PERMISSION:
│  ├─ Is user.role == 'client'?
│  │  ├─ YES → Continue
│  │  └─ NO → Return 403 "Only clients can post jobs"
│  │
│  ├─ Can user create 10+ jobs/day?
│  │  ├─ YES → Continue
│  │  └─ NO → Return 429 "Rate limit exceeded"
│  │
│  └─ Is user.is_active == true?
│     ├─ YES → Continue
│     └─ NO → Return 403 "Account disabled"
│
└─ Process request normally
```

### 3️⃣ Payment Hold & Release

```
TIMELINE OF PAYMENT:

[T0] Client Confirms Payment
├─ Status: "pending"
├─ is_released: false
├─ hold_date_start: NOW
└─ hold_date_end: NOW + 7 DAYS

[T0 to T6] Payment Hold Period
├─ Money in escrow
├─ Client CAN dispute
├─ Freelancer cannot access money
└─ 7-day protection window

[T7] Hold Period Expires
├─ Client CAN release payment
├─ Or backend auto-releases
├─ POST /api/payments/.../release_payment/
│
└─ Backend:
   ├─ Check: is_released == false?
   ├─ Check: now() > hold_date_end?
   ├─ Update: is_released = true
   ├─ Notify freelancer
   └─ Return 200 OK

[T7+] Freelancer Can Request Payout
├─ POST /api/payments/payouts/request_payout/
├─ Check: amount <= available_balance?
├─ Create payout record
├─ Status: "pending"
└─ Admin processes → "completed"

[T10+] Freelancer Receives Money
├─ Payout status: "completed"
├─ Bank transfer received
└─ Freelancer happy! 💰
```

### 4️⃣ Bidding & Negotiation

```
FREELANCER SUBMITS PROPOSAL (Bid)
├─ Amount: $2500
├─ Timeline: "3 weeks"
├─ Cover letter: pitch
└─ Status: "pending"

CLIENT REVIEWS PROPOSALS
├─ Can see multiple bids
├─ Compare: price, timeline, ratings
├─ Option 1: Message freelancer to negotiate
│  └─ START CONVERSATION
│     ├─ Discuss price
│     ├─ Discuss timeline
│     ├─ Discuss requirements
│     └─ REACH AGREEMENT
│
└─ Option 2: Accept best proposal
   ├─ ACCEPT PROPOSAL
   ├─ Status: "accepted"
   ├─ REJECT OTHER PROPOSALS
   │  └─ Update status: "rejected"
   │     Send notification to those freelancers
   │
   ├─ UPDATE JOB STATUS: "in_progress"
   ├─ INITIATE PAYMENT
   │  └─ Create transaction
   │
   └─ START WORK!
```

---

## Complete System Timeline

```
DAY 0: USER REGISTRATION
8:00 AM - Client registers on platform
         ├─ POST /api/accounts/register/ (client)
         └─ Email verification (future)

9:00 AM - Freelancer registers
         ├─ POST /api/accounts/register/ (freelancer)
         └─ Creates default profile

10:00 AM - Both complete profiles
          ├─ Client: adds company info
          └─ Freelancer: adds skills, rate

DAY 1: JOB POSTING & DISCOVERY
8:00 AM - Client posts job
         ├─ POST /api/jobs/
         ├─ "Build React Dashboard"
         ├─ Budget: $2000-3000
         ├─ Deadline: 1 month
         └─ Notifications sent to matching freelancers
            └─ Freelancer receives: job_posted alert

9:00 AM - Freelancer sees job notification
         ├─ Clicks on job
         ├─ GET /api/jobs/{id}/
         ├─ Views details
         └─ Reviews client profile

DAY 2: BIDDING PERIOD
10:00 AM - Freelancer 1 submits proposal
          ├─ POST /api/proposals/
          ├─ Amount: $2500
          ├─ Timeline: 3 weeks
          ├─ Client notified: "proposal_received"
          └─ Freelancer 2 also submits ($2200, 2 weeks)

DAY 3: NEGOTIATION
3:00 PM - Client messages Freelancer 2
         ├─ POST /api/chat/conversations/
         ├─ "Can you do it for $2000?"
         ├─ Freelancer 2 responds
         └─ Client: "Deal!"

DAY 4: PROPOSAL ACCEPTANCE
9:00 AM - Client accepts Freelancer 2's proposal
         ├─ POST /api/proposals/{id}/accept/
         ├─ Freelancer 1 receives: "proposal_rejected"
         ├─ Freelancer 2 receives: "proposal_accepted"
         ├─ Job status → "in_progress"
         └─ Client can now pay

DAY 4: PAYMENT INITIATED
10:00 AM - Client initiates payment
          ├─ POST /api/payments/transactions/create_payment/
          ├─ Amount: $2000
          ├─ Fee: $200 (10%)
          ├─ Freelancer gets: $1800 (net)
          ├─ Status: "pending"
          ├─ Hold until: DAY 11
          └─ Freelancer notified

DAY 4: WORK BEGINS
3:00 PM - Freelancer starts work
         ├─ Daily updates via chat
         ├─ POST /api/chat/messages/
         └─ Client satisfied with progress

DAY 25: DELIVERY
5:00 PM - Freelancer delivers completed work
         ├─ Uploads to shared folder
         ├─ Messages client: "Ready for review"
         ├─ Client reviews code
         ├─ Client: "Looks great!"
         └─ Client confirms completion

DAY 11: PAYMENT HOLD EXPIRES
Automatic or manual release happens
├─ POST /api/payments/{id}/release_payment/
├─ Status: "completed" → "released"
└─ Freelancer can now request payout

DAY 12: FREELANCER REQUESTS PAYOUT
9:00 AM - Freelancer requests payout
         ├─ POST /api/payments/payouts/request_payout/
         ├─ Amount: $1800
         ├─ Method: bank transfer
         ├─ Status: "pending"
         └─ Freelancer notified

DAY 12-14: ADMIN PROCESSES
Admin reviews and processes payout
├─ Verify bank details
├─ Initiate transfer
└─ Update status: "processing" → "completed"

DAY 15: PAYMENT RECEIVED
Freelancer's bank account receives: $1800
├─ Happy freelancer! 💰
└─ Review system (future): Rate client

LIFETIME: REPUTATION BUILDING
├─ Freelancer profile updated:
│  ├─ total_projects: 1
│  ├─ Rating: 5 stars (future)
│  └─ Appears higher in search results
│
└─ Client profile updated:
   ├─ Jobs completed: 1
   └─ Reliable buyer badge (future)
```

---

## Error Handling Flow

```
FRONTEND SENDS REQUEST
            ↓
┌─────────────────────────────────┐
│ BACKEND RECEIVES               │
│ └─ Check CORS                  │
│ └─ Check rate limit            │
│ └─ Parse JSON                  │
└─────────────────────────────────┘
            ↓
    ┌───────┴───────┐
    │ ANY ERROR?    │
    └─┬─────────┬───┘
      │         │
     YES        NO
      │         │
      ↓         ↓
┌──────────────┐ Continue
│ Error Type?  │ Processing
└──┬─┬─┬─┬─┬───┘
   │ │ │ │ │
Syntax Auth Val Perm DB
   │ │ │ │ │
   ↓ ↓ ↓ ↓ ↓
  400 401 400 403 500
   │ │ │ │ │
   └─┴─┴─┴─┘
      │
      ↓
RESPONSE WITH ERROR
{
  "detail": "Error message",
  "status": 400-500
}
      │
      ↓
FRONTEND CATCHES ERROR
      │
      ├─ 400: Bad request - show form errors
      ├─ 401: Unauthorized - redirect to login
      ├─ 403: Forbidden - show permission error
      ├─ 404: Not found - show not found page
      ├─ 500: Server error - show "try again"
      │
      └─ Display error in UI
         └─ Toast/Modal with message
```

---

## Summary Table

| Component | Technology | Status | Endpoints |
|-----------|-----------|--------|-----------|
| **Frontend** | React/Next.js | ✅ Ready | Pages, Components |
| **Backend** | Django 4.2 | ✅ Ready | 48 Endpoints |
| **Database** | MongoDB | ✅ Ready | 10 Collections |
| **Auth** | JWT | ✅ Ready | Register, Login, Refresh |
| **Jobs** | Full CRUD | ✅ Ready | Create, Browse, Apply |
| **Proposals** | Full CRUD | ✅ Ready | Submit, Accept, Reject |
| **Payments** | Transaction Mgmt | ✅ Ready | Create, Release, Payout |
| **Chat** | Messaging | ✅ Ready | Conversations, Messages |
| **Notifications** | Alert System | ✅ Ready | 8 Types, Preferences |
| **Profiles** | User Info | ✅ Ready | View, Update, Search |

---

## Quick Reference

### Frontend Start
```bash
cd freelance-frontend
npm run dev
# Opens on localhost:3000
```

### Backend Start
```bash
cd freelancerbackend
python manage.py runserver
# Runs on localhost:8000/api/
```

### API Base URL
```
http://localhost:8000/api/
```

### Key Endpoints
```
POST   /accounts/register/        → Register
POST   /token/                    → Login
GET    /jobs/                     → Browse jobs
POST   /jobs/                     → Post job
POST   /proposals/                → Submit proposal
POST   /payments/transactions/    → Create payment
POST   /chat/messages/            → Send message
GET    /notifications/            → Get alerts
```

---

**Workflow Design Complete** ✅  
**Total Pages**: ~15 Pages  
**Total Endpoints**: 48 Endpoints  
**Total Components**: ~30 Components  
**Database Collections**: 10 Collections  
**User Flows**: 8+ Complete Journeys  

All interconnected and working together seamlessly!
