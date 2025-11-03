# Staging vs Production: Cloud Run Architecture Guide

## Overview

Your FreshWall project has two different backend architectures:

| Environment | Architecture | URLs | Interface |
|------------|--------------|------|-----------|
| **Production** (`freshwall-30afe`) | Firebase Functions v1 | `cloudfunctions.net` | Firebase Console → Functions |
| **Staging** (`freshwall-staging`) | Firebase Functions v2 → Cloud Run | `run.app` | Google Cloud Console → Cloud Run |

## Why Are They Different?

**Firebase Functions v2** (used in staging) is built on top of **Google Cloud Run**. This is the modern, recommended approach from Google, but it exposes the underlying Cloud Run infrastructure in the Google Cloud Console.

### Key Differences:

**Production (v1 - Traditional):**
- Managed entirely through Firebase Console
- URLs: `https://us-central1-freshwall-30afe.cloudfunctions.net/{functionName}`
- Authentication handled automatically
- Simpler, but older architecture

**Staging (v2 - Cloud Run):**
- Visible in both Firebase Console AND Google Cloud Console
- URLs: `https://{service}-{hash}.run.app` (Cloud Run)
- Also: `https://us-central1-freshwall-staging.cloudfunctions.net/{functionName}` (Firebase proxy)
- Requires additional IAM configuration
- Modern, scalable, and more configurable

## The Authentication Problem

### What Was Happening

Your logs showed:
```
status: 403
The request was not authenticated. Either allow unauthenticated invocations or set the proper Authorization header.
```

### Why This Happened

1. **Firebase callable functions** use a special authentication mechanism where the Firebase SDK:
   - Sends the user's auth token in the request **body**
   - Cloud Function validates it using Firebase Admin SDK

2. **Cloud Run** (the underlying platform for Functions v2) has its own authentication layer:
   - By default, requires **IAM permissions** to invoke
   - Blocks requests from `allUsers` unless explicitly allowed

3. **The conflict:**
   - Cloud Run was blocking requests because it didn't see valid IAM credentials
   - But Firebase callable functions don't use IAM - they use Firebase Auth tokens
   - Result: Your perfectly valid Firebase Auth requests were being rejected at the Cloud Run layer

### The Solution

Make Cloud Run services publicly invokable (`allUsers` has `roles/run.invoker`), because:
- Firebase handles authentication internally through the request payload
- Cloud Run just provides the HTTP transport layer
- Only authenticated Firebase users can execute the function logic

**This is secure!** The function still validates Firebase Auth tokens before executing any logic.

## How to Fix Authentication Issues

### Option 1: Use the Script (Recommended)

```bash
cd Firebase
./fix-callable-function-auth.sh
```

This script will:
1. List all your callable functions
2. Grant `allUsers` the Cloud Run Invoker role for each one
3. Report success/failure for each function

### Option 2: Manual Fix via Google Cloud Console

For each function that returns 403 errors:

