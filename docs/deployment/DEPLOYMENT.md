# FreshWall Deployment Guide

This guide covers the multi-environment deployment strategy for FreshWall (iOS, Web, Firebase).

## Environment Strategy

### Environments

1. **Development** - Local development with Firebase emulators
2. **Staging** - Pre-production testing environment
3. **Production** - Live production environment

### Architecture Overview

```
┌─────────────────────────────────────────────────────┐
│                    Git Repository                    │
├─────────────────────────────────────────────────────┤
│  main branch        → Production deployments         │
│  staging branch     → Staging deployments            │
│  feature/* branches → Preview/development            │
└─────────────────────────────────────────────────────┘
           │
           ├──────────────────┬──────────────────┬─────────────────
           │                  │                  │
    ┌──────▼──────┐   ┌──────▼──────┐   ┌──────▼──────┐
    │   iOS App   │   │   Web App   │   │  Firebase   │
    │   (Xcode    │   │  (Vercel)   │   │  Backend    │
    │    Cloud)   │   │             │   │             │
    └──────┬──────┘   └──────┬──────┘   └──────┬──────┘
           │                  │                  │
    Staging │ Production Staging │ Production Staging │ Production
    TestFlight AppStore  Preview   Production Project  Project
```

## Firebase Backend Setup

### Projects

- **Staging**: `freshwall-staging` (to be created)
- **Production**: `freshwall-30afe` (existing)

### Setup Multiple Projects

```bash
cd Firebase

# Add staging project
firebase use --add
# Select/create freshwall-staging project
# Alias: staging

# Add production project (if not already added)
firebase use --add
# Select freshwall-30afe
# Alias: production

# Switch between environments
firebase use staging      # For staging
firebase use production   # For production
```

### Environment-Specific Configuration

Create `.env.staging` and `.env.production` files in `Firebase/functions/`:

```bash
# Firebase/functions/.env.staging
ENVIRONMENT=staging
LOG_LEVEL=debug

# Firebase/functions/.env.production
ENVIRONMENT=production
LOG_LEVEL=info
```

### Deployment

```bash
# Deploy to staging
firebase use staging
npm run build
firebase deploy

# Deploy to production
firebase use production
npm run build
firebase deploy
```

## Web App (Next.js) Setup

### Vercel Configuration

Vercel automatically creates preview deployments for each branch:

- **Production**: `main` branch → `freshwall.com`
- **Staging**: `staging` branch → `staging-freshwall.vercel.app`
- **Preview**: Feature branches → `freshwall-git-{branch}.vercel.app`

### Environment Variables

Configure in Vercel dashboard for each environment:

**Staging Environment**:
```env
NEXT_PUBLIC_FIREBASE_PROJECT_ID=freshwall-staging
NEXT_PUBLIC_FIREBASE_API_KEY=...
NEXT_PUBLIC_FIREBASE_AUTH_DOMAIN=freshwall-staging.firebaseapp.com
NEXT_PUBLIC_ENVIRONMENT=staging
```

**Production Environment**:
```env
NEXT_PUBLIC_FIREBASE_PROJECT_ID=freshwall-30afe
NEXT_PUBLIC_FIREBASE_API_KEY=...
NEXT_PUBLIC_FIREBASE_AUTH_DOMAIN=freshwall-30afe.firebaseapp.com
NEXT_PUBLIC_ENVIRONMENT=production
```

### Deployment Workflow

1. **Automatic on Git Push**: Vercel detects pushes and deploys automatically
2. **Manual Deploy**: Via Vercel CLI or dashboard

## iOS App Setup

### Build Configurations

Create Xcode build configurations:

1. **Debug** - Local development
2. **Staging** - Staging environment
3. **Release** - Production environment

### Firebase Configuration Per Environment

Use separate `GoogleService-Info.plist` files:

- `GoogleService-Info-Staging.plist`
- `GoogleService-Info-Production.plist`

Configure build phases to copy the correct file based on configuration.

### Xcode Cloud Workflows

Create workflows for:

1. **Staging Builds**:
   - Trigger: Push to `staging` branch
   - Destination: TestFlight (internal testing)
   - Build configuration: Staging

2. **Production Builds**:
   - Trigger: Git tags matching `v*.*.*`
   - Destination: TestFlight (external testing) → App Store
   - Build configuration: Release

