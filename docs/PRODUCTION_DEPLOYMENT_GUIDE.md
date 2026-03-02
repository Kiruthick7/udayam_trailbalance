# 🚀 Production Deployment Guide

Complete guide to deploy your Trial Balance app to production.

## 📋 Prerequisites Checklist

- [ ] AWS account with appropriate permissions
- [ ] Lambda deployment package created (`aws_lambda.zip` exists)
- [ ] AWS Secrets Manager secrets created (trial-balance-db-secret, trial-balance-jwt-secret)
- [ ] RDS MySQL database running and accessible
- [ ] Users table populated with admin accounts

---

## Part 1: Deploy Backend to AWS Lambda

### Step 1: Upload Lambda Function

#### Option A: Using AWS Console (Recommended for first deployment)

1. **Go to AWS Lambda Console:**
   - Navigate to: https://console.aws.amazon.com/lambda/
   - Region: **ap-south-1** (Mumbai)

2. **Upload the deployment package:**
   - Click on your function name (e.g., `udayam-fastapi`)
   - Scroll to "Code source" section
   - Click **"Upload from"** → **".zip file"**
   - Click **"Upload"** and select: `/Users/h1598349/Personal/udayam/trial_balance_api/aws_lambda.zip`
   - Click **"Save"**

#### Option B: Using AWS CLI (Faster for updates)

```bash
cd /Users/h1598349/Personal/udayam/trial_balance_api

# Upload the function code
aws lambda update-function-code \
  --function-name udayam-fastapi \
  --zip-file fileb://aws_lambda.zip \
  --region ap-south-1
```

### Step 2: Configure Lambda Environment Variables

1. **Go to Lambda Configuration:**
   - Lambda Console → Your function → **Configuration** tab
   - Click **Environment variables** → **Edit**

2. **Add these environment variables:**

   ```
   DB_SECRET_NAME = trial-balance-db-secret
   JWT_SECRET_NAME = trial-balance-jwt-secret
   AWS_REGION = ap-south-1
   ```

3. Click **Save**

### Step 3: Configure Lambda Function Settings

1. **Handler Configuration:**
   - Go to **Code** tab → **Runtime settings** → **Edit**
   - Handler: `main.handler`
   - Click **Save**

2. **Timeout & Memory:**
   - Go to **Configuration** tab → **General configuration** → **Edit**
   - Memory: **512 MB** (minimum)
   - Timeout: **30 seconds**
   - Click **Save**

### Step 4: Attach IAM Role Permissions

1. **Go to IAM Console:**
   - Lambda Console → Your function → **Configuration** → **Permissions**
   - Click on the **Role name** (opens IAM console)

2. **Add Secrets Manager Policy:**
   - Click **Add permissions** → **Attach policies**
   - Search for: `SecretsManagerReadWrite`
   - Select it and click **Attach policies**

   **OR create custom policy (more secure):**

   ```json
   {
     "Version": "2012-10-17",
     "Statement": [
       {
         "Effect": "Allow",
         "Action": [
           "secretsmanager:GetSecretValue",
           "secretsmanager:DescribeSecret"
         ],
         "Resource": [
           "arn:aws:secretsmanager:ap-south-1:YOUR_ACCOUNT_ID:secret:trial-balance-db-secret-*",
           "arn:aws:secretsmanager:ap-south-1:YOUR_ACCOUNT_ID:secret:trial-balance-jwt-secret-*"
         ]
       }
     ]
   }
   ```

### Step 5: Test Lambda Function

1. **Create a test event:**
   - Lambda Console → **Test** tab
   - Click **Create new event**
   - Event name: `health-check`
   - Template: **API Gateway AWS Proxy**
   - Modify the event JSON:

   ```json
   {
     "httpMethod": "GET",
     "path": "/health",
     "headers": {},
     "queryStringParameters": null,
     "body": null,
     "isBase64Encoded": false
   }
   ```

2. **Run the test:**
   - Click **Test** button
   - Check response:
     - Status code should be **200**
     - Body should contain: `{"status": "healthy"}`

3. **Test login endpoint:**
   - Create another test event: `test-login`
   - Event JSON:

   ```json
   {
     "httpMethod": "POST",
     "path": "/auth/login",
     "headers": {
       "Content-Type": "application/json"
     },
     "body": "{\"email\":\"harish@udayam.com\",\"password\":\"your_password\"}",
     "isBase64Encoded": false
   }
   ```

   - Click **Test**
   - Should return access token and refresh token

---

## Part 2: Get Production API URL

### Step 1: Find API Gateway URL

1. **Go to API Gateway Console:**
   - Navigate to: https://console.aws.amazon.com/apigateway/
   - Region: **ap-south-1**

2. **Find your API:**
   - Click on your API name (e.g., `UDAYAM-FASTAPI-API`)
   - Go to **Stages** in left sidebar
   - Click on **$default** stage

3. **Copy the Invoke URL:**
   - You'll see something like:
     ```
     https://h32dbgnyv3.execute-api.ap-south-1.amazonaws.com
     ```
   - **Copy this URL** - you'll need it for the Flutter app

### Step 2: Test API Endpoints

Test all endpoints using curl or Postman:

```bash
# Health check
curl https://YOUR_API_URL/health

# Login (replace with your credentials)
curl -X POST https://YOUR_API_URL/auth/login \
  -H "Content-Type: application/json" \
  -d '{"email":"harish@udayam.com","password":"your_password"}'

# Get companies (requires token from login)
curl https://YOUR_API_URL/api/companies \
  -H "Authorization: Bearer YOUR_ACCESS_TOKEN"
```

---

## Part 3: Update Flutter App for Production

### Step 1: Update API Base URL

