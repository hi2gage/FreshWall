# Vercel Environment Variables Setup

Quick guide to configure your environment variables in Vercel Dashboard.

## Important: How Vercel Gets Environment Variables

Vercel does **NOT** read `.env` files from your repository. You must configure them in:
- **Vercel Dashboard** (easiest)
- **Vercel CLI** (for automation)

## Current Setup

Your `.env` files are gitignored (for security). They serve as:
- ✅ Templates/reference for what to configure
- ✅ Local development configuration
- ❌ NOT used by Vercel deployments

## Step 1: Access Vercel Dashboard

1. Go to: https://vercel.com/dashboard
2. Find and click your FreshWall Web project
3. Go to **Settings** tab
4. Click **Environment Variables** in left sidebar

## Step 2: Add Production Variables

Click **Add New** for each variable below:

### Production Firebase Config (from your .env.local)

For each variable:
- **Environment**: Check ✅ **Production** only
- **Value**: Copy from your `.env.local`

```env
NEXT_PUBLIC_FIREBASE_API_KEY=AIzaSyAlRKu6Y2-c3AWcCvCca2PHfNezIDMO7-U
NEXT_PUBLIC_FIREBASE_AUTH_DOMAIN=freshwall-30afe.firebaseapp.com
NEXT_PUBLIC_FIREBASE_PROJECT_ID=freshwall-30afe
NEXT_PUBLIC_FIREBASE_STORAGE_BUCKET=freshwall-30afe.firebasestorage.app
NEXT_PUBLIC_FIREBASE_MESSAGING_SENDER_ID=526475481183
NEXT_PUBLIC_FIREBASE_APP_ID=1:526475481183:web:0efa808e6471664c93cbea
NEXT_PUBLIC_FIREBASE_MEASUREMENT_ID=G-E92WKGYRWB
NEXT_PUBLIC_ENVIRONMENT=production
NEXT_PUBLIC_BASE_URL=https://freshwall.app
```

### Optional: Stripe (Production)
```env
NEXT_PUBLIC_STRIPE_PUBLISHABLE_KEY=pk_live_...
STRIPE_SECRET_KEY=sk_live_...
STRIPE_WEBHOOK_SECRET=whsec_...
```

## Step 3: Get Staging Firebase Config

You need to get Firebase config for your staging project (`freshwall-staging`):

### Method 1: Firebase Console

1. Go to: https://console.firebase.google.com/
2. Select **freshwall-staging** project
3. Click ⚙️ (Settings) → **Project settings**
4. Scroll to **Your apps** section
5. If no web app exists:
   - Click **Add app** → **Web** (</>)
   - Register app with nickname (e.g., "FreshWall Web Staging")
6. Copy the `firebaseConfig` values

### Method 2: Firebase CLI

```bash
cd Firebase
firebase use staging
firebase apps:sdkconfig web
```

## Step 4: Add Staging Variables

In Vercel Dashboard, add these variables:

For each variable:
- **Environment**: Check ✅ **Preview** only (this includes staging branch)
- **Value**: Use staging Firebase config from Step 3

```env
NEXT_PUBLIC_FIREBASE_API_KEY=your_staging_api_key
NEXT_PUBLIC_FIREBASE_AUTH_DOMAIN=freshwall-staging.firebaseapp.com
NEXT_PUBLIC_FIREBASE_PROJECT_ID=freshwall-staging
NEXT_PUBLIC_FIREBASE_STORAGE_BUCKET=freshwall-staging.firebasestorage.app
NEXT_PUBLIC_FIREBASE_MESSAGING_SENDER_ID=473800449577
NEXT_PUBLIC_FIREBASE_APP_ID=your_staging_app_id
NEXT_PUBLIC_ENVIRONMENT=staging
NEXT_PUBLIC_BASE_URL=https://staging.freshwall.app
```

### Optional: Stripe (Staging - use test keys)
```env
NEXT_PUBLIC_STRIPE_PUBLISHABLE_KEY=pk_test_...
STRIPE_SECRET_KEY=sk_test_...
STRIPE_WEBHOOK_SECRET=whsec_...
```

