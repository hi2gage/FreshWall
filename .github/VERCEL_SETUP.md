# Vercel GitHub Actions Setup

This guide explains how to configure Vercel and GitHub for automated deployments via GitHub Actions.

## Required GitHub Secrets

Add these secrets to your GitHub repository (Settings → Secrets and variables → Actions):

1. **`VERCEL_TOKEN`**
   - Go to https://vercel.com/account/tokens
   - Click "Create Token"
   - Name it "GitHub Actions"
   - Copy the token and add to GitHub secrets

2. **`VERCEL_ORG_ID`**
   - Run in your Web directory: `vercel project ls`
   - Or find in `.vercel/project.json` after running `vercel link`
   - Add the org ID to GitHub secrets

3. **`VERCEL_PROJECT_ID`**
   - Run in your Web directory: `vercel project ls`
   - Or find in `.vercel/project.json` after running `vercel link`
   - Add the project ID to GitHub secrets

### Get Vercel IDs

```bash
cd Web
vercel link  # Link to your Vercel project
cat .vercel/project.json  # View the IDs
```

The output will look like:
```json
{
  "orgId": "team_xxxxxxxxxxxxx",
  "projectId": "prj_xxxxxxxxxxxxx"
}
```

## Vercel Configuration Changes

### 1. Disable Automatic Git Deployments

Since GitHub Actions will handle deployments, you need to disable Vercel's automatic deployments:

**Option A: Via Vercel Dashboard**
1. Go to your project settings: https://vercel.com/[your-team]/freshwall/settings/git
2. Under "Git" → "Automatic Deployments"
3. **Uncheck** "Automatically deploy commits pushed to matching branches"
4. This prevents double-deployments

**Option B: Keep Git Integration but Ignore Pushes**
1. Keep the Git integration enabled (for PR previews if you want)
2. Configure Production branch to "None" or "Ignore"
3. Let GitHub Actions handle all deployments

### 2. Environment Configuration (Optional)

The workflow will use your existing Vercel environments:
- **Preview** → staging.freshwall.app (deploys from `main`)
- **Production** → www.freshwall.app (deploys from `web/*` tags)

You can keep your existing environment setup in Vercel, but ensure:
- `staging.freshwall.app` is assigned to Preview environment
- `www.freshwall.app` is assigned to Production environment

## How It Works

### Staging Deployments (Preview)
```bash
# Triggered automatically when merged to main
git push origin main
# → GitHub Actions deploys to Vercel Preview
# → Accessible at https://staging.freshwall.app
```

### Production Deployments
```bash
# Create and push a web tag
git tag web/v1.0.0
git push origin web/v1.0.0
# → GitHub Actions deploys to Vercel Production
# → Accessible at https://www.freshwall.app
```

Or use the release script:
```bash
./Scripts/release-platform.sh
# Select "Web" → choose version → creates tag and deploys
```

## Verification

After setting up:

1. **Test Staging Deploy:**
   ```bash
   # Make a small change to Web/
   git checkout -b test/vercel-deploy
   # Edit a file
   git commit -am "Test Vercel deployment"
   git push origin test/vercel-deploy
   # Create PR to main, merge it
   # → Should deploy to staging.freshwall.app
   ```

2. **Test Production Deploy:**
   ```bash
   git tag web/v0.0.1-test
   git push origin web/v0.0.1-test
   # → Should deploy to www.freshwall.app
   # Delete the test tag after: git push --delete origin web/v0.0.1-test
   ```

## Troubleshooting

### "Error: Failed to create deployment"
- Verify `VERCEL_TOKEN` is valid and not expired
- Check token has appropriate permissions

### "Error: Forbidden"
- Verify `VERCEL_ORG_ID` and `VERCEL_PROJECT_ID` are correct
- Ensure token has access to the team/organization

### Domain not updating
- Check domain is properly configured in Vercel project settings
- Verify `staging.freshwall.app` and `www.freshwall.app` are added as domains
- Wait a few minutes for DNS propagation

### Workflow not triggering
- Ensure paths filter includes your changes: `Web/**`
- Check if workflow file is on the target branch (main)
- Verify GitHub Actions are enabled in repository settings
