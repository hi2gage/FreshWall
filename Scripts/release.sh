#!/bin/bash

set -e

# Colors for output
GREEN='\033[0;32m'
BLUE='\033[0;34m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
NC='\033[0m' # No Color

echo -e "${BLUE}🚀 FreshWall Release Script${NC}"
echo "=============================="

# Check if gh CLI is installed
if ! command -v gh &> /dev/null; then
    echo -e "${RED}❌ GitHub CLI (gh) is not installed${NC}"
    echo -e "${YELLOW}Install it with: brew install gh${NC}"
    exit 1
fi

# Check if we're in a git repository
if ! git rev-parse --git-dir > /dev/null 2>&1; then
    echo -e "${RED}❌ Not in a git repository${NC}"
    exit 1
fi

# Get the current version from git tags
CURRENT_VERSION=$(git tag --list --sort=-version:refname | head -1 | sed 's/^v//')
if [ -z "$CURRENT_VERSION" ]; then
    echo -e "${YELLOW}⚠️  No existing version tags found. Starting with 1.0.0${NC}"
    CURRENT_VERSION="1.0.0"
fi

echo -e "${BLUE}📋 Current version: ${CURRENT_VERSION}${NC}"

# Parse current version
IFS='.' read -r MAJOR MINOR PATCH <<< "$CURRENT_VERSION"

# Ask user what type of release
echo ""
echo "What type of release?"
echo "1) Patch (${MAJOR}.${MINOR}.$((PATCH+1)))"
echo "2) Minor (${MAJOR}.$((MINOR+1)).0)"
echo "3) Major ($((MAJOR+1)).0.0)"
echo "4) Custom version"
echo ""
read -p "Enter your choice (1-4): " RELEASE_TYPE

case $RELEASE_TYPE in
    1)
        NEW_VERSION="${MAJOR}.${MINOR}.$((PATCH+1))"
        ;;
    2)
        NEW_VERSION="${MAJOR}.$((MINOR+1)).0"
        ;;
    3)
        NEW_VERSION="$((MAJOR+1)).0.0"
        ;;
    4)
        read -p "Enter custom version (e.g., 1.2.3): " NEW_VERSION
        ;;
    *)
        echo -e "${RED}❌ Invalid choice${NC}"
        exit 1
        ;;
esac

echo -e "${GREEN}📦 New version will be: ${NEW_VERSION}${NC}"

# Confirm with user
read -p "Continue with release v${NEW_VERSION}? (y/N): " CONFIRM
if [[ ! $CONFIRM =~ ^[Yy]$ ]]; then
    echo -e "${YELLOW}🚫 Release cancelled${NC}"
    exit 0
fi

echo ""
echo -e "${BLUE}🚀 Triggering GitHub workflow...${NC}"

# Determine the workflow inputs based on release type
if [ "$RELEASE_TYPE" = "1" ]; then
    # Patch version
    gh workflow run prepare-release.yml \
        --ref staging \
        -f version_bump=patch
elif [ "$RELEASE_TYPE" = "2" ]; then
    # Minor version
    gh workflow run prepare-release.yml \
        --ref staging \
        -f version_bump=minor
elif [ "$RELEASE_TYPE" = "3" ]; then
    # Major version
    gh workflow run prepare-release.yml \
        --ref staging \
        -f version_bump=major
elif [ "$RELEASE_TYPE" = "4" ]; then
    # Custom version
    gh workflow run prepare-release.yml \
        --ref staging \
        -f version_bump=custom \
        -f custom_version="$NEW_VERSION"
fi

echo -e "${GREEN}✅ Workflow triggered successfully!${NC}"
echo ""
echo -e "${BLUE}📺 Watching workflow progress...${NC}"
echo ""

# Wait a moment for the workflow to start
sleep 3

# Watch the workflow run
gh run watch

echo ""
echo -e "${GREEN}🎉 Release v${NEW_VERSION} prepared!${NC}"
echo ""
echo -e "${BLUE}🔗 Next steps:${NC}"
echo -e "   • Review and merge the release → staging PR"
echo -e "   • Auto-promote will create staging → main PR"
echo -e "   • Review and merge the staging → main PR"
echo -e "   • Tag v${NEW_VERSION} will be auto-created when merged to main"