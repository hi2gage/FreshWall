#!/bin/bash

set -e

# Script to generate GoogleService-Info.plist files for different environments
# This script reads Firebase configuration from environment variables
# and generates the appropriate plist files for Xcode Cloud builds

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_DIR="$(dirname "$SCRIPT_DIR")"
PLIST_DIR="$PROJECT_DIR/App/FreshWall/FreshWallApp/GoogleConfigs"

echo "🔧 Generating GoogleService-Info.plist files from environment variables..."

# Function to generate a plist file
generate_plist() {
    local env_name=$1
    local env_name_upper=$(echo "$env_name" | tr '[:lower:]' '[:upper:]')
    local api_key_var="${env_name_upper}_FIREBASE_API_KEY"
    local gcm_sender_id_var="${env_name_upper}_FIREBASE_GCM_SENDER_ID"
    local project_id_var="${env_name_upper}_FIREBASE_PROJECT_ID"
    local storage_bucket_var="${env_name_upper}_FIREBASE_STORAGE_BUCKET"
    local google_app_id_var="${env_name_upper}_FIREBASE_GOOGLE_APP_ID"
    local measurement_id_var="${env_name_upper}_FIREBASE_MEASUREMENT_ID"
    local client_id_var="${env_name_upper}_FIREBASE_CLIENT_ID"
    local reversed_client_id_var="${env_name_upper}_FIREBASE_REVERSED_CLIENT_ID"
    
    # Use the env_name as-is to match Xcode build settings (Dev, Beta, Prod)
    local output_file="$PLIST_DIR/GoogleService-Info-${env_name}.plist"
    
    # Generate bundle ID based on environment
    local bundle_id
    case "$env_name" in
        "Dev")
            bundle_id="app.freshwall.dev"
            ;;
        "Beta")
            bundle_id="app.freshwall.beta"
            ;;
        "Prod")
            bundle_id="app.freshwall"
            ;;
        *)
            echo "❌ Unknown environment: $env_name"
            return 1
            ;;
    esac
    
    # Check if required environment variables are set
    local api_key="${!api_key_var}"
    local gcm_sender_id="${!gcm_sender_id_var}"
    local project_id="${!project_id_var}"
    local storage_bucket="${!storage_bucket_var}"
    local google_app_id="${!google_app_id_var}"
    local client_id="${!client_id_var}"
    local reversed_client_id="${!reversed_client_id_var}"
    local measurement_id="${!measurement_id_var}"

    if [[ -z "$api_key" || -z "$gcm_sender_id" || -z "$project_id" || -z "$storage_bucket" || -z "$google_app_id" || -z "$client_id" || -z "$reversed_client_id" || -z "$measurement_id" ]]; then
        echo "❌ Missing required environment variables for $env_name environment"
        echo "Required variables: ${api_key_var}, ${gcm_sender_id_var}, ${project_id_var}, ${storage_bucket_var}, ${google_app_id_var}, ${client_id_var}, ${reversed_client_id_var}, ${measurement_id_var}"
        return 1
    fi
    
    echo "📝 Generating $output_file..."
    
    cat > "$output_file" << EOF
<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
<plist version="1.0">
<dict>
	<key>CLIENT_ID</key>
	<string>$client_id</string>
	<key>REVERSED_CLIENT_ID</key>
	<string>$reversed_client_id</string>
	<key>API_KEY</key>
	<string>$api_key</string>
	<key>GCM_SENDER_ID</key>
	<string>$gcm_sender_id</string>
	<key>PLIST_VERSION</key>
	<string>1</string>
	<key>BUNDLE_ID</key>
	<string>$bundle_id</string>
	<key>PROJECT_ID</key>
	<string>$project_id</string>
	<key>STORAGE_BUCKET</key>
	<string>$storage_bucket</string>
	<key>IS_ADS_ENABLED</key>
	<false/>
	<key>IS_ANALYTICS_ENABLED</key>
	<true/>
	<key>IS_APPINVITE_ENABLED</key>
	<true/>
	<key>IS_GCM_ENABLED</key>
	<true/>
	<key>IS_SIGNIN_ENABLED</key>
	<true/>
	<key>GOOGLE_APP_ID</key>
	<string>$google_app_id</string>
	<key>GA_MEASUREMENT_ID</key>
	<string>$measurement_id</string>
</dict>
</plist>
EOF
    
    echo "✅ Generated $output_file"
}

# Create the directory if it doesn't exist
mkdir -p "$PLIST_DIR"

# Generate plist files for all environments since users can switch at runtime
echo "📝 Generating all environment plist files (required for runtime switching)..."

generate_plist "Dev"
generate_plist "Beta" 
generate_plist "Prod"

echo "🎉 GoogleService-Info.plist files generated successfully!"
