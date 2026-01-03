# Update iOS Dev/Beta to Use Staging

Your iOS app's Dev configuration currently points to production. Here's how to fix it.

## Problem

`GoogleService-Info-Dev.plist` has:
```xml
<key>PROJECT_ID</key>
<string>freshwall-30afe</string>  ← Production!
```

It should be:
```xml
<key>PROJECT_ID</key>
<string>freshwall-staging</string>  ← Staging!
```

## Solution

### Step 1: Get iOS Config from Staging Project

1. **Go to Firebase Console**: https://console.firebase.google.com/
2. **Select** `freshwall-staging` project (top left dropdown)
3. **Click gear icon** (⚙️) → **Project settings**
4. **General tab** → Scroll to **"Your apps"**

### Step 2: Add iOS App (if needed)

If you don't see an iOS app listed:

1. Click **Add app** → **iOS** icon
2. **iOS bundle ID**: `app.freshwall.beta` (use your actual dev bundle ID)
3. **App nickname**: "FreshWall Dev" (optional)
4. **App Store ID**: Leave blank
5. Click **Register app**
6. **Download** `GoogleService-Info.plist`
7. Skip the rest of the setup

### Step 3: Get the Config Values

You'll see or download a plist with these values:

```xml
<key>API_KEY</key>
<string>YOUR_STAGING_API_KEY</string>

<key>GCM_SENDER_ID</key>
<string>473800449577</string>

<key>PROJECT_ID</key>
<string>freshwall-staging</string>

<key>STORAGE_BUCKET</key>
<string>freshwall-staging.firebasestorage.app</string>

<key>GOOGLE_APP_ID</key>
<string>YOUR_STAGING_APP_ID</string>

<key>CLIENT_ID</key>
<string>YOUR_STAGING_CLIENT_ID</string>
```

### Step 4: Update Your Dev Plist

Replace the contents of:
```
App/FreshWall/FreshWallApp/GoogleService-Info-Dev.plist
```

With the staging values from Step 3.

**Key changes:**
- `PROJECT_ID`: `freshwall-30afe` → `freshwall-staging`
- `STORAGE_BUCKET`: `freshwall-30afe.firebasestorage.app` → `freshwall-staging.firebasestorage.app`
- `API_KEY`: New staging key
- `GOOGLE_APP_ID`: New staging app ID
- `CLIENT_ID`: New staging client ID

### Step 5: Same for Beta

Repeat for:
```
App/FreshWall/FreshWallApp/GoogleService-Info-Beta.plist
```

### Step 6: Clean Build & Restart

```bash
# In Xcode:
1. Product → Clean Build Folder (Shift+Cmd+K)
2. Stop the app completely
3. Build and run again
```

## Verify It's Working

### In the App:

1. Open **Debug Menu** (if you have one in settings)
2. Check current environment shows: "Firebase Dev" or "freshwall-staging"
3. Try logging in - it should connect to staging

### In Console Output:

Look for this in Xcode console:
```
✅ Firebase configured using: GoogleService-Info-Dev.plist
🚀 Using Firebase Dev
```

Should show **staging** data, not production data.

## Quick Test

Create a test incident in the app. Then check:
- **Staging Firebase Console**: https://console.firebase.google.com/project/freshwall-staging/firestore
- Should see the new incident there
- **Production should be unchanged**

## Troubleshooting

### Still seeing production data

**Solutions:**
1. Make sure you're running the **Dev** scheme in Xcode
2. Clean build folder (Shift+Cmd+K)
3. Delete app from simulator/device
4. Check `GoogleService-Info-Dev.plist` has `PROJECT_ID` = `freshwall-staging`

### "App won't build"

**Solutions:**
1. Check plist XML is valid
2. Make sure all required keys are present
3. Check for typos in values

### "Authentication failed"

**Solutions:**
1. Make sure you added your app's bundle ID in Firebase Console
2. Check `GOOGLE_APP_ID` is correct
3. Try creating a new user in staging

## Environment Summary

After this setup:

| Build Config | Plist File | Firebase Project | Use Case |
|--------------|-----------|------------------|----------|
| **Dev** | GoogleService-Info-Dev.plist | `freshwall-staging` | Development |
| **Beta** | GoogleService-Info-Beta.plist | `freshwall-staging` | TestFlight staging |
| **Prod** | GoogleService-Info-Prod.plist | `freshwall-30afe` | Production |

---

**Last Updated**: January 2025