## Release Workflow

### Feature Development

```bash
# 1. Create feature branch
git checkout -b feature/my-feature

# 2. Develop and test locally with emulators
cd Firebase && firebase emulators:start
cd Web && npm run dev

# 3. Commit and push
git add .
git commit -m "feat: add my feature"
git push origin feature/my-feature

# 4. Create PR to staging branch
```

### Staging Release

```bash
# 1. Merge PR to staging
git checkout staging
git merge feature/my-feature

# 2. Deploy to staging (automatic for Web via Vercel)
# Manual for Firebase:
cd Firebase
firebase use staging
npm run build
firebase deploy

# 3. Test in staging environment
# - iOS: TestFlight staging build
# - Web: staging-freshwall.vercel.app
# - Backend: freshwall-staging.firebaseapp.com

# 4. Push staging branch
git push origin staging
```

### Production Release

```bash
# 1. Merge staging to main
git checkout main
git merge staging

# 2. Run release script for iOS versioning
./Scripts/release.sh
# Choose version type (patch/minor/major)

# This script will:
# - Update iOS version numbers
# - Create git commit
# - Create and push git tag (e.g., v1.2.5)
# - Push to remote

# 3. Deploy Firebase to production
cd Firebase
firebase use production
npm run build
firebase deploy

# 4. Verify deployments
# - iOS: Check Xcode Cloud build
# - Web: Check Vercel production deployment
# - Firebase: Test production functions
```

## Environment-Specific Testing

### Staging Testing Checklist

- [ ] iOS app connects to staging Firebase project
- [ ] Web app uses staging Firebase configuration
- [ ] Cloud Functions work correctly
- [ ] Authentication flows work
- [ ] Data isolation from production
- [ ] Storage and image uploads work
- [ ] All features tested end-to-end

### Production Deployment Checklist

- [ ] Staging tests passed
- [ ] Firebase indexes deployed
- [ ] Security rules deployed
- [ ] Cloud Functions deployed
- [ ] iOS build uploaded to TestFlight
- [ ] Web deployment verified on Vercel
- [ ] Smoke tests on production
- [ ] Monitoring and alerts configured
- [ ] Rollback plan prepared

## Git Branch Strategy

```
main (production)
  └── staging
       └── feature/branch-name
```

- **main**: Production-ready code only
- **staging**: Integration and pre-production testing
- **feature/***: Active feature development
- **hotfix/***: Emergency production fixes (merge to main and staging)

## Rollback Procedures

### Firebase Functions

```bash
# List recent deployments
firebase functions:log

# Rollback to previous version
# (Deploy previous git commit)
git checkout v1.2.4
cd Firebase
firebase deploy --only functions
git checkout main
```

### Web App (Vercel)

1. Go to Vercel dashboard
2. Find previous deployment
3. Click "Promote to Production"

### iOS App

1. Use App Store Connect to revert to previous version
2. Or release hotfix version with fixed code

## Monitoring

### Production Monitoring

- **Firebase**: Functions logs, Firestore metrics, Auth activity
- **Vercel**: Web analytics, error tracking, performance metrics
- **App Store Connect**: Crash reports, user reviews, download metrics

### Staging Monitoring

- Manual testing logs
- Integration test results
- Performance benchmarks

## Cost Optimization

- Use Firebase Blaze plan (pay-as-you-go)
- Staging project with reduced quotas/limits
- Development with local emulators (free)
- Vercel Hobby plan for staging (if separate account)

## Security Considerations

- Never commit `.env` files
- Rotate API keys regularly
- Use different Firebase projects for environments
- Implement proper CORS policies
- Use App Check for production
- Regular security audits

## Quick Reference

### Deploy to Staging

```bash
# Firebase
cd Firebase && firebase use staging && npm run build && firebase deploy

# Web (automatic on push to staging branch)
git push origin staging
```

### Deploy to Production

```bash
# Full release
./Scripts/release.sh

# Firebase only
cd Firebase && firebase use production && npm run build && firebase deploy
```

### Switch Environments

```bash
# Firebase
firebase use staging
firebase use production

# Web (via branch)
git checkout staging    # Staging
git checkout main       # Production
```

---

**Last Updated**: January 2025
**Version**: 1.0.0