## Step 5: Redeploy

After adding environment variables:

1. Go to **Deployments** tab in Vercel
2. Find the latest staging deployment
3. Click **⋯** (three dots) → **Redeploy**

Or push a new commit:
```bash
git commit --allow-empty -m "chore: trigger redeploy with new env vars"
git push origin staging
```

## Option 2: Using Vercel CLI

### Install Vercel CLI:
```bash
npm install -g vercel
```

### Link your project:
```bash
cd Web
vercel link
```

### Add variables via CLI:

```bash
# Add production variable
vercel env add NEXT_PUBLIC_FIREBASE_PROJECT_ID production
# Paste value when prompted: freshwall-30afe

# Add preview variable
vercel env add NEXT_PUBLIC_FIREBASE_PROJECT_ID preview
# Paste value when prompted: freshwall-staging

# Add development variable (optional)
vercel env add NEXT_PUBLIC_FIREBASE_PROJECT_ID development
# Paste value when prompted: freshwall-staging
```

### View all environment variables:
```bash
vercel env ls
```

### Pull environment variables to local:
```bash
vercel env pull .env.vercel.local
```

## Verification

### Check if variables are set:

1. Go to Vercel Dashboard → Your Project → Settings → Environment Variables
2. You should see all variables listed with their scopes

### Test in deployment:

1. Create a test page that displays env vars (only for debugging):

```typescript
// pages/api/test-env.ts
export default function handler(req, res) {
  res.status(200).json({
    projectId: process.env.NEXT_PUBLIC_FIREBASE_PROJECT_ID,
    environment: process.env.NEXT_PUBLIC_ENVIRONMENT,
    // Don't expose sensitive keys!
  });
}
```

2. Visit: `https://staging.freshwall.app/api/test-env`
3. Verify it shows staging values
4. Visit: `https://freshwall.app/api/test-env`
5. Verify it shows production values
6. **Delete this test endpoint after verification!**

## Common Issues

### Variables not updating

**Solution:**
- Environment variables only apply to NEW deployments
- Redeploy after changing variables
- Check you selected the correct scope (Production vs Preview)

### Wrong values in deployment

**Solution:**
- Check variable scope matches the branch
- Staging branch should use **Preview** scope
- Main branch should use **Production** scope

### Sensitive values exposed

**Solution:**
- Never log or display API keys/secrets in production
- Use `NEXT_PUBLIC_` prefix only for client-side variables
- Server-side secrets (like `STRIPE_SECRET_KEY`) don't need `NEXT_PUBLIC_`

### Can't find environment variables

**Solution:**
- Check you're logged into correct Vercel account
- Verify you have access to the project
- Run `vercel whoami` to check logged-in user

## Security Best Practices

✅ **DO:**
- Use different Firebase projects for staging/production
- Use test Stripe keys for staging
- Rotate API keys regularly
- Use Preview scope for staging
- Use Production scope for production

❌ **DON'T:**
- Commit `.env` files to git
- Share API keys in Slack/email
- Use production credentials in staging
- Expose secret keys client-side
- Log sensitive values

## Quick Reference

### Vercel Environment Scopes

| Scope | When Used | Example Branch |
|-------|-----------|----------------|
| **Production** | `main` branch only | `main` |
| **Preview** | All other branches | `staging`, `feature/*` |
| **Development** | Local `vercel dev` | N/A |

### Your Setup

| Environment | Branch | Scope | Firebase Project | Domain |
|-------------|--------|-------|------------------|--------|
| Production | `main` | Production | `freshwall-30afe` | `freshwall.app` |
| Staging | `staging` | Preview | `freshwall-staging` | `staging.freshwall.app` |
| Features | `feature/*` | Preview | `freshwall-staging` | Auto-generated |

## Next Steps

1. ✅ Add production variables with **Production** scope
2. ✅ Get staging Firebase config from Console or CLI
3. ✅ Add staging variables with **Preview** scope
4. ✅ Redeploy to apply new variables
5. ✅ Test both environments
6. ✅ Delete any test/debug endpoints

---

**Dashboard**: https://vercel.com/dashboard
**Last Updated**: January 2025
