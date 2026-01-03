# Xcode Cloud Environment Variables Setup

This guide explains how to securely configure Firebase Google Service Info files for Xcode Cloud without committing sensitive data to your repository.

## Overview

The build process uses environment variables to generate `GoogleService-Info.plist` files during the Xcode Cloud build. This keeps sensitive Firebase configuration out of your git repository while ensuring builds work correctly.

## Required Environment Variables

⚠️ **Important**: Your app allows users to switch between environments at runtime, so **ALL** environment variables below are required for every Xcode Cloud build, regardless of which scheme you're building.

Set these environment variables in your Xcode Cloud configuration:

### Development Environment
- `DEV_FIREBASE_API_KEY` - Firebase API Key
- `DEV_FIREBASE_GCM_SENDER_ID` - Firebase GCM Sender ID  
- `DEV_FIREBASE_PROJECT_ID` - Firebase Project ID
- `DEV_FIREBASE_STORAGE_BUCKET` - Firebase Storage Bucket
- `DEV_FIREBASE_GOOGLE_APP_ID` - Firebase Google App ID

### Beta Environment
- `BETA_FIREBASE_API_KEY` - Firebase API Key
- `BETA_FIREBASE_GCM_SENDER_ID` - Firebase GCM Sender ID
- `BETA_FIREBASE_PROJECT_ID` - Firebase Project ID
- `BETA_FIREBASE_STORAGE_BUCKET` - Firebase Storage Bucket  
- `BETA_FIREBASE_GOOGLE_APP_ID` - Firebase Google App ID

### Production Environment
- `PROD_FIREBASE_API_KEY` - Firebase API Key
- `PROD_FIREBASE_GCM_SENDER_ID` - Firebase GCM Sender ID
- `PROD_FIREBASE_PROJECT_ID` - Firebase Project ID
- `PROD_FIREBASE_STORAGE_BUCKET` - Firebase Storage Bucket
- `PROD_FIREBASE_GOOGLE_APP_ID` - Firebase Google App ID

**Note**: Bundle IDs are automatically generated based on environment:
- Dev: `app.freshwall.dev`
- Beta: `app.freshwall.beta`  
- Prod: `app.freshwall`

## How to Set Environment Variables in Xcode Cloud

1. Open **App Store Connect**
2. Navigate to your app
3. Go to **Xcode Cloud** tab
4. Select your **Workflow**
5. Click **Environment** tab
6. Add the environment variables listed above with their corresponding values from your Firebase project

## Where to Find Firebase Values

You can find these values in your Firebase project:

1. Go to [Firebase Console](https://console.firebase.google.com/)
2. Select your project
3. Go to **Project Settings** (gear icon)
4. In the **General** tab, scroll down to **Your apps**
5. Click on your iOS app
6. Download the `GoogleService-Info.plist` temporarily to see the values
7. Copy the values to your Xcode Cloud environment variables
8. Delete the downloaded file (don't commit it)

## Build Process

1. Xcode Cloud clones your repository
2. Runs `ci_scripts/ci_post_clone.sh`
3. This script calls `Scripts/generate-google-service-info.sh`
4. The script reads environment variables and generates the appropriate plist files
5. Xcode builds with the generated configuration files

## Security Benefits

✅ **Secure**: Sensitive Firebase config is stored in Xcode Cloud environment variables, not in git  
✅ **Flexible**: Different configurations for dev/beta/prod environments  
✅ **Automated**: No manual file management during builds  
✅ **Auditable**: Environment variable changes are tracked in App Store Connect  

## Local Development

For local development, keep your existing `GoogleService-Info-*.plist` files in your local directory but make sure they're in `.gitignore`.

## Troubleshooting

If builds fail with missing plist files:

1. Verify all required environment variables are set in Xcode Cloud
2. Check that variable names match exactly (case-sensitive)
3. Ensure the scheme name detection logic matches your scheme names
4. Check Xcode Cloud build logs for detailed error messages

## Testing the Script Locally

You can test the script locally by setting environment variables:

```bash
export DEV_API_KEY="your-api-key"
export DEV_GCM_SENDER_ID="your-sender-id"
# ... set other variables
./Scripts/generate-google-service-info.sh
```