# Vercel Staging Setup with Custom Domain

This guide shows you how to set up `staging.freshwall.app` as your staging environment using a single Vercel project.

## Overview

Vercel supports multiple environments in a single project:

- **Production**: `main` branch → `freshwall.app`
- **Preview (Staging)**: `staging` branch → `staging.freshwall.app`
- **Preview (Features)**: Other branches → Auto-generated URLs

## Step 1: Create Staging Branch

```bash
# Create and push staging branch
git checkout -b staging
git push origin staging
```

Vercel will automatically create a preview deployment for this branch.

## Step 2: Configure DNS for Staging Subdomain

### In Your DNS Provider (where freshwall.app is registered)

Add a CNAME record:

```
Type:  CNAME
Name:  staging
Value: cname.vercel-dns.com
TTL:   3600 (or automatic)
```

**What this does**: Points `staging.freshwall.app` to Vercel

## Step 3: Add Custom Domain in Vercel

### Via Vercel Dashboard:

1. Go to [Vercel Dashboard](https://vercel.com/dashboard)
2. Select your FreshWall Web project
3. Go to **Settings** → **Domains**
4. Click **Add Domain**
5. Enter: `staging.freshwall.app`
6. Vercel will verify DNS configuration
7. Once verified, click **Assign to Branch**
8. Select **staging** branch
9. Click **Assign**

### Via Vercel CLI (Alternative):

```bash
cd Web

# Add the domain
vercel domains add staging.freshwall.app

# Assign to staging branch
vercel domains assign staging.freshwall.app staging
```

## Step 4: Configure Environment Variables

In Vercel Dashboard → Settings → Environment Variables:

### For Preview Deployments (Staging):

Set these variables with **Preview** scope:

```env
NEXT_PUBLIC_FIREBASE_PROJECT_ID=freshwall-staging
NEXT_PUBLIC_FIREBASE_API_KEY=your_staging_api_key
NEXT_PUBLIC_FIREBASE_AUTH_DOMAIN=freshwall-staging.firebaseapp.com
NEXT_PUBLIC_FIREBASE_STORAGE_BUCKET=freshwall-staging.appspot.com
NEXT_PUBLIC_FIREBASE_MESSAGING_SENDER_ID=473800449577
NEXT_PUBLIC_FIREBASE_APP_ID=your_staging_app_id
NEXT_PUBLIC_ENVIRONMENT=staging
NEXT_PUBLIC_BASE_URL=https://staging.freshwall.app
```

### For Production Deployments:

Set these variables with **Production** scope:

```env
NEXT_PUBLIC_FIREBASE_PROJECT_ID=freshwall-30afe
NEXT_PUBLIC_FIREBASE_API_KEY=your_production_api_key
NEXT_PUBLIC_FIREBASE_AUTH_DOMAIN=freshwall-30afe.firebaseapp.com
NEXT_PUBLIC_FIREBASE_STORAGE_BUCKET=freshwall-30afe.appspot.com
NEXT_PUBLIC_FIREBASE_MESSAGING_SENDER_ID=your_sender_id
NEXT_PUBLIC_FIREBASE_APP_ID=your_production_app_id
NEXT_PUBLIC_ENVIRONMENT=production
NEXT_PUBLIC_BASE_URL=https://freshwall.app
```

**Important**: Make sure each variable has the correct **scope**:
- **Preview** = Used for all preview deployments (including staging branch)
- **Production** = Used only for production (main branch)
- **Development** = Used for local development with `vercel dev`

## Step 5: Test Staging Deployment

```bash
# Push to staging branch
git checkout staging
git add .
git commit -m "test: staging deployment"
git push origin staging

# Vercel will automatically deploy to staging.freshwall.app
```

Check deployment status:
```bash
vercel ls
```

## Step 6: Configure Branch Protection (Optional but Recommended)

### In Vercel Dashboard:

1. Settings → Git
2. Under **Production Branch**, ensure `main` is selected
3. Under **Preview Branch Protection**, you can:
   - Enable password protection for preview deployments
   - Restrict by Vercel team members only
   - Allow public access

### Branch-Specific Settings:

You can configure staging branch to behave differently:
- Custom build commands
- Different environment variables
- Custom deployment settings

## Workflow After Setup

### Deploying to Staging:

```bash
# Make changes in feature branch
git checkout -b feature/new-thing
# ... make changes ...
git add .
git commit -m "feat: add new thing"

# Merge to staging for testing
git checkout staging
git merge feature/new-thing
git push origin staging

# Automatically deploys to: staging.freshwall.app
```

### Deploying to Production:

```bash
# After testing in staging
git checkout main
git merge staging
git push origin main

# Automatically deploys to: freshwall.app
```

## Alternative: Separate Vercel Projects

If you prefer complete isolation, you can create separate projects:

### Pros:
- Complete isolation between environments
- Different team permissions possible
- Separate billing/analytics

### Cons:
- More complex to manage
- Need to duplicate all settings
- Two places to update environment variables
- Two separate Git connections to manage

### Setup:
```bash
# In Web directory
vercel --scope your-team --name freshwall-staging

# This creates a new Vercel project
# Connect it to staging branch
# Add staging.freshwall.app domain to this project
```

## Recommended Architecture

**Use Single Project** unless you have specific requirements for isolation:

```
One Vercel Project: freshwall-web
├── Production Domain:  freshwall.app        (main branch)
├── Staging Domain:     staging.freshwall.app (staging branch)
└── Preview Domains:    auto-generated       (feature branches)
```

**Benefits:**
- ✅ Simpler to manage
- ✅ One place for all settings
- ✅ Automatic preview deployments
- ✅ Easy to promote deployments
- ✅ Unified analytics and logs
- ✅ Standard industry practice

## Environment Variable Management

### Best Practice:

Keep your env files synced:

```bash
# When you update staging config
cd Web

# Copy values to Vercel
# Use Vercel Dashboard or CLI:
vercel env pull .env.vercel.local
# This pulls current Vercel env vars

# Or push from file:
vercel env add NEXT_PUBLIC_FIREBASE_PROJECT_ID preview < value.txt
```

### Automation with Vercel CLI:

```bash
# List all environment variables
vercel env ls

# Add environment variable
vercel env add NEXT_PUBLIC_FIREBASE_PROJECT_ID

# Remove environment variable
vercel env rm NEXT_PUBLIC_FIREBASE_PROJECT_ID
```

## Troubleshooting

### Domain not working:

1. Check DNS propagation: `dig staging.freshwall.app`
2. Verify CNAME points to `cname.vercel-dns.com`
3. Wait up to 48 hours for DNS propagation (usually minutes)

### Wrong environment variables:

1. Check variable scope in Vercel Dashboard
2. Ensure **Preview** scope for staging
3. Redeploy after changing env vars

### Builds failing:

1. Check build logs in Vercel Dashboard
2. Verify all required env vars are set
3. Test build locally: `npm run build`

### Branch not deploying:

1. Ensure branch is pushed: `git push origin staging`
2. Check Vercel Git settings
3. Verify branch is not ignored in `vercel.json`

## Monitoring

### Check Deployment Status:

```bash
# Via CLI
vercel ls

# Via Dashboard
# Visit: https://vercel.com/dashboard
# See all deployments by branch
```

### View Logs:

```bash
# Real-time logs for a deployment
vercel logs [deployment-url]
```

### Analytics:

- Production analytics: Available in Vercel Dashboard
- Preview analytics: Available for each deployment

## Security Considerations

- Use different Firebase projects for staging/production
- Use test Stripe keys for staging
- Enable branch protection in GitHub
- Consider password protection for staging if needed
- Rotate API keys regularly

## Quick Reference

```bash
# Create staging branch
git checkout -b staging && git push origin staging

# Deploy to staging
git checkout staging && git push origin staging

# Deploy to production
git checkout main && git merge staging && git push origin main

# Check deployments
vercel ls

# Pull environment variables
vercel env pull
```

---

**Recommended Setup**: Single Vercel Project with branch-based deployments

**Last Updated**: January 2025
