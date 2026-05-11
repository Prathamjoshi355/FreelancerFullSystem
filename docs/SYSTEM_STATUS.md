# Freelancer Platform - Quick Reference & Troubleshooting

## ✅ Pre-Launch Checklist

### Backend Setup
- [ ] MongoDB running on localhost:27017
- [ ] Django migrations applied: `python manage.py migrate --run-syncdb`
- [ ] Backend starting: `python manage.py runserver`
- [ ] All API endpoints responding
- [ ] CORS enabled for frontend access

### Frontend Setup
- [ ] Dependencies installed: `npm install`
- [ ] Environment variables configured (.env.local if needed)
- [ ] Frontend starting: `npm run dev`
- [ ] Backend URL correct in code (localhost:8000)
- [ ] Frontend accessible on localhost:3001

### Database Setup
- [ ] MongoDB collections created
- [ ] Indexes setup for faster queries
- [ ] Backup configured (optional)

---

## 🚀 Startup Commands

```bash
# Terminal 1: Backend
cd c:\Users\prath\Downloads\freelance-frontend\freelancerbackend
python manage.py runserver

# Terminal 2: Frontend
cd c:\Users\prath\Downloads\freelance-frontend
npm run dev

# Terminal 3: Run E2E Tests (after both services running)
python c:\Users\prath\Downloads\freelance-frontend\test_e2e.py
```

---

## 📱 User Journey Paths

### Freelancer Path
```
/register/freelancer 
  ↓
/login 
  ↓
/freelancer/profile/edit (MANDATORY - Can't skip)
  ↓
/freelancer/dashboard
  ↓
/freelancer/skills/test/[skill] (Optional but recommended)
  ↓
/freelancer/browse-jobs
```

### Client Path
```
/register/client
  ↓
/login
  ↓
/client/profile/edit (MANDATORY - Can't skip)
  ↓
/client/dashboard
  ↓
/client/post-job or /client/hire
```

---

## 🔑 Key URLs

### Frontend
- **Login**: http://localhost:3001/login
- **Register (Freelancer)**: http://localhost:3001/register/freelancer
- **Register (Client)**: http://localhost:3001/register/client
- **Freelancer Dashboard**: http://localhost:3001/freelancer/dashboard
- **Client Dashboard**: http://localhost:3001/client/dashboard
- **Skill Tests**: http://localhost:3001/freelancer/skills/test/[javascript|react|python|ui-design]

### Backend APIs
- **Register**: POST http://localhost:8000/api/accounts/register/
- **Login**: POST http://localhost:8000/api/token/
- **User Info**: GET http://localhost:8000/api/accounts/user/
- **Profile**: GET/POST/PUT http://localhost:8000/api/profiles/me/
- **Skill Tests**: GET/POST http://localhost:8000/api/profiles/tests/
- **Specific Test**: GET http://localhost:8000/api/profiles/tests/{skill}/

---

## 🧪 Test Scenarios

### Scenario 1: Complete Freelancer Flow
1. Register new freelancer account
2. Login with credentials
3. Get redirected to profile edit (automatic)
4. Fill in bio, skills, hourly rate
5. Submit → redirected to dashboard
6. Click "Take Test" for JavaScript
7. Answer questions → Submit score
8. See test result and badge

### Scenario 2: Complete Client Flow
1. Register new client account
2. Login with credentials
3. Get redirected to profile edit (automatic)
4. Fill in company name, description
5. Submit → redirected to dashboard
6. Click "Post Job"
7. Fill job details and submit
8. See job listed

### Scenario 3: Authentication Persistence
1. Register and login
2. Close browser tab
3. Reopen http://localhost:3001/freelancer/dashboard
4. Should still be logged in (localStorage tokens)
5. Click logout
6. Redirected to login page
7. Try accessing dashboard → redirected to login

### Scenario 4: Profile Completion Gate
1. Register freelancer
2. Login successfully
3. Try accessing /freelancer/dashboard directly
4. Should redirect to /freelancer/profile/edit
5. Can't bypass profile completion
6. Complete profile → now can access dashboard

---

## 🐛 Common Issues & Solutions

### Issue: "404 Not Found" on Login
**Cause**: Backend not running or wrong URL
**Fix**: 
```bash
# Check backend is running
cd freelancerbackend
python manage.py runserver

# Verify URL in login form: http://localhost:8000/api/token/
```

### Issue: "JSON Parse Error" on Login
**Cause**: Backend returning HTML error instead of JSON
**Fix**:
```bash
# Check MongoDB is running
# Verify Django models are migrated
python manage.py migrate --run-syncdb

# Check backend logs for errors
python manage.py runserver
```

### Issue: Profile Edit Redirects to Login
**Cause**: Auth token expired or invalid
**Fix**:
```bash
# Clear browser localStorage
# Dev Tools → Application → Storage → Clear Site Data

# Login again with fresh token
```

### Issue: Skill Test Won't Submit
**Cause**: Token expired or profile not completed
**Fix**:
```bash
# Verify profile_completed flag in localStorage
# Should be: profile_completed = "true"

# If not set, complete profile first
```

### Issue: MongoDB Connection Error
**Cause**: MongoDB not running
**Fix**:
```bash
# Start MongoDB
# Windows: mongod --dbpath C:\mongodb-data

# Check connection in Django settings
# Should be: mongodb+srv://user:pass@host/ or mongodb://localhost:27017/
```

### Issue: "CORS Error" from Frontend
**Cause**: Backend doesn't allow frontend origin
**Fix**:
```python
# In freelancerbackend/FreelancerBackend/settings.py

CORS_ALLOWED_ORIGINS = [
    "http://localhost:3001",
    "http://localhost:3000",
    "http://127.0.0.1:3001",
]
```

