# Web App Authentication Troubleshooting Guide

## Quick Diagnostic Checklist

### 1. Check Browser Console
Open your browser developer tools (F12) and check the Console tab for errors.

**Common Error Patterns:**

```
❌ auth/unauthorized-domain
   → Your domain is not authorized in Firebase
   → Fix: Add domain to Firebase Auth settings

❌ auth/operation-not-allowed
   → Sign-in method is disabled
   → Fix: Enable Email/Password or Google in Firebase Auth

❌ auth/popup-blocked
   → Browser blocked the Google sign-in popup
   → Fix: Allow popups or use redirect instead

❌ 403 Forbidden (from cloudfunctions.net)
   → Cloud Run permissions not set
   → Fix: Run ./fix-callable-function-auth.sh

❌ auth/invalid-api-key
   → Wrong Firebase config in .env.staging
   → Fix: Verify API key matches Firebase console
```

### 2. Verify Firebase Auth Configuration

#### Check Authorized Domains
1. Go to: https://console.firebase.google.com/u/0/project/freshwall-staging/authentication/settings
2. Click **Settings** → **Authorized domains**
3. Required domains for staging:
   - ✓ `localhost` (local dev)
   - ✓ `staging-freshwall.vercel.app` (your Vercel deployment)
   - ✓ `freshwall-staging.firebaseapp.com` (Firebase default)
   - ✓ `freshwall-staging.web.app` (Firebase Hosting, if used)

#### Check Sign-in Methods
1. Go to: https://console.firebase.google.com/u/0/project/freshwall-staging/authentication/providers
2. Click **Sign-in method** tab
3. Enable these providers:
   - ✓ **Email/Password** → Enabled
   - ✓ **Google** → Enabled (with Web SDK configuration)

#### Google Sign-In Configuration
1. Click on **Google** provider
2. Make sure:
   - **Project support email** is set
   - **Project public-facing name** is set
   - Status shows **Enabled**

### 3. Verify Environment Variables

Check that your web app is using the correct staging configuration:

```bash
cd Web

# Check which .env file is being used
# For local dev: .env.local
# For Vercel staging: .env.staging

# Verify the values match Firebase console
cat .env.staging
```

Expected values for staging:
```bash
NEXT_PUBLIC_FIREBASE_API_KEY=AIzaSyASZLh4sugQQtOhZat93tYPUlr_ELDdHpQ
NEXT_PUBLIC_FIREBASE_AUTH_DOMAIN=freshwall-staging.firebaseapp.com
NEXT_PUBLIC_FIREBASE_PROJECT_ID=freshwall-staging
NEXT_PUBLIC_FIREBASE_STORAGE_BUCKET=freshwall-staging.firebasestorage.app
NEXT_PUBLIC_FIREBASE_MESSAGING_SENDER_ID=473800449577
NEXT_PUBLIC_FIREBASE_APP_ID=1:473800449577:web:3e8f7f9de0975f05a64638
```

### 4. Test Authentication Methods

#### Test Email/Password Login

**Create a test user manually:**
1. Go to: https://console.firebase.google.com/u/0/project/freshwall-staging/authentication/users
2. Click **Add user**
3. Email: `test@freshwall.app`
4. Password: Choose a strong password
5. Click **Add user**

**Try logging in with this user:**
- If it works → Auth is configured correctly
- If it fails → Check console for specific error

#### Test Google Sign-In

**Prerequisites:**
- Google provider must be enabled in Firebase
- OAuth consent screen must be configured in Google Cloud
- Your domain must be in authorized domains

**Common Google Sign-In Errors:**
```javascript
// Popup was blocked
auth/popup-blocked
→ Solution: Allow popups or use signInWithRedirect

// OAuth client not configured
auth/operation-not-allowed
→ Solution: Enable Google provider in Firebase

// Invalid OAuth client
auth/invalid-oauth-provider
→ Solution: Check OAuth consent screen configuration
```

### 5. Cloud Run Permissions (For Callable Functions)

If you're using Firebase callable functions after login (like `createTeamCreateUser`), you need to set Cloud Run permissions.

**Check if this is the issue:**
Look for errors like:
```
403 Forbidden
The request was not authenticated
```

**Fix:**
```bash
cd Firebase
./fix-callable-function-auth.sh
```

