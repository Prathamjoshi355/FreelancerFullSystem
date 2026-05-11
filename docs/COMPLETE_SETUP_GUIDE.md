# Complete Frontend-Backend Integration Setup

## System Architecture

```
Frontend (Next.js 15) - Port 3001
├── AuthContext (Profile Tracking)
├── ProtectedRoute (Authentication Guard)
├── Registration Pages
│   ├── Freelancer Registration
│   └── Client Registration
├── Profile Completion
│   ├── Freelancer Profile Edit
│   └── Client Profile Edit
├── Freelancer Dashboard
│   ├── Skill Tests(JavaScript, React, Python, UI Design)
│   └── Profile Management
└── Client Dashboard
    ├── Post Jobs
    ├── Browse Proposals
    └── Find Freelancers

Backend (Django 4.2) - Port 8000
├── Accounts App
│   ├── User Registration (freelancer/client)
│   ├── JWT Token Generation
│   └── User Management
├── Profiles App
│   ├── Profile CRUD
│   └── Skill Tests Management
├── Jobs App
├── Proposals App
├── Payments App
└── Chat & Notifications

Database (MongoDB) - Port 27017
├── CustomUser Collection
├── Profile Collection
├── SkillTest Collection
├── Jobs Collection
├── Proposals Collection
└── Transactions Collection
```

## Setup Steps

### 1. Start Backend (Django)

```bash
cd c:\Users\prath\Downloads\freelance-frontend\freelancerbackend
python manage.py migrate --run-syncdb
python manage.py runserver
```

The backend will run on: http://localhost:8000

### 2. Start Frontend (Next.js)

```bash
cd c:\Users\prath\Downloads\freelance-frontend
npm run dev
```

The frontend will run on: http://localhost:3001

### 3. Verify MongoDB Connection

MongoDB should be running on: http://localhost:27017

## User Flow

### Freelancer Registration & Setup

1. **Register** → `/register/freelancer`
   - Email, Password, Full Name
   - Role: Freelancer
   - ✅ Backend: Stores in MongoDB
   - ✅ Frontend: Saves JWT tokens

2. **Complete Profile** → `/freelancer/profile/edit`
   - Bio, Skills (comma-separated), Hourly Rate
   - Phone, City, Country (optional)
   - ✅ Backend: Updates Profile collection
   - ✅ Marks `profile_completed = true`

3. **Verify Skills** → `/freelancer/dashboard`
   - Available tests: JavaScript, React, Python, UI Design
   - Click "Take Test" for any skill
   - ✅ 3  questions per test, 70% pass required
   - ✅ Backend: Stores SkillTest with score

4. **Access Dashboard** → `/freelancer/dashboard`
   - View earned badges
   - Browse jobs
   - Manage proposals

### Client Registration & Setup

1. **Register** → `/register/client`
   - Email, Password, Company Name
   - Role: Client
   - ✅ Backend: Stores in MongoDB

2. **Complete Profile** → `/client/profile/edit`
   - Company info, Logo, Description
   - Contact details
   - ✅ Backend: Updates Profile collection

3. **Access Dashboard** → `/client/dashboard`
   - Post jobs
   - Browse proposals
   - Manage projects

## API Endpoints

### Authentication
```
POST /api/accounts/register/
  - Request: { email, password, full_name/company_name, role }
  - Response: 201 { user, access, refresh }

POST /api/token/
  - Request: { email, password }
  - Response: 200 { access, refresh, user }

POST /api/token/refresh/
  - Request: { refresh }
  - Response: 200 { access }

GET /api/accounts/user/
  - Headers: Authorization: Bearer {token}
  - Response: 200 { email, role, full_name/company_name, ... }
```

### Profile Management
```
GET /api/profiles/me/
  - Headers: Authorization: Bearer {token}
  - Response: 200 { id, bio, skills, hourly_rate, profile_completed, ... }

POST /api/profiles/me/
  - Headers: Authorization: Bearer {token}
  - Request: { bio, skills[], hourly_rate, phone, city, country }
  - Response: 201 { message, ...profile_data }

PUT /api/profiles/me/
  - Headers: Authorization: Bearer {token}
  - Request: { bio, skills[], hourly_rate, ... }
  - Response: 200 { message, ...profile_data }
```

