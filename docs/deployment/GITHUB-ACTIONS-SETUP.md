# GitHub Actions Setup Guide

This project uses GitHub Actions for automated deployments and PR management.

## Workflows

### 1. Auto-create PR to Main
**File:** `.github/workflows/auto-promote-to-main.yml`

**What it does:**
- Triggers when a PR is merged into `staging`
- Automatically creates a new PR from `staging` → `main`
- Includes changelog of all commits
- Adds production deployment checklist

**No setup required** - works out of the box with GitHub's default `GITHUB_TOKEN`.

---

### 2. Deploy Functions to Staging
**File:** `.github/workflows/deploy-staging-functions.yml`

**What it does:**
- Triggers when code is pushed to `staging` branch
- Only runs if Firebase functions, rules, or indexes changed
- Automatically deploys to `freshwall-staging` project
- Can also be triggered manually

**Setup required:** Firebase CI token (see below)

---

## Setup Instructions

### Step 1: Generate Firebase CI Token

Run this command in your terminal:

```bash
firebase login:ci
```

This will:
1. Open a browser for you to authenticate
2. Generate a CI token
3. Display the token in the terminal

**Copy this token** - you'll need it in the next step.

### Step 2: Add GitHub Secret

1. Go to your GitHub repository: https://github.com/hi2gage/FreshWall
2. Click **Settings** → **Secrets and variables** → **Actions**
3. Click **New repository secret**
4. Name: `FIREBASE_TOKEN`
5. Value: Paste the token from Step 1
6. Click **Add secret**

### Step 3: Test the Workflow

**Test auto-deployment:**
```bash
# Make a change to a function
echo "// test" >> Firebase/functions/src/index.ts

# Commit and push
git add Firebase/functions/src/index.ts
git commit -m "test: trigger deploy workflow"
git push origin staging
```

Go to GitHub → Actions tab to watch the deployment!

**Test manual deployment:**
1. Go to: https://github.com/hi2gage/FreshWall/actions/workflows/deploy-staging-functions.yml
2. Click **Run workflow**
3. Select `staging` branch
4. Click **Run workflow**

---

## Workflow Behavior

### When you merge a PR to staging:

1. **Auto-promote workflow** creates a PR to main ✅
2. **Deploy workflow** deploys functions to staging ✅
3. **Vercel** automatically deploys web app to staging ✅

### When you merge the promotion PR to main:

1. **Vercel** automatically deploys web app to production ✅
2. **You need to manually** deploy functions to production:
   ```bash
   firebase deploy --only functions --project production
   ```

---

## Why Manual for Production?

Firebase Functions deployment to **production** is intentionally manual because:
- ✅ Extra safety layer - prevents accidental production deploys
- ✅ Allows you to coordinate with iOS releases
- ✅ Gives you control over timing (deploy during low-traffic hours)
- ✅ You can test staging thoroughly first

**Future enhancement:** We could add a manual GitHub Action for production deployment too!

---

## Troubleshooting

### "Error: HTTP Error: 401, Request had invalid authentication credentials"

**Solution:** Your `FIREBASE_TOKEN` secret is missing or invalid. Regenerate it:
```bash
firebase login:ci
```
Then update the GitHub secret.

### "Error: Could not load Firebase project"

**Solution:** Make sure the project ID in the workflow matches your Firebase project:
- Should be: `freshwall-staging`
- Check in: `Firebase/.firebaserc`

### Workflow doesn't trigger

**Solution:**
- Make sure you're pushing to the `staging` branch
- Check that files in `Firebase/functions/**` were actually changed
- Look at the **Actions** tab in GitHub for error messages

---

## Files Modified

This setup added:
- `.github/workflows/auto-promote-to-main.yml`
- `.github/workflows/deploy-staging-functions.yml`
- `GITHUB-ACTIONS-SETUP.md` (this file)

---

**Ready to test?** Follow Step 3 above to trigger your first automated deployment! 🚀
