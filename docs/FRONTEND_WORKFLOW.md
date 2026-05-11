# Freelancer Platform - Frontend Workflow Documentation

**Version**: 1.0  
**Framework**: React + Next.js 14 (App Router)  
**Styling**: Tailwind CSS + shadcn/ui  
**State Management**: Context API + localStorage  
**API Client**: Axios with Interceptors  

---

## Table of Contents

1. [Architecture Overview](#architecture-overview)
2. [Project Structure](#project-structure)
3. [Authentication Flow](#authentication-flow)
4. [State Management](#state-management)
5. [API Integration](#api-integration)
6. [Component Workflows](#component-workflows)
7. [Page Structures](#page-structures)
8. [User Journeys](#user-journeys)
9. [Error Handling](#error-handling)
10. [Performance Considerations](#performance-considerations)

---

## Architecture Overview

### Tech Stack
- **Framework**: React 18 + Next.js 14 (App Router)
- **Language**: TypeScript
- **State**: Context API + localStorage
- **HTTP Client**: Axios with request/response interceptors
- **Styling**: Tailwind CSS + shadcn/ui components
- **Build Tool**: Vite (dev), Next.js (prod)

### Key Design Principles
✅ Protected routes enforce authentication  
✅ Role-based route access (freelancer vs client)  
✅ Token persistence across sessions  
✅ Automatic token refresh on 401 responses  
✅ Graceful fallback for API failures  
✅ Loading states on all data-fetching operations  

---

## Project Structure

```
freelance-frontend/
├── src/
│   ├── api.js                           # Axios instance + interceptors
│   ├── tokens.js                        # Token constants
│   ├── app/                             # Next.js app router
│   │   ├── layout.tsx                   # Root layout
│   │   ├── page.tsx                     # Home page
│   │   ├── login/page.tsx               # Login page
│   │   ├── register/page.tsx            # Role selection
│   │   ├── register/client/page.tsx     # Client signup
│   │   ├── register/freelancer/page.tsx # Freelancer signup
│   │   │
│   │   ├── client/                      # Client routes
│   │   │   ├── layout.tsx               # Client sidebar nav
│   │   │   ├── dashboard/page.tsx       # Client overview
│   │   │   ├── post-job/page.tsx        # Job creation form
│   │   │   ├── jobs/page.tsx            # My jobs list
│   │   │   ├── proposals/page.tsx       # Received proposals
│   │   │   ├── hire/page.tsx            # Hiring management
│   │   │   ├── payments/page.tsx        # Payment history
│   │   │   ├── profile/edit/page.tsx    # Profile settings
│   │   │   └── chat/page.tsx            # Messages
│   │   │
│   │   ├── freelancer/                  # Freelancer routes
│   │   │   ├── layout.tsx               # Freelancer sidebar nav
│   │   │   ├── dashboard/page.tsx       # Freelancer overview
│   │   │   ├── jobs/page.tsx            # Browse jobs
│   │   │   ├── proposals/page.tsx       # My proposals/bids
│   │   │   ├── profile/edit/page.tsx    # Profile & skills
│   │   │   ├── payments/page.tsx        # Earnings
│   │   │   └── chat/page.tsx            # Messages
│   │   │
│   │   └── profile/
│   │       └── edit/page.tsx            # Generic profile edit
│   │
│   ├── components/
│   │   ├── auth/
│   │   │   ├── login-form.tsx           # Login form component
│   │   │   ├── register-form.tsx        # Signup form (reusable)
│   │   │   └── google-auth.tsx          # Google OAuth button
│   │   │
│   │   ├── jobs/
│   │   │   ├── job-card.tsx             # Job listing card
│   │   │   ├── job-detail.tsx           # Job detail view
│   │   │   ├── job-filters.tsx          # Filter sidebar
│   │   │   ├── job-form.tsx             # Job creation form
│   │   │   └── apply-job.tsx            # Apply/bid form
│   │   │
│   │   ├── proposals/
│   │   │   ├── proposal-card.tsx        # Proposal listing
│   │   │   ├── proposal-detail.tsx      # Full proposal view
│   │   │   ├── proposal-actions.tsx     # Accept/reject buttons
│   │   │   └── submit-proposal.tsx      # Proposal form
│   │   │
│   │   ├── chat/
│   │   │   ├── conversation-list.tsx    # Conversations sidebar
│   │   │   ├── message-thread.tsx       # Messages display
│   │   │   ├── message-input.tsx        # Send message box
│   │   │   └── start-chat.tsx           # New conversation
│   │   │
│   │   ├── payments/
│   │   │   ├── payment-form.tsx         # Payment initiation
│   │   │   ├── transaction-list.tsx     # Transaction history
│   │   │   ├── invoice.tsx              # Invoice display
│   │   │   └── payout-request.tsx       # Payout form
│   │   │
│   │   ├── profile/
│   │   │   ├── edit-profile-form.tsx    # Profile editor
│   │   │   ├── skills-selector.tsx      # Skill picker
│   │   │   ├── profile-completion.tsx   # Progress bar
│   │   │   └── face-capture.tsx         # Camera/face upload
│   │   │
│   │   ├── ui/
│   │   │   └── [shadcn components]      # Reusable UI pieces
│   │   │       ├── button.tsx
│   │   │       ├── card.tsx
│   │   │       ├── input.tsx
│   │   │       ├── badge.tsx
│   │   │       ├── dialog.tsx
│   │   │       ├── tabs.tsx
│   │   │       └── ...
│   │   │
│   │   ├── common/
│   │   │   ├── navbar.tsx               # Top navigation
│   │   │   ├── footer.tsx               # Page footer
│   │   │   ├── sidebar.tsx              # Client/freelancer nav
│   │   │   ├── loading-skeleton.tsx     # Skeleton loaders
│   │   │   └── empty-state.tsx          # No data fallback
│   │   │
│   │   └── ProtectedRoute.tsx            # Auth guard component
│   │
│   ├── context/
│   │   └── AuthContext.tsx               # Auth state provider
│   │
│   ├── hooks/
│   │   ├── useAuth.ts                   # Auth context hook
│   │   ├── useJobs.ts                   # Jobs data hook
│   │   ├── useProposals.ts              # Proposals data hook
│   │   ├── useChat.ts                   # Chat data hook
│   │   └── useApi.ts                    # Generic API hook
│   │
│   ├── services/
│   │   └── apiService.js                # Centralized API calls
│   │
│   ├── styles/
│   │   ├── globals.css                  # Global styles
│   │   └── theme.css                    # Tailwind theme
│   │
│   └── lib/
│       ├── utils.ts                     # Helper functions
│       ├── constants.ts                 # App constants
│       └── validation.ts                # Form validation
│
├── public/
│   ├── logo.svg
│   └── images/
│
├── .env.local                           # Environment variables
├── next.config.mjs                      # Next.js config
├── tsconfig.json                        # TypeScript config
├── tailwind.config.ts                   # Tailwind config
├── postcss.config.mjs                   # PostCSS config
└── package.json
```

---

## Authentication Flow

### 1. Initial Page Load

```
App Mount
├─ AuthProvider wraps entire app
├─ useEffect: checkAuth()
│  ├─ Read from localStorage:
│  │  ├─ access_token
│  │  ├─ refresh_token
│  │  └─ user_data
│  ├─ Parse user_data JSON
│  └─ Set auth state if tokens exist
├─ If no tokens: isAuthenticated = false
└─ Render routes based on auth state
```

### 2. Login Page

```
/login (Public Route)
├─ LoginForm Component
│  ├─ Form inputs: email, password
│  ├─ onSubmit Handler:
│  │  ├─ Fetch: POST /api/accounts/token/
│  │  ├─ Request: { email, password }
│  │  ├─ Response: { access, refresh, user }
│  │  ├─ Handle response:
│  │  │  ├─ Extract tokens (accessToken = data.access || data.tokens?.access)
│  │  │  ├─ Store in localStorage:
│  │  │  │  ├─ localStorage.setItem("access_token", accessToken)
│  │  │  │  ├─ localStorage.setItem("refresh_token", refreshToken)
│  │  │  │  └─ localStorage.setItem("user_data", JSON.stringify(user))
│  │  │  ├─ Call auth.login(user, token) → updates context
│  │  │  └─ Redirect based on role:
│  │  │     ├─ freelancer → /freelancer/profile/edit
│  │  │     └─ client → /client/profile/edit
│  │  └─ Error handling:
│  │     ├─ Show error message
│  │     ├─ Clear form on failure
│  │     └─ Log error to console
│  └─ Loading state on submit button
└─ Link to register/forgot-password
```

### 3. Registration/Signup

```
/register (Public Route - Role Selection)
├─ Two buttons:
│  ├─ "Sign up as Client" → /register/client
│  └─ "Sign up as Freelancer" → /register/freelancer

/register/client (Client Signup)
├─ RegisterForm Component (role='client')
│  ├─ Form fields:
│  │  ├─ Email (required, unique)
│  │  ├─ Password (required, strength indicator)
│  │  └─ Company Name (required)
│  ├─ onSubmit Handler:
│  │  ├─ Payload: { email, password, company_name, role: 'client' }
│  │  ├─ POST /api/accounts/register/
│  │  ├─ Response: { user, access, refresh }
│  │  ├─ Store tokens & user data
│  │  └─ Redirect to /login (user fills profile next)
│  └─ Error handling: Show field-specific errors
└─ Link to login

/register/freelancer (Freelancer Signup)
├─ RegisterForm Component (role='freelancer')
│  ├─ Form fields:
│  │  ├─ Email (required, unique)
│  │  ├─ Password (required, strength indicator)
│  │  ├─ Full Name (required)
│  │  ├─ **Face Capture** (required)
│  │  │  ├─ Video stream from camera
│  │  │  ├─ Capture button → canvas snapshot
│  │  │  ├─ Retake button → restart camera
│  │  │  └─ Store as base64 data:image/jpeg;base64,...
│  │  └─ Canvas (hidden) for image data
│  ├─ onSubmit Handler:
│  │  ├─ Validation:
│  │  │  ├─ Check password strength >= 2/4
│  │  │  ├─ Require face_image for freelancers
│  │  │  └─ All fields non-empty
│  │  ├─ Payload:
│  │  │  {
│  │  │    email,
│  │  │    password,
│  │  │    full_name,
│  │  │    role: 'freelancer',
│  │  │    face_image: "data:image/jpeg;base64,..."
│  │  │  }
│  │  ├─ POST /api/accounts/register/
│  │  ├─ Trigger backend face recognition
│  │  ├─ Response: { user, access, refresh }
│  │  └─ Redirect to /login
│  └─ Error handling: Show errors, allow retake
└─ Link to login
```

### 4. Protected Routes

```
ProtectedRoute Component
├─ Props:
│  ├─ children: ReactNode
│  ├─ requireProfileCompletion?: boolean (default: true)
│  └─ requiredRole?: 'freelancer' | 'client'
├─ useAuth() Hook:
│  ├─ Check: isAuthenticated
│  ├─ Check: user exists
│  ├─ Check: user.role === requiredRole (if specified)
│  ├─ Check: profileCompleted (if required)
│  └─ Redirect logic:
│     ├─ Not authenticated → /login
│     ├─ Wrong role → /freelancer/dashboard or /client/dashboard
│     ├─ Profile incomplete → /freelancer/profile/edit or /client/profile/edit
│     └─ All checks pass → render children
└─ Example Usage:
   <ProtectedRoute requiredRole="freelancer" requireProfileCompletion={true}>
     <JobBrowser />
   </ProtectedRoute>
```

### 5. Token Refresh Flow

```
Axios Response Interceptor
├─ Check: response.status === 401 (Unauthorized)
├─ Check: Not already retrying (originalRequest._retry)
├─ Check: Not a public endpoint (register, token, refresh)
├─ If all true:
│  ├─ Mark: originalRequest._retry = true
│  ├─ Read from localStorage: refresh_token
│  ├─ POST /api/accounts/token/refresh/
│  │  ├─ With: { refresh: refreshToken }
│  │  └─ Receive: { access: newAccessToken }
│  ├─ Update localStorage: access_token = newAccessToken
│  ├─ Update axios default headers
│  ├─ Retry original request with new token
│  └─ Return new response
├─ On refresh failure:
│  ├─ Clear localStorage
│  ├─ Redirect to /login
│  └─ Return error
└─ Skip for public endpoints (they never get 401s)
```

---

## State Management

### AuthContext

```typescript
interface AuthContextType {
  user: User | null,
  isAuthenticated: boolean,
  profileCompleted: boolean,
  login: (user: User, token: string) => void,
  logout: () => void,
  checkAuth: () => void,
  updateProfile: (profile: Profile) => void
}

// User Object Structure
interface User {
  id?: string,
  email: string,
  full_name?: string,
  company_name?: string,
  role: 'freelancer' | 'client'
}
```

### Storage (localStorage)

```javascript
// Keys
const ACCESS_TOKEN_KEY = 'access_token'
const REFRESH_TOKEN_KEY = 'refresh_token'
const USER_DATA_KEY = 'user_data'
const PROFILE_COMPLETED_KEY = 'profile_completed'
const GOOGLE_ACCESS_TOKEN = 'GOOGLE_ACCESS_TOKEN'

// Example stored values
localStorage.getItem('access_token')  
// → "eyJ0eXAiOiJKV1QiLCJhbGciOiJIUzI1NiJ9..."

localStorage.getItem('user_data')
// → '{"id":"507f...", "email":"user@test.com", "role":"freelancer", ...}'

localStorage.getItem('profile_completed')
// → "true" or "false" (string, not boolean)
```

### Context Usage

```typescript
// In any component
const { user, isAuthenticated, login, logout } = useAuth()

// Check auth
if (!isAuthenticated) {
  return <Redirect to="/login" />
}

// Access user info
console.log(user.role, user.email)

// Login
login({ email, role }, accessToken)

// Logout
logout()
```

---

## API Integration

### Axios Instance + Interceptors

```javascript
// In src/api.js
const API_BASE_URL = 'http://localhost:8000/api'
const api = axios.create({ 
  baseURL: API_BASE_URL,
  headers: { 'Content-Type': 'application/json' }
})

// Request Interceptor
api.interceptors.request.use((config) => {
  const token = localStorage.getItem('access_token')
  
  // List of public endpoints (no auth header needed)
  const publicEndpoints = [
    '/accounts/register/',
    '/accounts/token/',
    '/accounts/token/refresh/',
    'login'
  ]
  
  const isPublicEndpoint = publicEndpoints.some(endpoint => 
    config.url.includes(endpoint)
  )
  
  // Only add bearer token to protected endpoints
  if (!isPublicEndpoint && token) {
    config.headers.Authorization = `Bearer ${token}`
  }
  
  return config
})

// Response Interceptor (handles 401, token refresh)
api.interceptors.response.use(
  response => response,
  async (error) => {
    const originalRequest = error.config
    
    if (error.response?.status === 401 && !originalRequest._retry) {
      // Handle token refresh logic
      // (see Token Refresh Flow above)
    }
    
    return Promise.reject(error)
  }
)
```

### API Service Calls

```javascript
// In src/services/apiService.js

export const authAPI = {
  register: (data) => api.post('/accounts/register/', data),
  login: (email, password) => api.post('/token/', { email, password }),
  getCurrentUser: () => api.get('/accounts/user/'),
  logout: () => {
    localStorage.removeItem('access_token')
    localStorage.removeItem('refresh_token')
  }
}

export const jobsAPI = {
  getJobs: (params) => api.get('/jobs/', { params }),
  getJob: (id) => api.get(`/jobs/${id}/`),
  createJob: (data) => api.post('/jobs/', data),
  getMyJobs: () => api.get('/jobs/my-jobs/'),
  getJobApplications: (id) => api.get(`/jobs/${id}/applications/`)
}

export const proposalsAPI = {
  submitProposal: (data) => api.post('/proposals/', data),
  getProposals: () => api.get('/proposals/'),
  acceptProposal: (id) => api.post(`/proposals/${id}/accept/`),
  rejectProposal: (id) => api.post(`/proposals/${id}/reject/`)
}

// Usage in components
const { data: jobs } = await jobsAPI.getJobs({ category: 'Web Design' })
```

---

## Component Workflows

### Job Browsing (Freelancer)

```
/freelancer/jobs
├─ Jobs Page Component
│  ├─ useState:
│  │  ├─ jobs: Job[]
│  │  ├─ loading: boolean
│  │  ├─ filters: { category, minBudget, maxBudget }
│  │  └─ selectedJob: Job | null
│  │
│  ├─ useEffect: fetchJobs()
│  │  ├─ Call jobsAPI.getJobs(filters)
│  │  ├─ Set loading = true → false
│  │  ├─ Update jobs state
│  │  └─ Handle errors
│  │
│  ├─ Layout:
│  │  ├─ Left: JobFilters Component
│  │  │  ├─ Filter inputs: category, budget range
│  │  │  ├─ onChange → update filters state
│  │  │  └─ Triggers new fetch
│  │  │
│  │  ├─ Center: JobList Component
│  │  │  ├─ Map jobs: JobCard component
│  │  │  ├─ JobCard shows:
│  │  │  │  ├─ Title, description snippet
│  │  │  │  ├─ Budget range, experience level
│  │  │  │  ├─ Client company name
│  │  │  │  ├─ Proposal count, views
│  │  │  │  └─ Click → open right panel
│  │  │  │
│  │  │  └─ Loading skeleton if loading
│  │  │
│  │  └─ Right: JobDetail + ApplyForm Component
│  │     ├─ Show selected job full details
│  │     ├─ ApplyJobForm Component:
│  │     │  ├─ Form fields:
│  │     │  │  ├─ Cover letter (textarea)
│  │     │  │  ├─ Proposed amount (number)
│  │     │  │  └─ Timeline (text)
│  │     │  │
│  │     │  ├─ onSubmit:
│  │     │  │  ├─ Payload: { job_id, cover_letter, proposed_amount, proposed_timeline }
│  │     │  │  ├─ POST /proposals/
│  │     │  │  ├─ Show success message
│  │     │  │  ├─ Update jobs/proposals in UX
│  │     │  │  └─ Close form
│  │     │  │
│  │     │  └─ Error handling: Show error toast
│  │     │
│  │     └─ Only show if user is freelancer + job is open
│  │
│  └─ Empty state if no jobs found
```

### Job Creation (Client)

```
/client/post-job
├─ JobForm Page Component
│  ├─ Form fields:
│  │  ├─ Title (text, required)
│  │  ├─ Description (textarea, required)
│  │  ├─ Category (select dropdown)
│  │  ├─ Budget Type (radio: fixed | hourly)
│  │  ├─ Budget Min (number, required)
│  │  ├─ Budget Max (number, required)
│  │  ├─ Hourly Rate (number, conditional)
│  │  ├─ Duration (select: short/medium/long)
│  │  ├─ Required Skills (tags input)
│  │  ├─ Experience Level (select: beginner/intermediate/expert)
│  │  ├─ Deadline (datetime picker, optional)
│  │  └─ Featured Checkbox (optional)
│  │
│  ├─ onSubmit Handler:
│  │  ├─ Validation:
│  │  │  ├─ All required fields filled
│  │  │  ├─ Budget min < max
│  │  │  ├─ Deadline in future (if set)
│  │  │  └─ Skills array non-empty
│  │  │
│  │  ├─ Payload:
│  │  │  {
│  │  │    title, description, category,
│  │  │    budget_type, budget_min, budget_max,
│  │  │    hourly_rate, duration, required_skills,
│  │  │    experience_level, deadline, is_featured
│  │  │  }
│  │  │
│  │  ├─ POST /jobs/
│  │  ├─ Success: Redirect to /client/jobs
│  │  └─ Error: Show field-level errors
│  │
│  └─ Preview Toggle: Show job as freelancer would see it
└─ Linked from /client/dashboard
```

### Proposal Management (Client)

```
/client/proposals
├─ Proposals Page Component
│  ├─ useState:
│  │  ├─ proposals: Proposal[]
│  │  ├─ loading: boolean
│  │  └─ selectedProposal: Proposal | null
│  │
│  ├─ useEffect: fetchProposals()
│  │  ├─ Call proposalsAPI.getProposals()
│  │  └─ Set proposals state
│  │
│  ├─ Layout:
│  │  ├─ ProposalList:
│  │  │  ├─ Group by job
│  │  │  ├─ ProposalCard shows:
│  │  │  │  ├─ Freelancer name, rating, skills
│  │  │  │  ├─ Proposed amount, timeline
│  │  │  │  ├─ Cover letter preview
│  │  │  │  ├─ Proposal status badge
│  │  │  │  └─ Click to open detail
│  │  │  │
│  │  │  └─ Filter tabs: All, Pending, Accepted, Rejected
│  │  │
│  │  └─ ProposalDetail (right panel):
│  │     ├─ Full proposal information
│  │     ├─ Freelancer Profile Card:
│  │     │  ├─ Name, rating, verified badge
│  │     │  ├─ Skills list
│  │     │  ├─ Jobs completed
│  │     │  └─ "View Profile" link
│  │     │
│  │     ├─ ProposalActions (conditional on status):
│  │     │  ├─ If pending:
│  │     │  │  ├─ "Accept" button → POST /proposals/{id}/accept/
│  │     │  │  │  ├─ Payload: {}
│  │     │  │  │  ├─ Updates proposal.status = 'hired'
│  │     │  │  │  ├─ Rejects other proposals
│  │     │  │  │  └─ Updates job.status = 'hired'
│  │     │  │  │
│  │     │  │  ├─ "Reject" button → POST /proposals/{id}/reject/
│  │     │  │  │  └─ Updates proposal.status = 'rejected'
│  │     │  │  │
│  │     │  │  └─ Modal confirmation before accept
│  │     │  │
│  │     │  └─ If hired:
│  │     │     ├─ "Hired" badge
│  │     │     ├─ "Start Chat" button → /client/chat
│  │     │     └─ "Make Payment" button → /client/payments
│  │     │
│  │     └─ Timestamps & metadata
│  │
│  └─ Empty state if no proposals
```

### Chat System (Both Roles)

```
/client/chat or /freelancer/chat
├─ Chat Page Component
│  ├─ useState:
│  │  ├─ conversations: Conversation[]
│  │  ├─ selectedConversation: Conversation | null
│  │  ├─ messages: Message[]
│  │  └─ messageText: string
│  │
│  ├─ useEffect: fetchConversations()
│  │  ├─ Call chatAPI.getConversations()
│  │  └─ Set conversations state
│  │
│  ├─ Layout:
│  │  ├─ Left: ConversationList
│  │  │  ├─ Map conversations: ConversationItem
│  │  │  ├─ Click → set selectedConversation
│  │  │  ├─ Show unread count badge
│  │  │  ├─ Show last message snippet
│  │  │  ├─ Show last_updated timestamp
│  │  │  └─ "New Conversation" button → StartChat modal
│  │  │
│  │  ├─ Right: MessageThread
│  │  │  ├─ useEffect: fetchMessages(selectedConversation.id)
│  │  │  │  ├─ Scroll to bottom
│  │  │  │  └─ Auto-refresh on interval
│  │  │  │
│  │  │  ├─ MessageBubbles:
│  │  │  │  ├─ Group by sender
│  │  │  │  ├─ Show timestamp
│  │  │  │  ├─ Show read status
│  │  │  │  ├─ Left align if other user
│  │  │  │  └─ Right align if current user
│  │  │  │
│  │  │  └─ MessageInput at bottom:
│  │  │     ├─ Textarea for message
│  │  │     ├─ Send button
│  │  │     ├─ onSubmit:
│  │  │     │  ├─ Validation: message non-empty
│  │  │     │  ├─ POST /chat/messages/
│  │  │     │  ├─ Payload: { conversation_id, content }
│  │  │     │  ├─ Clear input
│  │  │     │  ├─ Append to messages
│  │  │     │  └─ Scroll to bottom
│  │  │     │
│  │  │     └─ Error handling: Show toast
│  │  │
│  │  └─ Empty state if no conversation selected
│  │
│  └─ StartChat Modal:
│     ├─ Input: Email of other user
│     ├─ onSubmit:
│     │  ├─ POST /chat/conversations/
│     │  ├─ Payload: { participant_email }
│     │  ├─ Backend checks: Users have hired proposal
│     │  ├─ Create OR return existing conversation
│     │  ├─ Close modal
│     │  └─ Open conversation in main panel
│     │
│     └─ Error: "Chat only available after hiring"
```

### Payment Flow (Client)

```
/client/payments
├─ Payments Page Component
│  ├─ useState:
│  │  ├─ transactions: Transaction[]
│  │  ├─ loading: boolean
│  │  └─ showPaymentForm: boolean
│  │
│  ├─ Layout (tabs):
│  │  │
│  │  ├─ Tab 1: Transactions
│  │  │  ├─ TransactionList:
│  │  │  │  ├─ Map transactions: TransactionCard
│  │  │  │  ├─ Show: Amount, status, freelancer, date
│  │  │  │  ├─ Color code by status:
│  │  │  │  │  ├─ pending → yellow
│  │  │  │  │  ├─ completed → green
│  │  │  │  │  └─ failed → red
│  │  │  │  ├─ Click → TransactionDetail modal
│  │  │  │  └─ Filter tabs: All, Pending, Completed
│  │  │  │
│  │  │  └─ Empty state if no transactions
│  │  │
│  │  ├─ Tab 2: Payment Form
│  │  │  ├─ New Payment Button (from /client/proposals):
│  │  │  │  ├─ Select proposal (dropdown)
│  │  │  │  ├─ Show proposed amount (read-only)
│  │  │  │  ├─ Show freelancer info
│  │  │  │  ├─ Select payment method (radio):
│  │  │  │  │  ├─ Stripe
│  │  │  │  │  ├─ Razorpay
│  │  │  │  │  └─ Bank Transfer
│  │  │  │  │
│  │  │  │  ├─ onSubmit:
│  │  │  │  │  ├─ Validation: proposal selected
│  │  │  │  │  ├─ Check: proposal.status == 'hired'
│  │  │  │  │  ├─ POST /payments/transactions/create_payment/
│  │  │  │  │  ├─ Payload: { proposal_id, payment_method }
│  │  │  │  │  ├─ Response: Transaction with stripe/razorpay link
│  │  │  │  │  ├─ Redirect to payment gateway (external)
│  │  │  │  │  │  ├─ User completes payment
│  │  │  │  │  │  └─ Redirected back to app
│  │  │  │  │  │
│  │  │  │  │  ├─ Confirm Payment:
│  │  │  │  │  │  ├─ POST /payments/transactions/{id}/confirm_payment/
│  │  │  │  │  │  └─ Update transaction.status = 'completed'
│  │  │  │  │  │
│  │  │  │  │  └─ Show success message
│  │  │  │  │
│  │  │  │  └─ Error: Show error toast
│  │  │  │
│  │  │  └─ Breakdown:
│  │  │     ├─ Gross Amount: $1200
│  │  │     ├─ Platform Fee (10%): -$120
│  │  │     └─ Freelancer Receives: $1080
│  │  │
│  │  └─ Tab 3: Invoices
│  │     ├─ List past invoices
│  │     ├─ Download as PDF
│  │     └─ View/print
│  │
│  └─ Transaction Detail Modal:
│     ├─ Full information
│     ├─ Linked proposal details
│     ├─ Release countdown if pending
│     ├─ Release Payment button (if time passed)
│     └─ Generate invoice option
```

### Profile Setup (Both Roles)

```
/freelancer/profile/edit
├─ ProfileEditForm Component
│  ├─ Initial load: Fetch user profile from GET /api/accounts/user/
│  │
│  ├─ Form fields:
│  │  ├─ Full Name (freelancer)
│  │  ├─ Title (freelancer only)
│  │  ├─ Bio (textarea)
│  │  ├─ Skills (tags input with autocomplete)
│  │  ├─ Hourly Rate (number, freelancer)
│  │  ├─ Portfolio Links (URL array)
│  │  ├─ Experience Summary (textarea)
│  │  ├─ Education/Certifications
│  │  ├─ Languages
│  │  ├─ Availability (select)
│  │  └─ ProfileCompletionBar:
│  │     ├─ Shows percentage (0-100%)
│  │     ├─ Checklist:
│  │     │  ├─ ☐ Profile photo
│  │     │  ├─ ☐ Complete bio
│  │     │  ├─ ☐ Add 3+ skills
│  │     │  ├─ ☐ Set hourly rate
│  │     │  ├─ ☐ Verified email
│  │     │  └─ ☐ Phone number
│  │     │
│  │     └─ Update localStorage: profile_completed = true (when 100%)
│  │
│  ├─ onSubmit Handler:
│  │  ├─ PUT /api/accounts/user/
│  │  ├─ Payload: { full_name, bio, skills, hourly_rate, ... }
│  │  ├─ Response: Updated user object
│  │  ├─ Update auth context
│  │  ├─ Show success toast
│  │  └─ Redirect on completion
│  │
│  └─ Error: Show validation errors
```

---

## Page Structures

### Public Pages
- `/` - Home/landing page
- `/login` - Email/password login
- `/register` - Role selection
- `/register/client` - Client signup
- `/register/freelancer` - Freelancer signup with face capture

### Protected Client Routes
```
/client/
├─ /dashboard - Overview & stats
├─ /post-job - Create job form
├─ /jobs - My jobs list
├─ /proposals - Received proposals
├─ /hire - Hiring management & contracts
├─ /payments - Transaction history & payment form
├─ /chat - Messages with freelancers
└─ /profile/edit - Client profile settings
```

### Protected Freelancer Routes
```
/freelancer/
├─ /dashboard - Overview & earnings
├─ /jobs - Browse & search jobs
├─ /proposals - My proposals/bids
├─ /payments - Earnings & payout requests
├─ /chat - Messages with clients
└─ /profile/edit - Skills, bio, rate settings
```

---

## User Journeys

### Complete Freelancer Journey

```
1. SIGNUP
   → /register/freelancer
   → Capture face photo
   → POST /api/accounts/register/
   → Auto-login & redirect

2. PROFILE SETUP
   → Redirect to /freelancer/profile/edit
   → Fill full_name, bio, skills, hourly_rate
   → Complete profile checklist (100%)
   → localStorage: profile_completed = true

3. JOB BROWSING
   → Click /freelancer/jobs
   → View job list with filters
   → Click job → see full details
   → Click "Apply" → submit proposal

4. PROPOSAL MANAGEMENT
   → /freelancer/proposals
   → View "My Proposals" (sent proposals)
   → See status: pending, hired, rejected

5. ACCEPTANCE → CHAT
   → Client accepts proposal → status = 'hired'
   → Can now start chat
   → /freelancer/chat → "New Conversation"
   → Enter client email → Create conversation

6. PAYMENT RECEIPT
   → Client initiates payment
   → Transaction shows in /freelancer/payments
   → Wait 7 days hold period
   → Client releases payment
   → Freelancer receives notification

7. COMPLETION
   → Job marked complete
   → Review exchange
   → Rating updated
```

### Complete Client Journey

```
1. SIGNUP
   → /register/client
   → Enter company name
   → POST /api/accounts/register/
   → Auto-login & redirect

2. PROFILE SETUP
   → /client/profile/edit
   → Fill company info, description
   → Set payment method preferences

3. JOB POSTING
   → /client/post-job
   → Fill job details (title, description, budget, etc.)
   → POST /jobs/
   → Job status = 'open'

4. PROPOSAL REVIEW
   → /client/proposals
   → Review incoming proposals
   → See freelancer profiles
   → Accept favorite → status = 'hired'
   → Auto-rejects other proposals

5. COMMUNICATION
   → /client/chat
   → "New Conversation" → Enter freelancer email
   → Requirement: Both must have hired proposal
   → Send messages, attach files

6. PAYMENT
   → /client/payments
   → "New Payment" → Select proposal
   → Choose payment method
   → Process payment → Stripe/Razorpay
   → Confirm after payment gateway
   → Hold 7 days, then manually release

7. COMPLETION
   → Mark job complete
   → Leave review/rating
   → Proposal marked completed
   → Freelancer profile updated
```

---

## Error Handling

### API Error Responses

```javascript
// In axios interceptor
error.response?.data = {
  // Format 1: Field errors (registration)
  email: ["This email is already registered."],
  face_image: ["Face matching detected."],
  
  // Format 2: General error
  detail: "Invalid credentials",
  message: "Job not found",
  
  // Format 3: Non-field errors
  non_field_errors: ["Error message"]
}
```

### Error Display Strategy

```typescript
// Try multiple error sources in order
const getErrorMessage = (error) => {
  return (
    error?.response?.data?.detail ||
    error?.response?.data?.message ||
    error?.response?.data?.email?.[0] ||
    error?.response?.data?.face_image?.[0] ||
    error?.response?.data?.full_name?.[0] ||
    `Error (${error?.response?.status})`
  )
}

// Display in UI
{error && (
  <Alert variant="destructive">
    {getErrorMessage(error)}
  </Alert>
)}
```

### User Feedback

- **Success**: Toast notification (green) "Profile updated"
- **Error**: Toast notification (red) + field highlighting
- **Loading**: Skeleton loaders / spinner
- **No Data**: Empty state with illustration + call-to-action

---

## Performance Considerations

### Code Splitting
- Route-based lazy loading with `next/dynamic`
- Only load components needed for current route

### Image Optimization
- Next.js `<Image>` component for automatic optimization
- WebP conversion, responsive sizing
- Lazy loading below fold

### API Optimization
- Request deduplication (avoid duplicate API calls)
- Pagination for large lists (not yet implemented)
- Cache user data in context (avoid refetch)

### State Management
- Keep state as local as possible
- Only global auth in Context
- Use useState for component-specific data
- Avoid re-renders with React.memo for expensive components

### Bundle Size
- Tree-shaking for unused imports
- shadcn/ui imports only needed components
- Dynamic imports for modals/dialogs

---

## Development Workflow

### Local Development

```bash
# Install dependencies
cd freelance-frontend
npm install

# Set environment
cp .env.example .env.local
# Edit: NEXT_PUBLIC_API_URL=http://localhost:8000/api

# Start dev server
npm run dev
# Opens http://localhost:3000

# Build for production
npm run build
npm start
```

### Testing Auth Flow

```bash
# Register test user
POST http://localhost:3000/register/client
// Fill form, submit

// Login
POST http://localhost:3000/login
email: test@example.com
password: yourpassword

// Check localStorage
console.log(localStorage.getItem('access_token'))
console.log(JSON.parse(localStorage.getItem('user_data')))
```

### Browser DevTools
- **Redux DevTools**: Not used (using Context instead)
- **Network Tab**: Monitor API calls
- **Application Tab**: View localStorage tokens
- **Console**: Check for errors/warnings

---

**Last Updated**: March 24, 2026  
**Maintainer**: Development Team