### Issue: Tests Dashboard Empty
**Cause**: Need to complete profile and take tests first
**Fix**:
```bash
# 1. Complete profile at /freelancer/profile/edit
# 2. From dashboard, click "Take Test" for any skill
# 3. Complete the quiz
# 4. After submission, test appears on dashboard
```

---

## 📊 Data Verification

### Check User Created in MongoDB
```javascript
// MongoDB Shell
use freelancer_db
db.custom_users.findOne({email: "test@example.com"})
```

### Check Profile Created
```javascript
db.profiles.findOne({user_id: ObjectId("...")})
```

### Check Skill Tests
```javascript
db.skill_tests.find({user_id: ObjectId("...")})
```

---

## 🔐 Headers Required for API Calls

```javascript
// All authenticated requests need:
headers: {
  "Authorization": "Bearer {access_token}",
  "Content-Type": "application/json"
}

// Example:
fetch("http://localhost:8000/api/profiles/me/", {
  method: "GET",
  headers: {
    "Authorization": `Bearer ${localStorage.getItem("access_token")}`,
    "Content-Type": "application/json"
  }
})
```

---

## 💾 localStorage Keys

After login, these are stored:
```javascript
localStorage.getItem("access_token")          // JWT token for API calls
localStorage.getItem("refresh_token")         // Refresh token for new access
localStorage.getItem("user_data")            // User object as JSON
localStorage.getItem("profile_completed")    // "true" or "false"
```

---

## 🎯 Testing Credentials

Create test users during E2E test:
```bash
python test_e2e.py
```

Or manually register:
- Email: test@example.com
- Password: TestPass123!
- Full Name: Test User
- Role: freelancer or client

---

## 📈 Performance Optimization Tips

1. **Frontend Caching**
   - Profile data cached in AuthContext
   - Reduces API calls on dashboard refresh

2. **Backend Optimization**
   - User queries indexed by email
   - Profile queries indexed by user_id
   - Skill tests indexed for fast lookup

3. **Database Optimization**
   - MongoDB indexes set on common fields
   - Connection pooling enabled
   - Query results paginated

---

## 🔄 Development Workflow

### Making Code Changes

1. **Backend Changes**
   ```bash
   # Edit files in freelancerbackend/
   # Django will auto-reload on save
   # Changes take effect immediately
   ```

2. **Frontend Changes**
   ```bash
   # Edit files in src/
   # Next.js will rebuild on save
   # Changes visible after page refresh
   ```

3. **Database Changes**
   ```bash
   # Edit models.py
   # Run migrations:
   python manage.py makemigrations
   python manage.py migrate --run-syncdb
   ```

---

## 📝 File Locations Reference

```
c:\Users\prath\Downloads\freelance-frontend\
├── Frontend Source
│   ├── src/app/              # Pages
│   ├── src/components/       # Components
│   ├── src/context/          # Auth Context
│   └── src/hooks/             # Custom hooks
│
├── Backend Source
│   └── freelancerbackend/
│       ├── accounts/         # Auth app
│       ├── profiles/         # Profile app
│       ├── FreelancerBackend/ # Settings
│       └── manage.py         # Django CLI
│
├── Documentation
│   ├── COMPLETE_SETUP_GUIDE.md
│   └── SYSTEM_STATUS.md (this file)
│
└── Testing
    ├── test_e2e.py          # E2E test script
    └── build_output.txt     # Build logs
```

---

## 🚨 Emergency Reset

If something goes wrong and you need a clean slate:

```bash
# 1. Stop all services (Ctrl+C in terminals)

# 2. Clear frontend cache
rm -r c:\Users\prath\Downloads\freelance-frontend\.next
rm -r c:\Users\prath\Downloads\freelance-frontend\node_modules

# 3. Clear browser data
# Dev Tools → Application → Storage → Clear Site Data

# 4. Clear MongoDB (CAREFUL - deletes all data!)
# MongoDB Shell:
use freelancer_db
db.custom_users.deleteMany({})
db.profiles.deleteMany({})
db.skill_tests.deleteMany({})

# 5. Reinstall and restart
cd c:\Users\prath\Downloads\freelance-frontend
npm install
npm run dev

cd freelancerbackend
python manage.py migrate --run-syncdb
python manage.py runserver
```

---

## ✨ System Status Checks

Run this before reporting issues:

```bash
# 1. Check backend is responding
curl http://localhost:8000/api/accounts/user/

# 2. Check MongoDB connection
mongosh --eval "db.version()"

# 3. Check frontend is building
cd freelance-frontend
npm run build
```

---

## 📞 Support & Debugging

### Enable Debug Logging

**Frontend**:
```javascript
// Add to .env.local
NEXT_PUBLIC_DEBUG=true
```

**Backend**:
```python
# settings.py - set DEBUG
DEBUG = True
```

### Check Logs

**Frontend**: Browser Console (F12)
**Backend**: Terminal output
**Database**: MongoDB logs

---

## 🎓 Learning Resources

- Frontend: [Next.js Docs](https://nextjs.org/docs)
- Backend: [Django Docs](https://docs.djangoproject.com)
- Database: [MongoDB Docs](https://docs.mongodb.com)
- Authentication: [JWT Guide](https://jwt.io/introduction)

---

## 📅 Next Phase To-Do

- [ ] Job posting system backend
- [ ] Job browsing UI
- [ ] Proposal management
- [ ] Chat/messaging system
- [ ] Payment integration
- [ ] Rating system
- [ ] Search/filtering
- [ ] Mobile app
- [ ] Analytics dashboard
- [ ] Admin panel

---

**Last Updated**: After backend integration complete
**System Status**: ✅ Ready for end-to-end testing
**All 3 Components**: ✅ Integrated and functional