Edit the Flutter API service file:

**File:** `/Users/h1598349/Personal/udayam/trial_balance_app/lib/services/api_service.dart`

Change line 16 from:

```dart
'http://10.0.2.2:8000'  // Development
```

To:

```dart
'https://YOUR_API_GATEWAY_URL'  // Production
```

**Example:**
```dart
ApiService(
    {String baseUrl =
        'https://h32dbgnyv3.execute-api.ap-south-1.amazonaws.com'}) {
```

### Step 2: Build Flutter App for Production

#### For Android (APK):

```bash
cd /Users/h1598349/Personal/udayam/trial_balance_app

# Clean previous builds
flutter clean

# Get dependencies
flutter pub get

# Build release APK
flutter build apk --release

# APK will be at:
# build/app/outputs/flutter-apk/app-release.apk
```

#### For Android (AAB - Google Play Store):

```bash
flutter build appbundle --release

# AAB will be at:
# build/app/outputs/bundle/release/app-release.aab
```

#### For iOS (requires Mac):

```bash
flutter build ios --release

# Then open in Xcode:
open ios/Runner.xcworkspace

# In Xcode:
# 1. Select "Any iOS Device"
# 2. Product → Archive
# 3. Distribute App
```

### Step 3: Test Production Build

1. **Install the APK on your device:**
   ```bash
   # Using ADB
   adb install build/app/outputs/flutter-apk/app-release.apk
   ```

2. **Test all features:**
   - [ ] Login works
   - [ ] Auto-login works after closing/reopening
   - [ ] Companies load correctly
   - [ ] Trial balance reports generate
   - [ ] Logout works
   - [ ] All data displays correctly

---

## Part 4: Monitoring & Troubleshooting

### CloudWatch Logs

1. **View Lambda logs:**
   - CloudWatch Console → **Logs** → **Log groups**
   - Find: `/aws/lambda/UDAYAM-FASTAPI`
   - Click on latest log stream

2. **Common errors to check:**
   - Database connection issues
   - Secrets Manager access denied
   - JWT token errors
   - 500 Internal Server errors

### API Gateway Logs (Optional but Recommended)

1. **Enable logging:**
   - API Gateway Console → Your API → **Stages** → **$default**
   - **Logs/Tracing** tab
   - Enable **CloudWatch Logs**
   - Set log level to **INFO** or **ERROR**

### Set Up CloudWatch Alarms

Create alarms for:
- Lambda errors > 10 in 5 minutes
- Lambda duration > 25 seconds
- API Gateway 5XX errors > 10 in 5 minutes

---

## Part 5: Security Best Practices

### ✅ Completed
- [x] JWT authentication enabled
- [x] Password hashing with bcrypt
- [x] AWS Secrets Manager for credentials
- [x] HTTPS only (via API Gateway)

### 🔒 Additional Recommendations

1. **CORS Configuration:**
   - Update `main.py` to restrict CORS to your domain
   - Remove `http://localhost:3000` in production

2. **Rate Limiting:**
   - Enable API Gateway throttling
   - Set limits: 1000 requests/second per IP

3. **Database Security:**
   - Ensure RDS is in private subnet
   - Enable encryption at rest
   - Enable automated backups

4. **Monitoring:**
   - Set up CloudWatch dashboards
   - Configure SNS alerts for errors
   - Monitor database connections

---

## Part 6: Cost Optimization

### Current Expected Costs (Monthly)

- **Lambda:**
  - Free tier: 1M requests/month
  - After: $0.20 per 1M requests
  - Expected: **$0-5/month**

- **API Gateway:**
  - Free tier: 1M requests/month
  - After: $1.00 per 1M requests
  - Expected: **$0-2/month**

- **Secrets Manager:**
  - $0.40 per secret/month
  - 2 secrets = **$0.80/month**

- **RDS MySQL:**
  - db.t3.micro: **~$15/month** (if running 24/7)
  - Consider stopping when not in use

- **CloudWatch Logs:**
  - 5 GB free per month
  - Expected: **$0-1/month**

**Total estimated cost: $15-25/month**

### Cost Saving Tips:
- Stop RDS when not actively using
- Use Lambda reserved concurrency only if needed
- Enable CloudWatch log retention (7-14 days)
- Consider Aurora Serverless for DB (auto-scales to zero)

---

## 🎉 Deployment Complete!

Your Trial Balance app is now running in production!

### Quick Reference URLs:

- **API URL:** https://YOUR_API_GATEWAY_URL
- **Lambda Function:** https://console.aws.amazon.com/lambda/home?region=ap-south-1#/functions/UDAYAM-FASTAPI
- **API Gateway:** https://console.aws.amazon.com/apigateway/home?region=ap-south-1
- **CloudWatch Logs:** https://console.aws.amazon.com/cloudwatch/home?region=ap-south-1#logsV2:log-groups/log-group/$252Faws$252Flambda$252FUDAYAM-FASTAPI

### Support:
- For Lambda issues, check CloudWatch logs
- For API Gateway issues, check API Gateway logs
- For database issues, check RDS monitoring

---

## Next Steps (Optional Enhancements)

1. **Custom Domain:**
   - Set up Route 53 domain
   - Configure API Gateway custom domain
   - Add SSL certificate

2. **CI/CD Pipeline:**
   - Set up GitHub Actions
   - Automate deployment on push to main branch

3. **Backup Strategy:**
   - Configure RDS automated backups
   - Set up S3 bucket for report exports

4. **Advanced Monitoring:**
   - Set up AWS X-Ray for tracing
   - Create CloudWatch dashboards
   - Configure SNS alerts

5. **User Management:**
   - Add user registration endpoint
   - Implement forgot password
   - Add email verification
