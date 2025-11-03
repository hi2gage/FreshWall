# Visual Guide: Fixing Cloud Run Authentication

## Problem: 403 Forbidden Errors

Your Firebase callable functions are returning 403 because Cloud Run requires authentication by default.

## Solution: Allow Public Access to Cloud Run Services

### Method 1: Google Cloud Console (Visual)

#### Step 1: Navigate to Cloud Run
1. Go to: https://console.cloud.google.com/run?project=freshwall-staging
2. You'll see a list of your services (functions):
   ```
   ✓ createteamcreateuser
   ✓ jointeamcreateuser
   ✓ generateinvitecode
   ✓ notifynewincident
   ✓ notifynewclient
   ✓ notifynewuser
   ```

#### Step 2: Click on a Service
Click on any service name (e.g., `createteamcreateuser`)

#### Step 3: Go to Permissions Tab
At the top of the service details page, you'll see tabs:
```
[DETAILS] [METRICS] [REVISIONS] [LOGS] [PERMISSIONS] [YAML]
                                              ↑
                                         Click here
```

#### Step 4: Add Principal
1. Click the **"+ ADD PRINCIPAL"** button (top right)

2. A dialog will appear with two fields:

   **New principals:**
   ```
   ┌─────────────────────────────────────┐
   │ allUsers                            │  ← Type this exactly
   └─────────────────────────────────────┘
   ```

   **Select a role:**
   ```
   ┌─────────────────────────────────────┐
   │ Cloud Run Invoker                   │  ← Search and select this
   └─────────────────────────────────────┘
   ```

3. Click **"SAVE"**

#### Step 5: Verify
After saving, you should see in the Permissions list:
```
Principal         | Role
──────────────────┼──────────────────
allUsers          | Cloud Run Invoker
```

#### Step 6: Repeat for All Functions
Repeat steps 2-5 for each of your callable functions:
- createteamcreateuser ✓
- jointeamcreateuser
- generateinvitecode
- notifynewincident
- notifynewclient
- notifynewuser

---

### Method 2: gcloud CLI (Fast)

If you have gcloud CLI installed, run these commands:

```bash
# Set your project
PROJECT="freshwall-staging"
REGION="us-central1"

# Fix each function
gcloud run services add-iam-policy-binding createteamcreateuser \
  --project=$PROJECT --region=$REGION \
  --member="allUsers" --role="roles/run.invoker"

gcloud run services add-iam-policy-binding jointeamcreateuser \
  --project=$PROJECT --region=$REGION \
  --member="allUsers" --role="roles/run.invoker"

gcloud run services add-iam-policy-binding generateinvitecode \
  --project=$PROJECT --region=$REGION \
  --member="allUsers" --role="roles/run.invoker"

gcloud run services add-iam-policy-binding notifynewincident \
  --project=$PROJECT --region=$REGION \
  --member="allUsers" --role="roles/run.invoker"

gcloud run services add-iam-policy-binding notifynewclient \
  --project=$PROJECT --region=$REGION \
  --member="allUsers" --role="roles/run.invoker"

gcloud run services add-iam-policy-binding notifynewuser \
  --project=$PROJECT --region=$REGION \
  --member="allUsers" --role="roles/run.invoker"
```

Or use the script:
```bash
cd Firebase
./fix-callable-function-auth.sh
```

---

### Method 3: During Deployment (Prevent the Issue)

When deploying Cloud Functions v2, you can set the invoker during deployment:

**Update your Firebase function code:**

```typescript
import { onCall } from "firebase-functions/v2/https";

export const createTeamCreateUser = onCall(
  {
    // Add this configuration
    invoker: "public",  // ← Makes Cloud Run publicly invokable
    cors: true,
  },
  async (request) => {
    // Your function code
  }
);
```

**Then redeploy:**
```bash
cd Firebase
npm run build
firebase deploy --only functions
```

---

## What Each Section Looks Like