Or manually in Google Cloud Console:
1. https://console.cloud.google.com/run?project=freshwall-staging
2. For each function → Permissions → Add Principal
3. Principal: `allUsers`, Role: `Cloud Run Invoker`

### 6. Vercel Deployment Configuration

If you're testing on Vercel (https://staging-freshwall.vercel.app):

**Check environment variables:**
1. Go to Vercel dashboard → Your project → Settings → Environment Variables
2. Make sure all `NEXT_PUBLIC_FIREBASE_*` variables are set for **Preview** environment
3. Variables should match `.env.staging`

**After adding/changing variables:**
- Redeploy the application
- Environment changes don't apply to existing deployments

### 7. Network/CORS Issues

**Check Network Tab:**
1. Open DevTools → Network tab
2. Try to log in
3. Look for failed requests (red)

**Common CORS errors:**
```
Access to XMLHttpRequest has been blocked by CORS policy
```

**Fix:**
Firebase automatically handles CORS for:
- `firebaseapp.com` domains
- Authorized domains in Firebase Auth settings

If you see CORS errors, the domain likely isn't authorized.

### 8. Service Account Permissions (Advanced)

The difference in service account count (22 vs 15) is usually not an issue. Service accounts are created automatically.

**However, if you're having permission issues:**

Check IAM permissions:
1. Go to: https://console.cloud.google.com/iam-admin/iam?project=freshwall-staging
2. Look for these service accounts:
   - `firebase-adminsdk@freshwall-staging.iam.gserviceaccount.com`
   - `{PROJECT_NUMBER}-compute@developer.gserviceaccount.com`
   - `{PROJECT_NUMBER}@cloudbuild.gserviceaccount.com`

**Key roles needed:**
- Firebase Admin SDK → `Firebase Admin SDK Administrator Service Agent`
- Compute Service Account → `Editor` or `Cloud Run Invoker`
- Cloud Build → `Cloud Build Service Agent`

## Step-by-Step Debugging Process

### Local Development (localhost:3000)

```bash
# 1. Make sure you're using staging environment
cd Web
cp .env.staging .env.local

# 2. Start the dev server
npm run dev

# 3. Open browser to http://localhost:3000
# 4. Open DevTools (F12)
# 5. Try to log in
# 6. Check Console tab for errors
```

### Vercel Deployment (staging-freshwall.vercel.app)

```bash
# 1. Verify environment variables in Vercel dashboard
# Settings → Environment Variables → Preview

# 2. Make sure authorized domain includes your Vercel URL
# Firebase Console → Authentication → Settings → Authorized domains

# 3. Redeploy after any environment changes
git push origin staging  # or whatever triggers your deployment

# 4. Test the live site
# Open: https://staging-freshwall.vercel.app
# Open DevTools → Console
# Try to log in
```

## Common Issues & Solutions

| Symptom | Likely Cause | Solution |
|---------|--------------|----------|
| "auth/unauthorized-domain" | Domain not authorized | Add domain to Firebase Auth settings |
| "auth/operation-not-allowed" | Provider disabled | Enable Email/Google in Firebase Auth |
| Google popup closes immediately | OAuth not configured | Set up OAuth consent screen |
| 403 from cloudfunctions.net | Cloud Run permissions | Run fix-callable-function-auth.sh |
| Login works but user can't access data | Firestore rules | Check Firestore security rules |
| Login works but Cloud Functions fail | Missing auth token | Check if Firebase SDK is passing auth correctly |

## Testing Checklist

- [ ] Authorized domains includes your deployment URL
- [ ] Email/Password provider is enabled
- [ ] Google provider is enabled (if using Google sign-in)
- [ ] OAuth consent screen is configured
- [ ] Environment variables match Firebase console
- [ ] Cloud Run permissions are set for callable functions
- [ ] Test user exists in Firebase Auth
- [ ] Browser console shows no errors
- [ ] Network tab shows successful auth requests
- [ ] Firestore rules allow authenticated access

## Get Help

If you're still stuck, gather this information:

1. **Exact error message** from browser console
2. **Which authentication method** (Email or Google)
3. **Environment** (localhost or Vercel)
4. **Network tab screenshot** showing failed requests
5. **Firebase Auth settings screenshot**

Then check:
- Firebase documentation: https://firebase.google.com/docs/auth/web/start
- Stack Overflow with the specific error code
- Firebase Support if you have a paid plan

---

**Pro Tip:** Test with a fresh incognito window to avoid cached credentials and old authentication states.
