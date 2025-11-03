# Clone Production Data to Staging (WITH IMAGES!)

Complete guide to copy your production Firestore data AND Storage images to staging for testing.

## Quick Start (Recommended Path)

### Step 1: Install Dependencies

```bash
cd Firebase
npm install firebase-admin
```

### Step 2: Download Service Account Keys

**For Production:**
1. Go to: https://console.firebase.google.com/project/freshwall-30afe/settings/serviceaccounts/adminsdk
2. Click **Generate new private key**
3. Save as: `Firebase/prod-service-account.json`

**For Staging:**
1. Go to: https://console.firebase.google.com/project/freshwall-staging/settings/serviceaccounts/adminsdk
2. Click **Generate new private key**
3. Save as: `Firebase/staging-service-account.json`

**IMPORTANT:** These files contain secrets! They're already in `.gitignore` but double-check they're not staged:
```bash
git status
```

### Step 3: First, Do a Dry Run

Preview what will be copied **without making changes**:

```bash
cd /Users/gage/Dev/startups/FreshWall
node Scripts/clone-firestore-data.js --team-id=4bn04KFSRcPvGbHXOV49 --dry-run
```

This shows you:
- Team name and details
- Number of users, clients, incidents
- Number of photos
- Preview of the data

### Step 4: Run the Real Migration

**With images** (recommended for testing):
```bash
node Scripts/clone-firestore-data.js --team-id=4bn04KFSRcPvGbHXOV49
```

**Without images** (faster, if you don't need photos):
```bash
node Scripts/clone-firestore-data.js --team-id=4bn04KFSRcPvGbHXOV49 --skip-images
```

This will copy:
- Team data
- All clients
- All incidents
- All users
- All invite codes
- **All incident photos** (before/after images from Storage)

### Step 4: Clean Up (Optional)

After cloning, you can delete the service account files for security:
```bash
rm Firebase/prod-service-account.json
rm Firebase/staging-service-account.json
```

## Option 2: Firebase CLI Export/Import

### Prerequisites:

```bash
# Make sure you have Firebase CLI
npm install -g firebase-tools

# Login
firebase login
```

### Set Up Cloud Storage Access:

**Production Project:**
```bash
firebase use production

# Grant staging service account access to production bucket
# In Firebase Console → Storage → Rules, temporarily allow:
# allow read, write: if true;
```

### Export from Production:

```bash
firebase use production
firebase firestore:export gs://freshwall-30afe.appspot.com/firestore-backups/$(date +%Y%m%d)
```

### Import to Staging:

```bash
firebase use staging
firebase firestore:import gs://freshwall-30afe.appspot.com/firestore-backups/YYYYMMDD
```

(Replace YYYYMMDD with the actual date folder)

## Option 3: Manual Copy (Small Datasets Only)

If you only have a few records, you can manually recreate them in staging through the app or Firebase Console.

## What Gets Copied?

✅ All team data
✅ All clients
✅ All incidents (including photos metadata)
✅ All users
✅ All invite codes

❌ **Storage files (photos) are NOT copied**

## Copying Storage Files (Photos)

If you need to copy actual photos:

### Using gsutil:

```bash
# Install Google Cloud SDK
brew install google-cloud-sdk

# Authenticate
gcloud auth login

# Copy storage bucket
gsutil -m cp -r \
  gs://freshwall-30afe.appspot.com/teams \
  gs://freshwall-staging.appspot.com/
```

### Using Firebase Console:

1. Download photos from production Storage
2. Upload to staging Storage
3. Maintain same path structure

## Security Notes

⚠️ **Service Account Keys:**
- Keep them secret, keep them safe
- Never commit to git
- Delete after use
- Rotate regularly

⚠️ **Data Privacy:**
- Staging data should be treated as sensitive
- Don't use real customer data if possible
- Consider anonymizing data

⚠️ **Firestore Rules:**
- Test that staging rules work correctly
- Don't accidentally expose staging data

## Troubleshooting

### "Permission denied" error

**Solution:** Make sure service account keys are downloaded correctly and paths are correct in the script.

### "Collection not found" error

**Solution:** Verify production has data in the collections you're trying to copy.

### Script hangs or times out

**Solution:** You may have a lot of data. Consider:
- Running script on a server
- Copying one team at a time
- Using Firebase CLI export/import instead

### Photos not showing in staging

**Solution:** The script only copies Firestore data, not Storage files. Use `gsutil` to copy storage separately.

## Automating Regular Syncs

Create a cron job or GitHub Action to sync production → staging weekly:

```yaml
# .github/workflows/sync-staging.yml
name: Sync Production to Staging

on:
  schedule:
    - cron: '0 0 * * 0' # Every Sunday at midnight
  workflow_dispatch: # Manual trigger

jobs:
  sync:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v3
      - uses: actions/setup-node@v3
      - name: Install dependencies
        run: cd Firebase && npm install firebase-admin
      - name: Run clone script
        env:
          PROD_SERVICE_ACCOUNT: ${{ secrets.PROD_SERVICE_ACCOUNT }}
          STAGING_SERVICE_ACCOUNT: ${{ secrets.STAGING_SERVICE_ACCOUNT }}
        run: node Scripts/clone-firestore-data.js
```

## Best Practices

1. **Schedule regular syncs** (weekly/monthly)
2. **Anonymize sensitive data** in staging
3. **Test thoroughly** in staging before production
4. **Keep staging small** - delete old test data regularly
5. **Document test scenarios** that require specific data

---

**Last Updated**: January 2025
