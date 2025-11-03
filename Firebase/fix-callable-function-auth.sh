#!/bin/bash

# Fix Cloud Run authentication for Firebase callable functions in staging
#
# Problem: Cloud Run requires authentication by default, but Firebase callable
# functions handle auth internally through the Firebase SDK. This script makes
# the Cloud Run services publicly accessible so Firebase can handle auth.
#
# Security: This is SAFE because:
# - Firebase validates the auth token in the request payload
# - Only authenticated Firebase users can execute function logic
# - Cloud Run just handles the HTTP transport layer

set -e

PROJECT="freshwall-staging"
REGION="us-central1"

# Firebase callable functions (lowercase service names in Cloud Run)
CALLABLE_FUNCTIONS=(
  "createteamcreateuser"
  "jointeamcreateuser"
  "generateinvitecode"
  "notifynewincident"
  "notifynewclient"
  "notifynewuser"
)

echo "🔧 Fixing Cloud Run authentication for Firebase callable functions"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo ""
echo "Project: $PROJECT"
echo "Region: $REGION"
echo ""
echo "This will make the Cloud Run services publicly invokable."
echo "Firebase will still validate authentication internally."
echo ""
read -p "Continue? (y/n) " -n 1 -r
echo ""

if [[ ! $REPLY =~ ^[Yy]$ ]]; then
    echo "Aborted."
    exit 1
fi

echo ""
echo "Setting permissions..."
echo ""

# Check if gcloud is installed
if ! command -v gcloud &> /dev/null; then
    echo "❌ Error: gcloud CLI is not installed"
    echo ""
    echo "Please install it from: https://cloud.google.com/sdk/docs/install"
    echo ""
    echo "Or manually set permissions in Google Cloud Console:"
    echo "1. Go to https://console.cloud.google.com/run?project=$PROJECT"
    echo "2. For each function below:"
    for func in "${CALLABLE_FUNCTIONS[@]}"; do
        echo "   - $func"
    done
    echo "3. Click the function → Permissions tab → Add Principal"
    echo "4. Principal: allUsers"
    echo "5. Role: Cloud Run Invoker"
    exit 1
fi

SUCCESS_COUNT=0
FAILED_COUNT=0

for func in "${CALLABLE_FUNCTIONS[@]}"; do
    echo "📝 $func"

    if gcloud run services add-iam-policy-binding "$func" \
        --project="$PROJECT" \
        --region="$REGION" \
        --member="allUsers" \
        --role="roles/run.invoker" \
        --quiet 2>/dev/null; then

        echo "   ✅ Successfully updated"
        ((SUCCESS_COUNT++))
    else
        echo "   ⚠️  Failed (service may not exist yet)"
        ((FAILED_COUNT++))
    fi
    echo ""
done

echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo ""
echo "Results:"
echo "  ✅ Success: $SUCCESS_COUNT"
if [ $FAILED_COUNT -gt 0 ]; then
    echo "  ⚠️  Failed: $FAILED_COUNT (may not be deployed yet)"
fi
echo ""

if [ $SUCCESS_COUNT -gt 0 ]; then
    echo "✅ Done! Your Firebase callable functions should now work correctly."
    echo ""
    echo "Test with your iOS app - the 403 authentication errors should be gone."
else
    echo "⚠️  No functions were updated."
    echo ""
    echo "Make sure your functions are deployed first:"
    echo "  cd Firebase && firebase deploy --only functions"
fi
echo ""
