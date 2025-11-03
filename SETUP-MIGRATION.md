# Quick Setup: Data Migration to Staging

Follow these steps to copy production team data to staging (including images).

## Step 1: Install gcloud CLI

```bash
brew install google-cloud-sdk
```

## Step 2: Authenticate with Google Cloud

This command will open a browser window for you to log in with your Google account (gage@freshwall.app):

```bash
gcloud auth application-default login
```

**Important:** Make sure you log in with an account that has access to BOTH:
- freshwall-30afe (production)
- freshwall-staging (staging)

## Step 3: Download Production Service Account Key (Optional)

You can download the production key if you want, but the script will also work with just gcloud authentication.

**If you want to use a service account key for production:**

1. Go to: https://console.firebase.google.com/project/freshwall-30afe/settings/serviceaccounts/adminsdk
2. Click "Generate new private key"
3. Save as: `Firebase/prod-service-account.json`

**Otherwise:** The script will automatically use your gcloud credentials.

## Step 4: Run the Migration

### Preview First (Dry Run - Recommended)

See what will be copied without making changes:

```bash
cd /Users/gage/Dev/startups/FreshWall
node Scripts/clone-firestore-data.js --team-id=4bn04KFSRcPvGbHXOV49 --dry-run
```

### Run the Real Migration

Copy everything including images:

```bash
node Scripts/clone-firestore-data.js --team-id=4bn04KFSRcPvGbHXOV49
```

Or skip images (faster):

```bash
node Scripts/clone-firestore-data.js --team-id=4bn04KFSRcPvGbHXOV49 --skip-images
```

---

## What This Copies

✅ Team data (name, code, settings)
✅ All users in the team
✅ All clients
✅ All incidents
✅ All before/after photos from Firebase Storage

---

## After Migration

Once the migration completes:

1. **Team Code:** The script will show you the team code
2. **Test in Staging:** Users need to create NEW accounts in staging (different Firebase Auth)
3. **Join Team:** Use the team code to join the migrated team
4. **Verify Data:** Check that clients, incidents, and photos all copied correctly

---

## Troubleshooting

### "Could not load the default credentials"

**Solution:** Run the authentication command again:
```bash
gcloud auth application-default login
```

### "Permission denied" errors

**Solution:** Make sure you're logged in with an account (gage@freshwall.app) that has:
- Owner or Editor role on freshwall-30afe
- Owner or Editor role on freshwall-staging

Check in:
- https://console.cloud.google.com/iam-admin/iam?project=freshwall-30afe
- https://console.cloud.google.com/iam-admin/iam?project=freshwall-staging

### Script fails during photo copying

**Solution:** Run with `--skip-images` to copy just the data, then manually copy photos later if needed.

---

## Security Note

The `gcloud auth application-default login` command stores your credentials in:
- `~/.config/gcloud/application_default_credentials.json`

This is safe and only stored locally on your machine. The script uses these credentials to authenticate as you when accessing Firebase.

---

**Ready?** Start with the dry-run command to preview what will be copied!