### Skill Tests
```
GET /api/profiles/tests/
  - Headers: Authorization: Bearer {token}
  - Response: 200 [ { skill, score, passed, completed_at, ... } ]

GET /api/profiles/tests/{skill}/
  - Headers: Authorization: Bearer {token}
  - Response: 200 { skill, score, passed, completed_at }

POST /api/profiles/tests/
  - Headers: Authorization: Bearer {token}
  - Request: { skill, score }
  - Response: 201 { message, skill, score, passed }
```

## Frontend Components & Pages

### Auth Pages
- `/login` - Login form
- `/register/freelancer` - Freelancer registration
- `/register/client` - Client registration

### Freelancer Pages
- `/freelancer/profile/edit` - Profile completion (redirects here after login if not completed)
- `/freelancer/dashboard` - Main dashboard with skill tests
- `/freelancer/skills/test/[skill]` - Skill test interface
- `/freelancer/browse-jobs` - Job listing
- `/freelancer/proposals` - My proposals

### Client Pages
- `/client/profile/edit` - Profile completion
- `/client/dashboard` - Main dashboard
- `/client/post-job` - Create job posting
- `/client/proposals` - Manage proposals
- `/client/hire` - Find freelancers

## Authentication Flow

```
1. User registers → Backend creates CustomUser in MongoDB
2. User logs in → Backend validates + returns JWT tokens
3. Frontend stores tokens in localStorage
4. Frontend checks profile_completed flag
5. If not completed → Redirect to /[role]/profile/edit
6. After profile completion → Redirect to /[role]/dashboard
7. All API calls include: Authorization: Bearer {token}
8. Protected routes checked via ProtectedRoute component
```

## Error Handling

### Login Errors
- ✅ Invalid email/password → 401 Unauthorized
- ✅ Network errors → User-friendly message
- ✅ JSON parsing errors → Fixed (now handles HTML responses)

### Profile Errors
- ✅ Missing required fields → 400 Bad Request
- ✅ Profile already exists → 400 Bad Request
- ✅ Not authenticated → 401 Unauthorized

## Testing the Full Flow

### Manual Testing Steps

1. **Start services**
   ```bash
   # Terminal 1
   cd freelancerbackend && python manage.py runserver

   # Terminal 2
   cd freelance-frontend && npm run dev
   ```

2. **Register as Freelancer**
   - Visit http://localhost:3001/register/freelancer
   - Email: john@test.com
   - Password: TestPass123!
   - Full Name: John Doe
   - Submit
   - ✅ Should redirect to profile edit page

3. **Complete Profile**
   - Fill Bio, Skills, Hourly Rate
   - Fill optional fields
   - Submit
   - ✅ Should show success and redirect to dashboard

4. **Verify Skills**
   - Click "Take Test" on JavaScript
   - Answer questions (70%+ required to pass)
   - Submit
   - ✅ Should show score and badge

5. **Test Client Flow**
   - Logout and register as client
   - Complete company profile
   - Access dashboard
   - ✅ Should see different interface

## Key Features Implemented

✅ **Profile Completion Flow**
- After login, redirects to profile edit if not completed
- Won't allow access to dashboard until profile is complete

✅ **Skill-Based Tests**
- JavaScript, React, Python, UI Design tests
- Multiple choice questions
- 70% pass requirement
- Instant results with badges

✅ **Role-Based Dashboards**
- Freelancer: Skill tests, job browse, proposals
- Client: Job posting, proposal management, talent search

✅ **Session Management**
- JWT tokens stored in localStorage
- Auto-refresh on 401
- Logout clears all data

✅ **MongoDB Integration**
- All user data persisted
- Profile tracking
- Skill test scores

## Troubleshooting

### "404 Not Found" Error
- ✅ Check backend is running on port 8000
- ✅ Check frontend is making correct API calls
- ✅ Verify MongoDB is running

### "JSON parsing error"
- ✅ Backend must return JSON, not HTML
- ✅ Check authentication header format
- ✅ Verify CORS is enabled

### Profile not saving
- ✅ Check authorization token is valid
- ✅ Verify all required fields are filled
- ✅ Check MongoDB connection

### Test redirects not working
- ✅ Check localStorage has access_token
- ✅ Verify role-based redirect URLs
- ✅ Check AuthContext is properly initialized

## Next Steps

1. Implement job posting system
2. Add proposal management
3. Create messaging system
4. Integrate payments/Stripe
5. Add more skill tests
6. Implement rating system
7. Add search filters
8. Create mobile app
