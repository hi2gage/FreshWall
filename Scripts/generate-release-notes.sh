#!/bin/bash

set -e

# Generate release notes for TestFlight from git commits
# This script can be run in Xcode Cloud post-actions

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_DIR="$(dirname "$SCRIPT_DIR")"

echo "🔤 Generating TestFlight release notes..."

# Get the latest tag (previous release)
LATEST_TAG=$(git describe --tags --abbrev=0 2>/dev/null || echo "")

if [ -z "$LATEST_TAG" ]; then
    echo "No previous tags found, using all commits from last 20"
    COMMITS=$(git log --oneline -20 --pretty=format:"• %s")
else
    echo "Getting commits since tag: $LATEST_TAG"
    COMMITS=$(git log ${LATEST_TAG}..HEAD --oneline --pretty=format:"• %s")
fi

# Create release notes
RELEASE_NOTES_FILE="$PROJECT_DIR/release-notes.txt"

cat > "$RELEASE_NOTES_FILE" << EOF
🚀 FreshWall Build $(date +"%Y.%m.%d")

What's New:
$COMMITS

📱 Test Instructions:
• Sign in with your Google account or test credentials
• Try creating a new incident with photos
• Test the web dashboard at your Vercel URL
• Check role-based permissions (admin vs field worker)

🐛 Known Issues:
• Report any issues via the debug menu
• Check console logs for detailed error information

Built with ❤️ by Claude Code
EOF

echo "✅ Release notes generated: $RELEASE_NOTES_FILE"
cat "$RELEASE_NOTES_FILE"