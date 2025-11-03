#!/bin/bash

# Colors for output
GREEN='\033[0;32m'
BLUE='\033[0;34m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
CYAN='\033[0;36m'
NC='\033[0m' # No Color

# Get the script directory
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_DIR="$(dirname "$SCRIPT_DIR")"

echo -e "${BLUE}🔍 FreshWall Environment Status${NC}"
echo "=================================="
echo ""

# Git Information
echo -e "${CYAN}📦 Git Status${NC}"
echo "-------------------"
cd "$PROJECT_DIR"
echo -e "Current branch: ${GREEN}$(git branch --show-current)${NC}"
echo -e "Latest commit: $(git log -1 --oneline)"
echo -e "Latest tag: ${GREEN}$(git describe --tags --abbrev=0 2>/dev/null || echo 'No tags')${NC}"
echo ""

# Check if working directory is clean
if git diff-index --quiet HEAD --; then
    echo -e "Working directory: ${GREEN}✓ Clean${NC}"
else
    echo -e "Working directory: ${YELLOW}⚠ Uncommitted changes${NC}"
fi
echo ""

# Firebase Information
echo -e "${CYAN}🔥 Firebase Configuration${NC}"
echo "-------------------"
if [ -d "$PROJECT_DIR/Firebase" ]; then
    cd "$PROJECT_DIR/Firebase"
    CURRENT_PROJECT=$(firebase use 2>&1 | grep "Active Project" | awk '{print $3}')

    if [ -n "$CURRENT_PROJECT" ]; then
        echo -e "Active project: ${GREEN}$CURRENT_PROJECT${NC}"
    else
        echo -e "${YELLOW}⚠ No active Firebase project${NC}"
    fi

    # Check if projects are configured
    if [ -f ".firebaserc" ]; then
        echo ""
        echo "Configured projects:"
        grep -A 10 '"projects"' .firebaserc | grep -E '(staging|production)' | sed 's/^/  /'
    fi
else
    echo -e "${RED}❌ Firebase directory not found${NC}"
fi
echo ""

# Web App Information
echo -e "${CYAN}🌐 Web App Status${NC}"
echo "-------------------"
if [ -d "$PROJECT_DIR/Web" ]; then
    cd "$PROJECT_DIR/Web"

    # Check if node_modules exists
    if [ -d "node_modules" ]; then
        echo -e "Dependencies: ${GREEN}✓ Installed${NC}"
    else
        echo -e "Dependencies: ${YELLOW}⚠ Not installed (run npm install)${NC}"
    fi

    # Check environment files
    echo ""
    echo "Environment files:"
    [ -f ".env.local" ] && echo -e "  ${GREEN}✓${NC} .env.local" || echo -e "  ${RED}✗${NC} .env.local"
    [ -f ".env.staging" ] && echo -e "  ${GREEN}✓${NC} .env.staging" || echo -e "  ${YELLOW}⚠${NC} .env.staging (template created)"
    [ -f ".env.production" ] && echo -e "  ${GREEN}✓${NC} .env.production" || echo -e "  ${YELLOW}⚠${NC} .env.production (template created)"

    # Check if Next.js is built
    if [ -d ".next" ]; then
        echo ""
        echo -e "Next.js build: ${GREEN}✓ Built${NC}"
    else
        echo ""
        echo -e "Next.js build: ${YELLOW}⚠ Not built${NC}"
    fi
else
    echo -e "${RED}❌ Web directory not found${NC}"
fi
echo ""

# iOS App Information
echo -e "${CYAN}📱 iOS App Status${NC}"
echo "-------------------"
if [ -d "$PROJECT_DIR/App/FreshWall" ]; then
    cd "$PROJECT_DIR/App/FreshWall"

    if [ -f "Configurations/Base.xcconfig" ]; then
        VERSION=$(grep "IDENTITY_VERSION" Configurations/Base.xcconfig | cut -d'=' -f2 | tr -d ' ')
        BUILD=$(grep "IDENTITY_BUILD" Configurations/Base.xcconfig | cut -d'=' -f2 | tr -d ' ')
        echo -e "Version: ${GREEN}$VERSION${NC}"
        echo -e "Build: ${GREEN}$BUILD${NC}"
    else
        echo -e "${YELLOW}⚠ Version info not found${NC}"
    fi
else
    echo -e "${RED}❌ iOS app directory not found${NC}"
fi
echo ""

# Reminders
echo -e "${CYAN}📋 Quick Commands${NC}"
echo "-------------------"
echo "Switch Firebase env:   firebase use staging|production"
echo "Deploy Firebase:       ./Scripts/deploy-firebase.sh"
echo "Release iOS:           ./Scripts/release.sh"
echo "Deploy web:            git push origin main (auto-deploys)"
echo ""
echo "Check status again:    ./Scripts/env-status.sh"
echo ""
