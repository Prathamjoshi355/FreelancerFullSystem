# Backend Quick Start Guide

## Project Structure

```
freelancerbackend/
├── accounts/              # User authentication & registration
├── profiles/              # User profiles & portfolio
├── jobs/                  # Job postings & applications
├── proposals/             # Proposals/Bids system
├── payments/              # Transactions & payouts
├── messages/              # Messaging system
├── notifications/         # Notifications system
├── FreelancerBackend/     # Main Django project settings
├── manage.py              # Django management
└── requirements.txt       # Dependencies
```

## Environment Setup

### 1. Install Dependencies
```bash
cd freelancerbackend
pip install -r requirements.txt
```

### 2. Start MongoDB
Ensure MongoDB is running:
```bash
# On Windows (if installed locally)
mongod

# Or use remote connection - update in settings.py:
MONGO_URI = 'mongodb://username:password@host:27017'
```

### 3. Run Development Server
```bash
python manage.py runserver
```

Server runs on: `http://localhost:8000`

## Core Workflows

### 1. Client Posts a Job
```
1. Client registers with role='client' and company_name
2. Client navigates to /api/jobs/ (POST) and creates job
3. Job appears on /api/jobs/ (GET) for freelancers
4. Freelancers view job at /api/jobs/{id}
```

### 2. Freelancer Applies
```
1. Freelancer browses jobs at /api/jobs/
2. Submits proposal at /api/proposals/ (POST)
3. Client sees proposal at /api/jobs/{id}/applications/
4. Client accepts proposal via /api/proposals/{id}/accept/
5. Job status changes to 'in_progress'
```

### 3. Payment Flow
```
1. After proposal accepted, client initiates payment
2. POST /api/payments/transactions/create_payment/
3. System calculates 10% platform fee
4. Payment held for 7 days (dispute period)
5. After 7 days, freelancer can release payment
6. POST /api/payments/transactions/{id}/release_payment/
7. Freelancer requests payout at /api/payments/payouts/request_payout/
```

### 4. Messaging
```
1. Create conversation: POST /api/messages/conversations/
2. Send message: POST /api/messages/messages/
3. Mark as read: POST /api/messages/messages/mark_as_read/
4. View unread: GET /api/messages/messages/unread_count/
```

## API Testing

### Using curl

**Get Token:**
```bash
curl -X POST http://localhost:8000/api/token/ \
  -H "Content-Type: application/json" \
  -d '{"email":"user@example.com","password":"password"}'
```

**Create Job:**
```bash
curl -X POST http://localhost:8000/api/jobs/ \
  -H "Authorization: Bearer {access_token}" \
  -H "Content-Type: application/json" \
  -d '{
    "title":"Web Dev Job",
    "description":"Build a website",
    "category":"Web Development",
    "budget_type":"fixed",
    "budget_min":1000,
    "budget_max":5000,
    "required_skills":["React"],
    "duration":"medium",
    "deadline":"2026-04-13T23:59:59Z"
  }'
```

### Using Postman
1. Import API endpoints from API_DOCUMENTATION.md
2. Set Authorization to "Bearer Token"
3. Add your JWT token
4. Test endpoints

### Using REST Client (VS Code)
Create a `.rest` file:
```
### Get Token
POST http://localhost:8000/api/token/
Content-Type: application/json

{
  "email": "test@example.com",
  "password": "password"
}

### Create Job
POST http://localhost:8000/api/jobs/
Authorization: Bearer YOUR_TOKEN_HERE
Content-Type: application/json

{
  "title": "Web Dev Job",
  "description": "Build website",
  "category": "Web Development",
  "budget_type": "fixed",
  "budget_min": 1000,
  "budget_max": 5000,
  "required_skills": ["React"],
  "duration": "medium",
  "deadline": "2026-04-13T23:59:59Z"
}
```

## Database Queries

### View MongoDB Collections
```bash
# Connect to MongoDB
mongosh

# List databases
show dbs

# Use freelancer_db
use freelancer_db

# List collections
show collections

# View sample documents
db.custom_users.findOne()
db.jobs.find().limit(5)
```

## Troubleshooting

### MongoDB Connection Error
- Ensure MongoDB is running
- Check MONGO_URI in settings.py
- Verify authentication credentials if using remote DB

### CORS Errors
- Check CORS_ALLOWED_ORIGINS in settings.py
- Add frontend URL if needed
- Restart server after changes

### JWT Token Issues
- Token expired? Use refresh token at /api/token/refresh/
- Invalid token? Ensure Authorization header format: `Bearer {token}`
- No token? User not authenticated - login first

## Development Tips

### Enable Debug Mode
```python
# settings.py
DEBUG = True
```

### Running Tests
```bash
python manage.py test
```

### Database Migrations (for future use)
```bash
python manage.py makemigrations
python manage.py migrate
```

### Create Superuser (Admin)
```bash
python manage.py createsuperuser
```

## Production Deployment

### Before Going Live:
1. Set `DEBUG = False` in settings.py
2. Update `SECRET_KEY` (use environment variable)
3. Configure `ALLOWED_HOSTS` with your domain
4. Update `CORS_ALLOWED_ORIGINS` with frontend URL
5. Use environment variables for sensitive data
6. Enable HTTPS
7. Set up proper database backups
8. Configure email for notifications
9. Set up error logging/monitoring

### Example .env file:
```
DJANGO_SECRET_KEY=your-secret-key
DEBUG=False
MONGODB_URI=mongodb://user:pass@host:27017
ALLOWED_HOSTS=yourdomain.com,www.yourdomain.com
```

## API Response Format

All API responses follow this format:

### Success Response (2xx)
```json
{
  "id": "unique-id",
  "field1": "value1",
  "field2": 123,
  "created_at": "2026-03-13T10:30:00Z"
}
```

### List Response
```json
[
  { "id": "1", "name": "Item 1" },
  { "id": "2", "name": "Item 2" }
]
```

### Error Response (4xx, 5xx)
```json
{
  "detail": "Error message explaining what went wrong"
}
```

## Next Steps

1. **Frontend Integration**: Update frontend API base URL to point to this backend
2. **Real-time Features**: Add WebSockets for live notifications & messaging
3. **Payment Gateway**: Integrate Stripe or PayPal
4. **Email Service**: Add email notifications for jobs, proposals, etc.
5. **File Upload**: Implement avatar & portfolio upload
6. **Rating System**: Add review & rating features
7. **Admin Dashboard**: Create admin panel for platform management

## Support

For issues or questions:
1. Check API_DOCUMENTATION.md for endpoint details
2. Review error messages carefully
3. Check MongoDB data for consistency
4. Enable Django debug toolbar for detailed request info
