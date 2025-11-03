# FreshWall Staging Environment - Quick Setup Guide

This guide will help you set up and use your staging environment for FreshWall.

## What's Been Set Up

You now have a multi-environment deployment system:

```
Development (local) → Staging → Production
```

### Firebase Projects
- **Staging**: `freshwall-staging` (Project #473800449577)
- **Production**: `freshwall-30afe` (existing)

### Configuration Files Created

```
Firebase/
├── .firebaserc (configured with staging/production aliases)
└── functions/
    ├── .env.staging (needs your actual keys)
    └── .env.production (needs your actual keys)

Web/
├── .env.staging (needs your actual keys)
└── .env.production (needs your actual keys)

Scripts/
└── deploy-firebase.sh (interactive deployment script)

DEPLOYMENT.md (comprehensive deployment guide)
```

## Step 1: Get Firebase Configuration for Staging

You need to get the Firebase config for your staging project:

### Option A: Firebase Console (Easiest)

1. Go to [Firebase Console](https://console.firebase.google.com/)
2. Select `freshwall-staging` project
3. Click the gear icon (⚙️) → Project Settings
4. Scroll down to "Your apps"
5. If you don't have a web app, click "Add app" → Web (</>) icon
6. Copy the `firebaseConfig` object values

### Option B: Firebase CLI

```bash
cd Firebase
firebase use staging
firebase apps:sdkconfig web
```

## Step 2: Configure Environment Files

### Update Web Staging Config

Edit `Web/.env.staging` with your actual values:

```bash
cd Web
nano .env.staging  # or use your preferred editor
```

Replace the placeholder values with your staging Firebase config from Step 1.

### Update Web Production Config

Edit `Web/.env.production` with your production values:

```bash
nano .env.production
```

### Update Firebase Functions Configs

If you're using any secrets in Cloud Functions:

```bash
cd Firebase/functions
nano .env.staging
nano .env.production
```

## Step 3: Set Up Vercel Environments

### 1. Go to Vercel Dashboard
Visit: https://vercel.com/dashboard

### 2. Select Your Project
Find and click on `freshwall-web` (or your web project name)

### 3. Configure Environment Variables

Go to **Settings** → **Environment Variables**

For **Staging** (Preview environments):
- Set environment scope to: **Preview**
- Add variables from `Web/.env.staging`

For **Production**:
- Set environment scope to: **Production**
- Add variables from `Web/.env.production`

Example variables to add:
- `NEXT_PUBLIC_FIREBASE_PROJECT_ID`
- `NEXT_PUBLIC_FIREBASE_API_KEY`
- `NEXT_PUBLIC_FIREBASE_AUTH_DOMAIN`
- `NEXT_PUBLIC_ENVIRONMENT`
- etc.

## Step 4: Test the Setup

### Test Firebase Deployment

```bash
cd Firebase

# Test staging
firebase use staging
npm run build
firebase deploy

# Test production (be careful!)
firebase use production
npm run build
# Don't deploy to production yet if you're still testing!
```

### Test Web Deployment

```bash
cd Web

# Create a staging branch
git checkout -b staging
git push origin staging

# This will trigger a Vercel preview deployment
# Check Vercel dashboard for the preview URL
```

## Daily Usage

### Deploy to Staging

```bash
# Quick command
cd Firebase && firebase use staging && npm run build && firebase deploy

# OR use the helper script
./Scripts/deploy-firebase.sh
# Choose option 1 (Staging)
```

### Deploy to Production

```bash
# For iOS app
./Scripts/release.sh

# For Firebase backend
./Scripts/deploy-firebase.sh
# Choose option 2 (Production)

# For Web (automatic on merge to main)
git checkout main
git merge staging
git push origin main
```

### Check Which Environment You're On

```bash
cd Firebase
firebase use
```

### Switch Between Environments

```bash
firebase use staging      # Switch to staging
firebase use production   # Switch to production
```

## Git Branching Strategy

Recommended branch structure:

```
main (production)
  │
  └── staging (pre-production)
       │
       └── feature/your-feature (development)
```

### Workflow:

1. Create feature branch from `staging`:
   ```bash
   git checkout staging
   git pull origin staging
   git checkout -b feature/new-feature
   ```

2. Develop and push feature:
   ```bash
   git add .
   git commit -m "feat: add new feature"
   git push origin feature/new-feature
   ```

3. Merge to staging for testing:
   ```bash
   git checkout staging
   git merge feature/new-feature
   git push origin staging

   # Deploy to staging
   cd Firebase
   firebase use staging
   npm run build
   firebase deploy
   ```

4. After testing, merge to main for production:
   ```bash
   git checkout main
   git merge staging

   # Run release script for iOS versioning
   ./Scripts/release.sh

   # Deploy Firebase to production
   cd Firebase
   firebase use production
   npm run build
   firebase deploy
   ```

## iOS App Configuration (Future Setup)

To fully support staging/production for iOS:

1. Create separate `GoogleService-Info.plist` files:
   - Download from Firebase Console → Project Settings
   - Save as `GoogleService-Info-Staging.plist`
   - Save as `GoogleService-Info-Production.plist`

2. Create Xcode build configurations:
   - Duplicate Release configuration
   - Rename to "Staging"

3. Add build phase to copy correct plist based on configuration

4. Configure Xcode Cloud workflows:
   - Staging: Trigger on `staging` branch → TestFlight internal
   - Production: Trigger on `v*` tags → TestFlight → App Store

## Troubleshooting

### "Permission denied" when deploying Firebase

Make sure you have access to both projects:
```bash
firebase login
firebase projects:list
```

### Vercel not picking up environment variables

- Check Environment Variables in Vercel Dashboard
- Make sure scope is set correctly (Preview vs Production)
- Redeploy after changing variables

### Wrong Firebase project being used

Check and switch:
```bash
firebase use
firebase use staging  # or production
```

### Environment files not being ignored

Make sure `.gitignore` includes:
```
.env
.env.staging
.env.production
.env*.local
```

Check what's being tracked:
```bash
git status
```

If env files show up, remove them:
```bash
git rm --cached Web/.env.staging
git rm --cached Web/.env.production
git commit -m "Remove env files from git"
```

## Next Steps

1. **Complete environment configuration** (Steps 1-3 above)
2. **Test staging deployment** with a small change
3. **Set up monitoring** for both environments
4. **Document any custom deployment steps** for your team
5. **Create runbooks** for common operations

## Quick Commands Reference

```bash
# Switch Firebase environment
firebase use staging
firebase use production

# Deploy Firebase (interactive)
./Scripts/deploy-firebase.sh

# Deploy Firebase (manual)
cd Firebase
firebase use staging
npm run build
firebase deploy

# Release new iOS version
./Scripts/release.sh

# Check current git branch
git branch

# See deployment logs
firebase functions:log --only functionName

# See Firestore indexes
firebase firestore:indexes
```

## Security Reminders

- Never commit `.env` files to git
- Use different API keys for staging and production
- Rotate keys regularly
- Use Firebase App Check in production
- Review security rules before deploying
- Test in staging before production

## Resources

- [Full Deployment Guide](./DEPLOYMENT.md)
- [Firebase Console - Staging](https://console.firebase.google.com/project/freshwall-staging)
- [Firebase Console - Production](https://console.firebase.google.com/project/freshwall-30afe)
- [Vercel Dashboard](https://vercel.com/dashboard)

---

**Need help?** Check [DEPLOYMENT.md](./DEPLOYMENT.md) for detailed information.

**Last Updated**: January 2025
