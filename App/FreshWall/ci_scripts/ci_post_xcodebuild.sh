#!/bin/bash

set -e

echo "🚀 Running post-build script for TestFlight..."

# Make sure we're in the right directory
cd "$CI_PRIMARY_REPOSITORY_PATH"

# Generate release notes
chmod +x Scripts/generate-release-notes.sh
./Scripts/generate-release-notes.sh

# The release notes file can be used by Xcode Cloud
# or uploaded to your own service for later use
if [ -f "release-notes.txt" ]; then
    echo "📝 Release notes generated successfully"
    echo "Contents:"
    cat release-notes.txt
else
    echo "❌ Failed to generate release notes"
fi

echo "✅ Post-build script completed"