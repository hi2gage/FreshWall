#!/bin/bash

# Fix Cloud Build permissions for staging Firebase project
# This grants the necessary IAM roles for Cloud Functions v2 deployment

PROJECT_ID="freshwall-staging"
PROJECT_NUMBER="473800449577"

echo "🔧 Granting Cloud Build permissions for $PROJECT_ID..."

# Grant Cloud Build service agent role to the Cloud Build service account
echo "Granting cloudbuild.builds.builder to compute service account..."
gcloud projects add-iam-policy-binding $PROJECT_ID \
  --member="serviceAccount:${PROJECT_NUMBER}-compute@developer.gserviceaccount.com" \
  --role="roles/cloudbuild.builds.builder"

# Grant Cloud Run Admin to Cloud Build service account (needed for Cloud Functions v2)
echo "Granting run.admin to Cloud Build service account..."
gcloud projects add-iam-policy-binding $PROJECT_ID \
  --member="serviceAccount:${PROJECT_NUMBER}@cloudbuild.gserviceaccount.com" \
  --role="roles/run.admin"

# Grant Service Account User role (needed to deploy functions)
echo "Granting iam.serviceAccountUser to Cloud Build service account..."
gcloud projects add-iam-policy-binding $PROJECT_ID \
  --member="serviceAccount:${PROJECT_NUMBER}@cloudbuild.gserviceaccount.com" \
  --role="roles/iam.serviceAccountUser"

echo "✅ Permissions granted! Try deploying again with:"
echo "   firebase deploy --only functions"
