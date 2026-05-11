# SQLite to MongoDB Migration Guide

## ✅ Completed Setup

Your Django freelancer backend has been successfully configured to use **MongoDB with MongoEngine**.

### What Was Changed:

1. **Updated `settings.py`:**
   - Removed SQLite database configuration
   - Added MongoDB connection (MongoEngine)
   - Configured to connect to `mongodb://localhost:27017`
   - Database name: `freelancer_db`

2. **Updated Models:**
   - `accounts/models.py`: Converted to MongoEngine Document
   - `profiles/models.py`: Created MongoDB Profile model

3. **Installed Packages:**
   - Django 4.2.7
   - mongoengine 0.29.3
   - pymongo 4.6.0
   - All authentication packages with correct versions

## 🚀 Getting Started

### Prerequisites:
You need **MongoDB** installed and running locally.

**Download MongoDB:**
- Windows: https://www.mongodb.com/try/download/community
- Extract and run: `mongod.exe` (or use MongoDB Atlas cloud)

### Step 1: Start MongoDB
```bash
# On Windows, if installed locally:
# Run mongod.exe from MongoDB bin folder
# OR use MongoDB Atlas (cloud)
```

### Step 2: Verify Connection
```bash
cd freelancerbackend
python manage.py shell
```

Then in Python shell:
```python
from accounts.models import CustomUser
print("MongoDB connected successfully!")
```

### Step 3: Create Initial Admin User
```bash
python manage.py shell
```

In Python shell:
```python
from accounts.models import CustomUser

admin = CustomUser(
    email="admin@freelancer.com",
    full_name="Admin",
    role="client",
    is_staff=True,
    is_superuser=True
)
admin.set_password("your_password_here")
admin.save()
print("Admin user created!")
```

### Step 4: Run Development Server
```bash
python manage.py runserver
```

## 📝 MongoDB Connection Details

**Current Configuration (via Environment Variables):**
```bash
MONGO_DB_NAME=freelancer_db
MONGO_URI=mongodb://root:rootpassword@mongodb:27017/freelancer_db?authSource=admin
```

**For Docker Setup:**
- The app connects to MongoDB using the service name `mongodb` (not `localhost`)
- Environment variables are set in `docker-compose.yml`
- Database name: `freelancer_db`
- Authentication source: `admin` (where root user is created)

**For Local Development (outside Docker):**
```bash
MONGO_DB_NAME=freelancer_db
MONGO_URI=mongodb://localhost:27017/freelancer_db
```

**For Production with Authentication:**
```bash
MONGO_URI=mongodb://username:password@host:27017/freelancer_db
```

**For MongoDB Atlas (Cloud):**
```bash
MONGO_URI=mongodb+srv://username:password@cluster.mongodb.net/freelancer_db?retryWrites=true&w=majority
```

## 🔄 Key Differences from SQLite

| Feature | SQLite | MongoDB |
|---------|--------|---------|
| Schema | Fixed schema | Flexible schema |
| Scaling | Limited | Horizontal scaling |
| Queries | SQL | MongoEngine/PyMongo |
| ACID | Limited | Full ACID (4.0+) |
| Joins | Native | References |

## 📦 Model Usage Examples

### Create a User
```python
from accounts.models import CustomUser

user = CustomUser(
    email="john@example.com",
    full_name="John Doe",
    role="freelancer"
)
user.set_password("password123")
user.save()
```

### Create a Profile
```python
from accounts.models import CustomUser
from profiles.models import Profile

user = CustomUser.objects.get(email="john@example.com")

profile = Profile(
    user_id=user,
    bio="Experienced web developer",
    skills=["Python", "Django", "React"],
    hourly_rate=50.0
)
profile.save()
```

### Query Users
```python
# Find by email
user = CustomUser.objects.get(email="john@example.com")

# Find all freelancers
freelancers = CustomUser.objects(role="freelancer")

# Update user
user.full_name = "Jane Doe"
user.save()

# Delete user
user.delete()
```

## 🔧 Updating Your Existing API

No major changes needed! Your serializers will work the same way:

```python
from rest_framework import serializers
from accounts.models import CustomUser

class UserSerializer(serializers.ModelSerializer):
    class Meta:
        model = CustomUser
        fields = ['id', 'email', 'full_name', 'role']
```

## ⚠️ Important Notes

1. **No Migrations Needed**: MongoEngine doesn't use Django migrations
2. **No Admin Panel**: Django admin won't work with MongoEngine (it needs SQL)
3. **Reset Database**: 
   ```bash
   python manage.py shell
   ```
   Then:
   ```python
   from mongoengine import disconnect
   from accounts.models import CustomUser
   from profiles.models import Profile
   
   # Drop collections
   CustomUser.drop_collection()
   Profile.drop_collection()
   print("Collections dropped!")
   ```

## 📊 Monitoring MongoDB

Use **MongoDB Compass** (GUI) or **mongosh** (CLI):
```bash
# View databases
show dbs

# Use freelancer_db
use freelancer_db

# View collections
show collections

# Query data
db.custom_users.find()
db.profiles.find()
```

## 🆘 Troubleshooting

### Connection Error
- Ensure MongoDB is running (`mongod`)
- Check if port 27017 is open
- Verify `MONGO_URI` in settings.py

### Import Error
```bash
pip install -r requirements.txt
```

### Models Not Found
```python
# Ensure models are imported in Django shell
from accounts.models import CustomUser
from profiles.models import Profile
```

## 📞 Next Steps

1. Migrate any existing data from SQLite (if you have a migration script)
2. Update your API views if needed
3. Add more models to `profiles/models.py` as needed
4. Consider adding a non-SQL admin dashboard for management

---

**Database Type:** MongoDB (NoSQL)  
**ODM:** MongoEngine  
**Status:** ✅ Ready to use