1. Go to [Cloud Run Console](https://console.cloud.google.com/run?project=freshwall-staging)
2. Click on the service (e.g., `createteamcreateuser`)
3. Click the **Permissions** tab
4. Click **Add Principal**
5. Principal: `allUsers`
6. Role: **Cloud Run Invoker**
7. Click **Save**

### Option 3: Manual Fix via gcloud CLI

```bash
gcloud run services add-iam-policy-binding createteamcreateuser \
  --project=freshwall-staging \
  --region=us-central1 \
  --member="allUsers" \
  --role="roles/run.invoker"
```

## Deployment Workflow

### Deploying to Staging

```bash
# Make sure you're on the staging project
firebase use freshwall-staging

# Deploy functions
cd Firebase
npm run build
firebase deploy --only functions

# Fix authentication (if needed)
./fix-callable-function-auth.sh
```

### Deploying to Production

```bash
# Switch to production project
firebase use freshwall-30afe

# Deploy functions (no special auth config needed for v1)
cd Firebase
npm run build
firebase deploy --only functions
```

## Environment Configuration

### Firebase Functions Configuration

Your `firebase.json` doesn't specify the functions runtime version, so it uses the version based on your dependencies in `package.json`.

To explicitly set v2 (recommended), update `Firebase/functions/package.json`:

```json
{
  "engines": {
    "node": "18"
  },
  "main": "lib/index.js"
}
```

And ensure you're using v2 imports in your code:

```typescript
// ✅ Functions v2 (Cloud Run)
import { onCall } from "firebase-functions/v2/https";
import { onDocumentWritten } from "firebase-functions/v2/firestore";

// ❌ Functions v1 (legacy)
import * as functions from "firebase-functions";
```

### Which Version Should You Use?

**Use Functions v2 (Cloud Run) for:**
- New projects (like staging)
- Better performance and scaling
- More configuration options
- Modern Google Cloud features

**Keep Functions v1 if:**
- Existing production environment is stable
- Migration risk is not worth the benefits
- Simpler management is preferred

## Migrating Production to v2

If you want to migrate production to the same architecture as staging:

### 1. Update Dependencies

```bash
cd Firebase/functions
npm install firebase-functions@latest
```

### 2. Update Function Code

Your code is already using v2 syntax! (`onCall` from `firebase-functions/v2/https`)

### 3. Deploy to Production

```bash
firebase use freshwall-30afe
cd Firebase
npm run build
firebase deploy --only functions
```

### 4. Fix Authentication

Since production will now use Cloud Run too, you'll need to fix authentication:

```bash
# Update the script to use freshwall-30afe
# Or run manually for each function
./fix-callable-function-auth.sh
```

### 5. Update iOS App

If function URLs change, update your iOS app's Firebase configuration.

## Monitoring & Debugging

### Viewing Logs

**Staging (Cloud Run):**
```bash
# Firebase logs
firebase functions:log --project freshwall-staging

# Cloud Run logs (more detailed)
# Go to: https://console.cloud.google.com/run?project=freshwall-staging
# Click function → Logs tab
```

**Production (Functions v1):**
```bash
# Firebase logs
firebase functions:log --project freshwall-30afe

# Or in console: https://console.firebase.google.com/u/0/project/freshwall-30afe/functions
```

### Common Issues

| Issue | Cause | Solution |
|-------|-------|----------|
| 403 Forbidden | Cloud Run auth not set | Run `fix-callable-function-auth.sh` |
| Function not found | Wrong project selected | Check `firebase use` |
| CORS errors | Missing CORS config | Already configured in your `onCall()` |
| Build failures | Permission issues | Run `fix-staging-permissions.sh` |

## Security Considerations

### Is Making Cloud Run Public Safe?

**Yes!** For Firebase callable functions:

1. **Cloud Run** only handles HTTP transport
   - Public access = can receive HTTP requests
   - Does NOT mean unauthenticated function execution

2. **Firebase validates auth** in the function code:
   ```typescript
   export const createTeamCreateUser = onCall(async (request) => {
     if (!request.auth?.uid) {  // ← Auth validation
       throw new Error("User must be authenticated.");
     }
     // ... rest of function
   });
   ```

3. **Defense in depth:**
   - Firestore security rules enforce data access
   - Cloud Run manages scaling and DDoS protection
   - Firebase Auth validates all requests

### What About Non-Callable Functions?

For **HTTP functions** (not callable), you control auth yourself:

```typescript
import { onRequest } from "firebase-functions/v2/https";

export const webhook = onRequest(async (req, res) => {
  // Validate your own auth header
  const authHeader = req.headers.authorization;
  // ...
});
```

For **Firestore triggers** (like `onDocumentWritten`):
- No HTTP endpoint
- No Cloud Run service
- Runs automatically on database changes

## Checklist: Setting Up New Environment

- [ ] Create Firebase project
- [ ] Enable required APIs (Cloud Functions, Cloud Run, Cloud Build)
- [ ] Grant build permissions: `./fix-staging-permissions.sh`
- [ ] Deploy functions: `firebase deploy --only functions`
- [ ] Fix callable function auth: `./fix-callable-function-auth.sh`
- [ ] Test with iOS app
- [ ] Configure Firestore rules
- [ ] Set up monitoring/alerts

## Resources

- [Firebase Functions v2 docs](https://firebase.google.com/docs/functions/beta)
- [Cloud Run docs](https://cloud.google.com/run/docs)
- [Callable functions guide](https://firebase.google.com/docs/functions/callable)
- [Cloud Run IAM](https://cloud.google.com/run/docs/securing/managing-access)

---

**Last Updated:** 2025-11-02
**Applies To:** FreshWall staging and production environments
