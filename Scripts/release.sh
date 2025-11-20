#!/bin/bash

set -e

# Colors for output
GREEN='\033[0;32m'
BLUE='\033[0;34m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
NC='\033[0m' # No Color

# Get the current directory
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_DIR="$(dirname "$SCRIPT_DIR")"
XCCONFIG_FILE="$PROJECT_DIR/App/FreshWall/Configurations/Base.xcconfig"

echo -e "${BLUE}🚀 FreshWall Release Script${NC}"
echo "=============================="

# Check if we're in a git repository
if ! git rev-parse --git-dir > /dev/null 2>&1; then
    echo -e "${RED}❌ Not in a git repository${NC}"
    exit 1
fi

# Check current branch - must be on staging to create release branch
CURRENT_BRANCH=$(git rev-parse --abbrev-ref HEAD)
if [ "$CURRENT_BRANCH" != "staging" ]; then
    echo -e "${RED}❌ Release script must be run from 'staging' branch${NC}"
    echo -e "${YELLOW}Current branch: ${CURRENT_BRANCH}${NC}"
    echo -e "${BLUE}Please checkout staging first: git checkout staging${NC}"
    exit 1
fi

# Check if working directory is clean
if ! git diff-index --quiet HEAD --; then
    echo -e "${RED}❌ Working directory is not clean. Please commit or stash changes first.${NC}"
    exit 1
fi

# Ensure we're up to date with remote
echo -e "${BLUE}📥 Syncing with remote staging...${NC}"
git pull origin staging

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
echo -e "${BLUE}🌿 Creating release branch...${NC}"

# Create release branch from staging
RELEASE_BRANCH="release/v${NEW_VERSION}"
git checkout -b "$RELEASE_BRANCH"

echo ""
echo -e "${BLUE}🔧 Updating version in Base.xcconfig...${NC}"

# Update version in Base.xcconfig
if [ -f "$XCCONFIG_FILE" ]; then
    # Update IDENTITY_VERSION
    sed -i '' "s/IDENTITY_VERSION = .*/IDENTITY_VERSION = $NEW_VERSION/" "$XCCONFIG_FILE"
    
    # Increment build number - use current timestamp for uniqueness
    BUILD_NUMBER=$(date +%Y%m%d%H%M)
    sed -i '' "s/IDENTITY_BUILD = .*/IDENTITY_BUILD = $BUILD_NUMBER/" "$XCCONFIG_FILE"
    
    echo -e "${GREEN}✅ Updated version to ${NEW_VERSION} and build to ${BUILD_NUMBER} in Base.xcconfig${NC}"
else
    echo -e "${RED}❌ Base.xcconfig not found at expected location: $XCCONFIG_FILE${NC}"
    exit 1
fi

echo -e "${BLUE}📝 Committing version bump...${NC}"

# Add and commit the version changes
git add .
git commit -m "Bump version to v${NEW_VERSION}

🤖 Generated with [Claude Code](https://claude.ai/code)

Co-Authored-By: Claude <noreply@anthropic.com>"

echo -e "${BLUE}🚀 Pushing release branch and creating tag...${NC}"

# Push the release branch
git push -u origin "$RELEASE_BRANCH"

# Create and push tag
git tag "v${NEW_VERSION}"
git push origin "v${NEW_VERSION}"

echo ""
echo -e "${GREEN}✅ Pushed release branch and tag${NC}"

# Create PR to staging
echo ""
echo -e "${BLUE}🔀 Creating pull request to staging...${NC}"

if command -v gh &> /dev/null; then
    gh pr create \
        --base staging \
        --head "$RELEASE_BRANCH" \
        --title "Release v${NEW_VERSION}" \
        --body "$(cat <<EOF
## Release v${NEW_VERSION}

Version bump and release preparation.

### Summary
- Version: ${NEW_VERSION}
- Build: ${BUILD_NUMBER}
- Tag: v${NEW_VERSION}

### Pre-merge Checklist
- [ ] Version numbers updated correctly
- [ ] Tests passing
- [ ] Ready for staging deployment

🤖 Generated with [Claude Code](https://claude.ai/code)
EOF
)"
    echo -e "${GREEN}✅ Pull request to staging created successfully!${NC}"

    # Ask if user wants to create PR to main as well
    echo ""
    read -p "Also create a PR from staging → main? (y/N): " CREATE_MAIN_PR
    if [[ $CREATE_MAIN_PR =~ ^[Yy]$ ]]; then
        echo -e "${BLUE}🔀 Creating pull request to main...${NC}"
        gh pr create \
            --base main \
            --head staging \
            --title "🚀 Promote staging to production (v${NEW_VERSION})" \
            --body "$(cat <<EOF
## Release v${NEW_VERSION}

This PR promotes staging to production.

### Summary
- Version: ${NEW_VERSION}
- Build: ${BUILD_NUMBER}
- Tag: v${NEW_VERSION}

### Deployment Checklist
- [ ] Staging tests passed
- [ ] Manual testing completed
- [ ] Release notes updated
- [ ] Ready for production deployment

🤖 Generated with [Claude Code](https://claude.ai/code)
EOF
)"
        echo -e "${GREEN}✅ Pull request to main created successfully!${NC}"
    fi
else
    echo -e "${YELLOW}⚠️  GitHub CLI (gh) not found. Please create PRs manually:${NC}"
    echo -e "${BLUE}   Staging: https://github.com/hi2gage/FreshWall/compare/staging...${RELEASE_BRANCH}${NC}"
    echo -e "${BLUE}   Main: https://github.com/hi2gage/FreshWall/compare/main...staging${NC}"
fi

# Return to staging branch
git checkout staging

echo ""
echo -e "${GREEN}🎉 Release v${NEW_VERSION} prepared successfully!${NC}"
echo -e "${BLUE}📋 Summary:${NC}"
echo -e "   • Version: ${NEW_VERSION}"
echo -e "   • Build: ${BUILD_NUMBER}"
echo -e "   • Tag: v${NEW_VERSION}"
echo -e "   • Branch: ${RELEASE_BRANCH}"
echo ""
echo -e "${BLUE}🔗 Next steps:${NC}"
echo -e "   • Review and merge ${RELEASE_BRANCH} → staging PR"
echo -e "   • After merging to staging, merge staging → main PR"
echo -e "   • Monitor deployment and test release"