### Cloud Run Services List
```
┌────────────────────────────────────────────────────────────────┐
│ Cloud Run                                                      │
├────────────────────────────────────────────────────────────────┤
│                                                                │
│ Service Name              | Region      | Last Deployed       │
│ ──────────────────────────┼─────────────┼──────────────────   │
│ createteamcreateuser      | us-central1 | 7 minutes ago      │
│ jointeamcreateuser        | us-central1 | 7 minutes ago      │
│ generateinvitecode        | us-central1 | 7 minutes ago      │
│ notifynewincident         | us-central1 | 7 minutes ago      │
│ notifynewclient           | us-central1 | 7 minutes ago      │
│ notifynewuser             | us-central1 | 7 minutes ago      │
│                                                                │
└────────────────────────────────────────────────────────────────┘
```

### Service Details - Permissions Tab
```
┌────────────────────────────────────────────────────────────────┐
│ createteamcreateuser                                           │
├────────────────────────────────────────────────────────────────┤
│                                                                │
│ [DETAILS] [METRICS] [REVISIONS] [LOGS] [PERMISSIONS] [YAML]  │
│                                             ^^^^^^^^            │
│                                                                │
│ ┌────────────────────────────────────────────┐                │
│ │ Permissions                  [+ ADD PRINCIPAL]              │
│ │                                                              │
│ │ Control access to this service                              │
│ │                                                              │
│ │ Principal         | Role                                     │
│ │ ──────────────────┼───────────────────────                  │
│ │ allUsers          | Cloud Run Invoker                        │
│ │                   |                                          │
│ └────────────────────────────────────────────┘                │
│                                                                │
└────────────────────────────────────────────────────────────────┘
```

---

## Why This Is Safe

**Q: Won't making it public allow anyone to call my functions?**

**A: No!** Here's why:

1. **Cloud Run** handles HTTP transport only
   - "Public" means: can receive HTTP requests
   - Does NOT mean: can execute without authentication

2. **Firebase validates authentication** in your code:
   ```typescript
   export const createTeamCreateUser = onCall(async (request) => {
     if (!request.auth?.uid) {  // ← This still validates!
       throw new Error("User must be authenticated.");
     }
     // Only authenticated users get here
   });
   ```

3. **Defense in depth:**
   - Cloud Run: Manages HTTP
   - Firebase Auth: Validates users
   - Firestore Rules: Controls data access
   - Function Code: Implements business logic

---

## Testing After Fixing

### Test from iOS App

The 403 errors should be gone. If you see:

**Before (Error):**
```
Error: 403 Forbidden
The request was not authenticated.
```

**After (Success):**
```
✅ Team created successfully
teamId: abc123
teamCode: A1B2C3
```

### Test from Firebase Console

1. Go to Firebase Console → Functions
2. Click on a function → "Logs" tab
3. You should see successful executions

### Check Cloud Run Metrics

1. Go to Cloud Run Console
2. Click on a service
3. Click "Metrics" tab
4. You should see:
   - Request count increasing
   - 2xx status codes (success)
   - No 403 errors

---

## Troubleshooting

### "I don't see the Permissions tab"

Make sure you're looking at:
- **Cloud Run** console (not Cloud Functions console)
- **Service details** (not the services list)

Direct link: https://console.cloud.google.com/run?project=freshwall-staging

### "Add Principal button is grayed out"

Check your Google Cloud IAM permissions. You need:
- `run.services.setIamPolicy` permission
- Or the `Cloud Run Admin` role

### "Still getting 403 errors"

1. Verify the permission was added:
   ```bash
   gcloud run services get-iam-policy createteamcreateuser \
     --project=freshwall-staging \
     --region=us-central1
   ```

2. Check which URL your app is calling
3. Try calling the Firebase proxy URL instead:
   ```
   https://us-central1-freshwall-staging.cloudfunctions.net/createTeamCreateUser
   ```

---

## Quick Reference

| What | Where | Action |
|------|-------|--------|
| Set permissions | Cloud Run Console → Service → Permissions | Add `allUsers` as `Cloud Run Invoker` |
| View logs | Cloud Run Console → Service → Logs | Check for errors |
| Deploy functions | Terminal: `firebase deploy --only functions` | Updates all functions |
| Switch projects | Terminal: `firebase use freshwall-staging` | Changes active project |

---

**Remember:** You need to do this for EACH Cloud Run service (each function becomes a separate service).
