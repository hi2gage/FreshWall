#!/bin/bash

# Check recent Firestore queries in staging

PROJECT_ID="freshwall-staging"
LIMIT=50

echo "📊 Fetching recent Firestore operations..."
echo ""

# Get all Firestore operations
gcloud logging read "resource.type=cloud_firestore_database" \
  --limit $LIMIT \
  --format="table(timestamp, protoPayload.methodName, protoPayload.resourceName)" \
  --project $PROJECT_ID

echo ""
echo "💡 Common methodNames:"
echo "  - BatchGetDocuments: Read operations"
echo "  - Commit: Write operations"
echo "  - Listen: Real-time listeners"
echo "  - RunQuery: Collection queries"
