#!/bin/bash

set -e

# Colors for output
GREEN='\033[0;32m'
BLUE='\033[0;34m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
NC='\033[0m' # No Color

echo -e "${BLUE}🚀 FreshWall Platform Release Script${NC}"
echo "======================================"

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

# Check if on main branch
CURRENT_BRANCH=$(git rev-parse --abbrev-ref HEAD)
if [ "$CURRENT_BRANCH" != "main" ]; then
    echo -e "${RED}❌ Must be on 'main' branch to create releases${NC}"
    echo -e "${YELLOW}Current branch: ${CURRENT_BRANCH}${NC}"
    exit 1
fi

# Ensure we're up to date
git fetch --tags origin

echo ""
echo "Select platform to release:"
echo "1) iOS"
echo "2) Web"
echo "3) Firebase (backend only)"
echo ""
read -p "Enter your choice (1-3): " PLATFORM_CHOICE

case $PLATFORM_CHOICE in
    1)
        PLATFORM="ios"
        PLATFORM_NAME="iOS"
        VERSION_FILE="App/FreshWall/Configurations/Base.xcconfig"
        ;;
    2)
        PLATFORM="web"
        PLATFORM_NAME="Web"
        VERSION_FILE="Web/package.json"
        ;;
    3)
        PLATFORM="firebase"
        PLATFORM_NAME="Firebase"
        VERSION_FILE="Firebase/functions/package.json"
        ;;
    *)
        echo -e "${RED}❌ Invalid choice${NC}"
        exit 1
        ;;
esac

# Get the current version from git tags for this platform
CURRENT_VERSION=$(git tag --list "${PLATFORM}/v*" --sort=-version:refname | head -1 | sed "s|^${PLATFORM}/v||")
if [ -z "$CURRENT_VERSION" ]; then
    echo -e "${YELLOW}⚠️  No existing ${PLATFORM_NAME} tags found. Starting with 1.0.0${NC}"
    CURRENT_VERSION="1.0.0"
fi

echo -e "${BLUE}📋 Current ${PLATFORM_NAME} version: ${CURRENT_VERSION}${NC}"

# Parse current version
IFS='.' read -r MAJOR MINOR PATCH <<< "$CURRENT_VERSION"

# Ask user what type of release
echo ""
echo "What type of release?"
echo "1) Patch (${MAJOR}.${MINOR}.$((PATCH+1))) - Bug fixes"
echo "2) Minor (${MAJOR}.$((MINOR+1)).0) - New features"
echo "3) Major ($((MAJOR+1)).0.0) - Breaking changes"
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

TAG_NAME="${PLATFORM}/v${NEW_VERSION}"
echo -e "${GREEN}📦 New ${PLATFORM_NAME} version will be: ${NEW_VERSION}${NC}"
echo -e "${GREEN}🏷️  Tag: ${TAG_NAME}${NC}"

# Prompt for release notes
echo ""
echo -e "${BLUE}📝 Enter release notes (press Ctrl+D when done):${NC}"
RELEASE_NOTES=$(cat)

# Confirm with user
echo ""
echo -e "${YELLOW}Review:${NC}"
echo -e "Platform: ${PLATFORM_NAME}"
echo -e "Version: ${NEW_VERSION}"
echo -e "Tag: ${TAG_NAME}"
echo -e "Notes:"
echo "$RELEASE_NOTES"
echo ""
read -p "Create this release? (y/N): " CONFIRM
if [[ ! $CONFIRM =~ ^[Yy]$ ]]; then
    echo -e "${YELLOW}🚫 Release cancelled${NC}"
    exit 0
fi

# Create the tag
echo ""
echo -e "${BLUE}🏷️  Creating tag ${TAG_NAME}...${NC}"
git tag -a "$TAG_NAME" -m "${PLATFORM_NAME} Release v${NEW_VERSION}

${RELEASE_NOTES}"

# Push the tag
echo -e "${BLUE}📤 Pushing tag to origin...${NC}"
git push origin "$TAG_NAME"

# Create GitHub release
echo -e "${BLUE}📦 Creating GitHub release...${NC}"
gh release create "$TAG_NAME" \
    --title "${PLATFORM_NAME} v${NEW_VERSION}" \
    --notes "${RELEASE_NOTES}" \
    --target main

echo ""
echo -e "${GREEN}✅ Release ${TAG_NAME} created successfully!${NC}"
echo ""
echo -e "${BLUE}🔗 View release:${NC}"
gh release view "$TAG_NAME" --web

echo ""
echo -e "${GREEN}🎉 ${PLATFORM_NAME} v${NEW_VERSION} released!${NC}"

# Show what will deploy based on platform
case $PLATFORM in
    ios)
        echo -e "${BLUE}📱 This will trigger:${NC}"
        echo -e "   • iOS app build and TestFlight upload"
        echo -e "   • Firebase deployment (if Firebase/ changes included)"
        ;;
    web)
        echo -e "${BLUE}🌐 This will trigger:${NC}"
        echo -e "   • Web app deployment to Vercel/production"
        echo -e "   • Firebase deployment (if Firebase/ changes included)"
        ;;
    firebase)
        echo -e "${BLUE}🔥 This will trigger:${NC}"
        echo -e "   • Firebase Functions deployment"
        echo -e "   • Firestore rules deployment"
        echo -e "   • Extensions deployment"
        ;;
esac
