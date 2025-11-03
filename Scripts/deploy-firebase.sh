#!/bin/bash

set -e

# Colors for output
GREEN='\033[0;32m'
BLUE='\033[0;34m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
NC='\033[0m' # No Color

# Get the script directory
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_DIR="$(dirname "$SCRIPT_DIR")"
FIREBASE_DIR="$PROJECT_DIR/Firebase"

echo -e "${BLUE}🔥 FreshWall Firebase Deployment${NC}"
echo "=================================="

# Check if Firebase directory exists
if [ ! -d "$FIREBASE_DIR" ]; then
    echo -e "${RED}❌ Firebase directory not found${NC}"
    exit 1
fi

cd "$FIREBASE_DIR"

# Get available environments
echo ""
echo "Select environment to deploy to:"
echo "1) Staging"
echo "2) Production"
echo ""
read -p "Enter your choice (1-2): " ENV_CHOICE

case $ENV_CHOICE in
    1)
        ENVIRONMENT="staging"
        ;;
    2)
        ENVIRONMENT="production"
        ;;
    *)
        echo -e "${RED}❌ Invalid choice${NC}"
        exit 1
        ;;
esac

echo ""
echo -e "${YELLOW}⚠️  You are about to deploy to ${ENVIRONMENT}${NC}"
read -p "Continue? (y/N): " CONFIRM
if [[ ! $CONFIRM =~ ^[Yy]$ ]]; then
    echo -e "${YELLOW}🚫 Deployment cancelled${NC}"
    exit 0
fi

# Switch to selected environment
echo ""
echo -e "${BLUE}🔄 Switching to ${ENVIRONMENT} project...${NC}"
firebase use "$ENVIRONMENT"

# Build functions
echo -e "${BLUE}🔨 Building Cloud Functions...${NC}"
cd functions
npm run build
cd ..

# Ask what to deploy
echo ""
echo "What would you like to deploy?"
echo "1) Everything (functions, firestore rules, storage rules, indexes)"
echo "2) Functions only"
echo "3) Firestore rules only"
echo "4) Storage rules only"
echo ""
read -p "Enter your choice (1-4): " DEPLOY_CHOICE

case $DEPLOY_CHOICE in
    1)
        DEPLOY_TARGET=""
        echo -e "${BLUE}📦 Deploying everything...${NC}"
        ;;
    2)
        DEPLOY_TARGET="--only functions"
        echo -e "${BLUE}📦 Deploying functions only...${NC}"
        ;;
    3)
        DEPLOY_TARGET="--only firestore"
        echo -e "${BLUE}📦 Deploying Firestore rules only...${NC}"
        ;;
    4)
        DEPLOY_TARGET="--only storage"
        echo -e "${BLUE}📦 Deploying Storage rules only...${NC}"
        ;;
    *)
        echo -e "${RED}❌ Invalid choice${NC}"
        exit 1
        ;;
esac

# Deploy
firebase deploy $DEPLOY_TARGET

echo ""
echo -e "${GREEN}✅ Deployment to ${ENVIRONMENT} completed successfully!${NC}"

# Show project info
echo ""
echo -e "${BLUE}📋 Deployment Summary:${NC}"
firebase use
echo ""
echo -e "${BLUE}🔗 Console:${NC}"
if [ "$ENVIRONMENT" == "staging" ]; then
    echo "   https://console.firebase.google.com/project/freshwall-staging"
else
    echo "   https://console.firebase.google.com/project/freshwall-30afe"
fi
