#!/bin/bash

# Xcode Cloud Post-Clone Script
# This script runs after Xcode Cloud clones your repository
# It sets up the environment and generates necessary configuration files

set -e

echo "🚀 Running Xcode Cloud post-clone setup..."

# Trust Swift Package plugins (like SwiftLint) by skipping signature validation
defaults write com.apple.dt.Xcode IDESkipPackagePluginFingerprintValidatation -bool YES
defaults write com.apple.dt.Xcode IDESkipMacroFingerprintValidation -bool YES

# Navigate to the project root
cd "$CI_PRIMARY_REPOSITORY_PATH"

# Generate GoogleService-Info.plist files from environment variables
echo "📱 Generating Firebase configuration files..."
./Scripts/generate-google-service-info.sh

echo "✅ Xcode Cloud post-clone setup completed successfully!"